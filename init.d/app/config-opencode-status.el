;;; config-opencode-status.el --- OpenCode status enhancements -*- lexical-binding: t -*-

;;; --- Variables ---

(defcustom opencode-max-replay-messages 20
  "Maximum number of messages to render when opening a session.
nil means render all messages. Only the last N messages are rendered;
earlier messages are fetched (for state correctness) but not displayed."
  :type '(choice (const :tag "All messages" nil)
                 (integer :tag "Max messages"))
  :group 'opencode)

(defvar opencode-status--spinner-frames '("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷"))
(defvar opencode-status--spinner-index 0)
(defvar opencode-status--spinner-timer nil)

(defvar opencode-status--lsp-servers nil
  "Cached list of connected LSP servers from opencode server.")

(defvar opencode-status--lsp-abbrevs
  '(("pyright" . "py")
    ("typescript-language-server" . "ts")
    ("bash-language-server" . "sh")
    ("clangd" . "c")
    ("json-language-server" . "json")
    ("elisp-lsp-server" . "el")
    ("racket-langserver" . "rkt")
    ("jdtls" . "java"))
  "Abbreviation map for LSP server IDs in mode-line.")

(defvar opencode-status--title-aliases
  '(("build Big Pickle" . "⚡BP")
    ("build" . "⚡B"))
  "Alist mapping session titles to short aliases for mode-line display.")

;;; --- Utility functions ---

(defun opencode-status--truncate (str max-width)
  "Truncate STR to MAX-WIDTH, adding ellipsis if needed."
  (if (<= (length str) max-width)
      str
    (concat (substring str 0 (- max-width 1)) "…")))

(defun opencode-status--short-title ()
  "Return shortened buffer name for mode-line."
  (let* ((name (buffer-name))
         (title (when (string-match "^\\*OpenCode: \\(.+?\\)\\*$" name)
                  (match-string 1 name)))
         (alias (and title (alist-get title opencode-status--title-aliases nil nil #'equal))))
    (or alias (and title (opencode-status--truncate title 16)) name)))

;;; --- Spinner ---

(defun opencode-status--next-spinner ()
  "Return the next spinner frame and advance index."
  (let ((frame (nth opencode-status--spinner-index opencode-status--spinner-frames)))
    (setq opencode-status--spinner-index
          (mod (1+ opencode-status--spinner-index)
               (length opencode-status--spinner-frames)))
    frame))

(defun opencode-status--start-spinner ()
  "Start the animated spinner timer."
  (unless opencode-status--spinner-timer
    (setq opencode-status--spinner-timer
          (run-with-timer 0 0.1
            (lambda ()
              (when (derived-mode-p 'opencode-session-mode)
                (force-mode-line-update)))))))

(defun opencode-status--stop-spinner ()
  "Stop the animated spinner timer."
  (when opencode-status--spinner-timer
    (cancel-timer opencode-status--spinner-timer)
    (setq opencode-status--spinner-timer nil)))

;;; --- LSP ---

(defun opencode-status--refresh-lsp ()
  "Fetch LSP server list from opencode server and cache it."
  (when (and (boundp 'opencode-api-url) opencode-api-url)
    (opencode-api-lsp servers
      (setq opencode-status--lsp-servers servers)
      (force-mode-line-update))))

(defun opencode-status--lsp-string ()
  "Return LSP display string based on window width.
Returns empty string if no LSP servers or window too narrow."
  (let ((servers opencode-status--lsp-servers)
        (w (window-width)))
    (when (and servers (> (length servers) 0) (>= w 115))
      (if (< w 130)
          (format " L:%d" (length servers))
        (let ((names (mapcar (lambda (s)
                              (or (alist-get (alist-get 'id s)
                                            opencode-status--lsp-abbrevs
                                            nil nil #'equal)
                                  (opencode-status--truncate
                                   (alist-get 'name s) 3)))
                            servers)))
          (format " %s" (string-join names "+")))))))

(defun opencode-status--start-lsp-poll ()
  "Start polling LSP status every 10 seconds."
  (run-with-timer 0 10 #'opencode-status--refresh-lsp))

;;; --- Mode-line ---

(defun opencode-status--network-indicator ()
  "Return network status string for mode-line."
  (if (and (boundp 'opencode--event-subscription)
           (process-live-p opencode--event-subscription))
      (propertize "●" 'face 'success)
    (propertize "●" 'face 'error)))

(defun opencode-status--context-count ()
  "Return number of extra context labels pending."
  (let ((n (length opencode--extra-parts)))
    (if (> n 0)
        (propertize (format "#%d" n) 'face 'bold)
      "")))

;;; ============================================================
;;; Block 1: Things defined in opencode.el (loaded first)
;;; ============================================================

(with-eval-after-load 'opencode

  ;; --- Suppress D-Bus notification errors (no daemon on Hyprland) ---

  (setq opencode-toast-function #'ignore)

  ;; --- Advice: replay optimization: load only last N messages ---

  (defun opencode-status--replay-truncate (orig-fun messages)
    "Truncate MESSAGES to `opencode-max-replay-messages' before replay."
    (let ((limit opencode-max-replay-messages))
      (if (and limit (> (length messages) limit))
          (progn
            (opencode--output
             (propertize
              (format "... %d earlier messages not loaded ...\n\n"
                      (- (length messages) limit))
              'face 'shadow))
            (funcall orig-fun (seq-drop messages (- (length messages) limit))))
        (funcall orig-fun messages))))

  (advice-add 'opencode--replay-session-messages :around
              #'opencode-status--replay-truncate)

  ;; --- Advice: show retry status in buffer ---

  (defun opencode-status--handle-retry (session-id data)
    "Show retry status with visual indicator in SESSION-ID buffer."
    (opencode--with-session-buffer session-id
      (opencode--output
        (propertize
         (format "🔄 Retrying... (%s)" (or (alist-get 'message data) ""))
         'face 'warning))
      (opencode--output "\n")))

  (defun opencode-status--handle-message-around (orig-fun message)
    "Advice: intercept retry messages before ORIG-FUN handles them."
    (let-alist message
      (if (and (equal .type "session.status")
               (equal .data.status "retry"))
          (opencode-status--handle-retry .sessionID .data)
        (funcall orig-fun message))))

  (advice-add 'opencode--handle-message :around #'opencode-status--handle-message-around)

  ;; --- Advice: scroll to end after replay ---

  (defun opencode-status--replay-scroll-after (&rest _)
    "Scroll to end of conversation after session replay completes."
    (when (derived-mode-p 'opencode-session-mode)
      (goto-char (point-max))
      (let ((win (get-buffer-window (current-buffer))))
        (when win
          (with-selected-window win
            (recenter -1))))))

  (advice-add 'opencode--replay-session-messages :after #'opencode-status--replay-scroll-after)

  ;; --- Advice: cleanup spinner on disconnect ---

  (defun opencode-status--disconnect-cleanup (&rest _)
    "Stop spinner when disconnected from opencode server."
    (opencode-status--stop-spinner))

  (advice-add 'opencode-disconnect :after #'opencode-status--disconnect-cleanup))

;;; ============================================================
;;; Block 2: Things defined in opencode-sessions.el (loaded later)
;;; ============================================================

(with-eval-after-load 'opencode-sessions

  ;; --- Terminal-style face overrides ---

  (set-face-attribute 'opencode-request-margin-highlight nil
                      :foreground "#00afff" :background 'unspecified :weight 'normal)
  (set-face-attribute 'opencode-reasoning-margin-highlight nil
                      :foreground "#808080" :background 'unspecified :weight 'normal)
  (set-face-attribute 'opencode-tool-margin-highlight nil
                      :foreground "#d78700" :background 'unspecified :weight 'normal)

  ;; --- Balanced margins ---

  (defun opencode-status--pad-margin (orig-fun face)
    "Pad margin indicator with leading space."
    (propertize " " 'display
                `((margin left-margin)
                  ,(propertize " ▎" 'face face))))

  (advice-add 'opencode--margin :around #'opencode-status--pad-margin)

  (defun opencode-status--set-margins ()
    "Set balanced margins for terminal-style display."
    (setq-local left-margin-width 3
                right-margin-width 1)
    (set-window-margins nil left-margin-width right-margin-width))

  (add-hook 'opencode-session-mode-hook #'opencode-status--set-margins)

  ;; --- Mode-line format ---

  (defun opencode-status--mode-line ()
    "Return custom mode-line for opencode session buffers."
    (let* ((title (opencode-status--short-title))
           (w (window-width)))
      (if (< w 80)
          (list (propertize title 'face 'bold))
        (list (propertize title 'face 'bold) " " mode-line-process))))

  (defun opencode--session-status-indicator ()
    "Return mode line indicator: net, spinner, agent, model, ctx, labels, status, lsp."
    (let-alist opencode-session-agent
      (let* ((busy (string= opencode-session-status "busy"))
             (spinner (if busy (opencode-status--next-spinner) " "))
             (net (opencode-status--network-indicator))
             (agent (pcase .name
                      ("Planner-Sisyphus" "Plan")
                      (_ (opencode-status--truncate .name 8))))
             (model (opencode--current-model))
             (model-name (if model (opencode-status--truncate (alist-get 'name model) 12) ""))
             (variant (when (and .variant model)
                        (propertize (format " %s" .variant)
                                    'face '(bold opencode-request-margin-highlight))))
             (context-used (if (and opencode-session-tokens model
                                    (map-nested-elt model '(limit context)))
                               (let ((pct (* 100 (/ (float opencode-session-tokens)
                                                    (map-nested-elt model '(limit context))))))
                                 (propertize (format "%.0f%%" pct)
                                             'face (cond ((> pct 80) 'error)
                                                         ((> pct 60) 'warning)
                                                         (t 'success))))
                             ""))
             (labels (opencode-status--context-count))
             (status (if busy "*" ">"))
             (lsp (opencode-status--lsp-string))
             (w (window-width)))
        (if busy
            (opencode-status--start-spinner)
          (opencode-status--stop-spinner))
        (cond
         ((< w 80)
          (format " %s%s %s %s %s " net spinner agent context-used status))
         ((< w 115)
          (format " %s%s %s %s %s %s " net spinner agent model-name context-used status))
         (t
          (format " %s%s %s %s%s %s %s %s%s "
                  net spinner agent model-name (or variant "")
                  context-used labels status lsp))))))

  (defun opencode-status--set-mode-line ()
    "Set custom mode-line format for opencode session buffers."
    (setq-local mode-line-format '(:eval (opencode-status--mode-line))))

  (add-hook 'opencode-session-mode-hook #'opencode-status--set-mode-line)

  ;; --- LSP polling ---

  (add-hook 'opencode-session-mode-hook #'opencode-status--start-lsp-poll)

  ;; --- Advice: enhanced error display ---

  (defun opencode-status--display-error-around (orig-fun session-id message)
    "Display error in buffer and minibuffer via ORIG-FUN."
    (funcall orig-fun session-id message)
    (message "%s" (propertize (format "opencode error: %s" message) 'face 'error)))

  (advice-add 'opencode-session--display-error :around #'opencode-status--display-error-around)

  ;; --- Advice: enhanced abort feedback ---

  (defun opencode-status--abort-around (orig-fun)
    "Show feedback before calling ORIG-FUN to abort session."
    (message "%s" (propertize "⏹ Aborting session..." 'face 'warning))
    (funcall orig-fun))

  (advice-add 'opencode-abort-session :around #'opencode-status--abort-around)

  ;; --- Advice: guard tool display for aborted sessions ---

  (defun opencode-status--insert-tool-block-around (orig-fun tool input)
    "Guard ORIG-FUN: aborted tools may have empty input crashing display."
    (condition-case _err
        (funcall orig-fun tool input)
      (error
       (opencode--output
        (propertize (format "[%s tool: display skipped]\n" tool)
                    'face 'shadow)))))

  (advice-add 'opencode--insert-tool-block :around #'opencode-status--insert-tool-block-around))

(provide 'config-opencode-status)
;;; config-opencode-status.el ends here
