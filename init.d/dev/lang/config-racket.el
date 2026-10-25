;;; config-racket.el --- Racket configuration -*- lexical-binding: t; -*-

(use-package racket-mode
  :ensure t
  :defer t
  :mode ("\\.rktl\\'" . racket-mode)
  :custom
  (racket-show-debug-backtrace t)
  (racket-show-debug-local-values t)
  :bind (:map racket-mode-map
              ("C-c C-d" . racket-debug)
              ("C-c C-r" . racket-run)
              ("C-c C-n" . racket-scratch)))

(add-to-list 'lisp-mode-list 'racket-mode)

(set-language-protocol 'racket 'racket-mode-hook
           '("https://github.com/6cdh/tree-sitter-racket.git"))

;; DAP configuration for Racket (using racket-debug-mode)
;; Note: No DAP adapter available for Racket
;; Use racket-mode's built-in debugger instead
(with-eval-after-load 'dape
  (add-to-list 'dape-configs
               '(racket-debug
                 modes (racket-mode)
                 ensure (lambda (config)
                          (unless (executable-find "racket")
                            (user-error "Racket executable not found")))
                 fn (lambda (config)
                      (require 'racket-mode)
                      (let ((proc (racket--repl-and-process)))
                        (unless proc
                          (user-error "No Racket process running. Start one with M-x racket-run"))
                        (unless racket-debug-mode
                          (racket-debug))))
                 :request "launch"
                 :type "racket"
                 :cwd dape-cwd)))

;; Racket-specific dape hydra (needs both dape and racket-debug)
(with-eval-after-load 'dape
  (defhydra racket-dape-hydra (:color pink :hint nil)
    "
Racket DAP: _i_ for information panel.

 ^^Breakpoint ^^Stepping     ^^Watch           ^^Stack      ^^Other               ^^Process
^^-----------------------^^--------------------^^-----------^^----------------------^^--------------
 _b_ : Toggle _s_ : Step      _w_ : Watch       _S_ : Select _x_ : Eval Expr      _r_ : Restart
 _B_ : Remove _o_ : Step Over _d_ : Dump        _<_ : Up     _e_ : Break Expr     _q_ : Quit
 _l_ : Log    _u_ : Step Out  _R_ : REPL        _>_ : Down   _t_ : Select Thread  _D_ : Disconnect
 _h_ : Hits   _n_ : Next      ^ ^               ^ ^          ^ ^                  _Q_ : Quit Menu
"
    ("i" dape-info)
    ("b" racket-debug-toggle-break-expression)
    ("B" racket-debug-remove-all-break-expressions)
    ("l" racket-debug-set-break-expression)
    ("h" racket-debug-help)
    ("s" racket-debug-step)
    ("o" racket-debug-step-over)
    ("u" racket-debug-step-out)
    ("n" racket-debug-forward-breakable)
    ("c" racket-debug-continue)
    ("w" racket-debug-run-to-here)
    ("d" racket-debug-step)
    ("R" racket-run)
    ("r" dape-restart :color blue)
    ("q" dape-quit :color blue)
    ("D" dape-disconnect-quit :color blue)
    ("Q" nil :color blue)
    ("S" dape-select-stack)
    ("<" dape-stack-select-up)
    (">" dape-stack-select-down)
    ("x" dape-evaluate-expression)
    ("e" dape-breakpoint-expression)
    ("t" dape-select-thread))

  ;; Bind Racket-specific hydra to dape-active-mode in racket-mode
  (add-hook 'racket-mode-hook
            (lambda ()
              (when (bound-and-true-p dape-active-mode)
                (local-set-key (kbd "C-c d") 'racket-dape-hydra/body)))))

;;; ------------------------------------------------------------------
;;; Generic Racket scratch sessions
;;;
;;; A scratch is a file-backed Racket buffer plus its own REPL namespace.
;;; It is intentionally independent of any project.  To use a project
;;; library, insert a require with `C-c C-i f' / `C-c C-i m' and run.
;;; ------------------------------------------------------------------

(defgroup racket-scratch nil
  "Generic interactive Racket scratch sessions."
  :group 'racket
  :prefix "racket-scratch-")

(defcustom racket-scratch-directory
  (locate-user-emacs-file "racket-scratch/")
  "Directory used for generated Racket scratch files."
  :type 'directory)

(defcustom racket-scratch-auto-start nil
  "Start the REPL automatically when creating a new scratch.

The default nil follows the DrRacket workflow: edit, then run with
\\[racket-scratch-run]."
  :type 'boolean)

(defcustom racket-scratch-lang "racket"
  "Default #lang used for new Racket scratch files."
  :type 'string)

(defvar-local racket-scratch--inline-eval-p nil
  "Non-nil while a C-j result should be inserted in the scratch buffer.")

(defun racket-scratch--starter (lang)
  "Return initial contents for a scratch using LANG."
  (format
   "#lang %s\n\
\n\
;; Racket scratch session\n\
;; C-c C-c run / C-j eval+print / C-c C-r send region\n\
;; C-c C-z REPL / C-c C-i f import file / C-c C-i m import module\n\
\n\
"

   lang))

(defun racket-scratch--new-file (lang)
  "Create and return a new scratch file for LANG."
  (make-directory racket-scratch-directory t)
  (let ((file (make-temp-file
               (expand-file-name "scratch-" racket-scratch-directory)
               nil ".rkt")))
    (with-temp-file file
      (insert (racket-scratch--starter lang)))
    file))

(defun racket-scratch--show (string &optional pos)
  "Insert STRING after the evaluated expression, or use racket-show."
  (if racket-scratch--inline-eval-p
      (progn
        (setq racket-scratch--inline-eval-p nil)
        (unless (or (null string)
                    (string-empty-p string)
                    (string= string "#<void>"))
          (let ((text (replace-regexp-in-string "\n" "\n;;   " string)))
            (save-excursion
              (goto-char (or pos (point)))
              (insert " => " text)
              (newline)))))
    (if (fboundp 'racket-show-pseudo-tooltip)
        (racket-show-pseudo-tooltip string pos)
      (message "%s" string))))

(defun racket-scratch--insert-after-lang (text)
  "Insert TEXT after the #lang line, or at the beginning."
  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward "^#lang .*$" nil t)
        (progn
          (forward-line 1)
          (unless (bolp) (newline)))
      (goto-char (point-min)))
    (insert "\n" text "\n")))

(defun racket-scratch-import-file (file)
  "Insert a require form for the Racket FILE into the current scratch."
  (interactive "fRacket file to import: ")
  (racket-scratch--insert-after-lang
   (format "(require (file %S))" (expand-file-name file))))

(defun racket-scratch-import-module (module)
  "Insert a require form for MODULE into the current scratch."
  (interactive "sRacket module to import: ")
  (racket-scratch--insert-after-lang (format "(require %s)" module)))

(defun racket-scratch-run ()
  "Run the current scratch file and create/refresh its REPL."
  (interactive)
  (unless (buffer-file-name)
    (user-error "Racket scratch must visit a file"))
  (racket-run)
  (message "Racket REPL starting; C-c C-z switches to it"))

(defun racket-scratch-switch-to-repl ()
  "Switch to the REPL associated with this scratch buffer."
  (interactive)
  (racket-edit-switch-to-repl))

(defun racket-scratch-eval-print-last-sexp ()
  "Evaluate the preceding sexp and insert its value, like *scratch* C-j."
  (interactive)
  (require 'racket-repl)
  (unless (racket--repl-session-id)
    (user-error "No Racket REPL; run the scratch first (C-c C-c)"))
  (setq racket-scratch--inline-eval-p t)
  (condition-case err
      (racket-eval-last-sexp)
    (error
     (setq racket-scratch--inline-eval-p nil)
     (signal (car err) (cdr err)))))

(defvar racket-scratch-import-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "f") #'racket-scratch-import-file)
    (define-key map (kbd "m") #'racket-scratch-import-module)
    map)
  "Keymap for importing modules into a Racket scratch.")

(defvar racket-scratch-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") #'racket-scratch-run)
    (define-key map (kbd "C-c C-r") #'racket-send-region)
    (define-key map (kbd "C-c C-z") #'racket-scratch-switch-to-repl)
    (define-key map (kbd "C-c C-i") racket-scratch-import-map)
    (define-key map (kbd "C-j") #'racket-scratch-eval-print-last-sexp)
    map)
  "Keymap for `racket-scratch-mode'.")

(define-minor-mode racket-scratch-mode
  "Minor mode for a generic DrRacket-like Racket scratch."
  :lighter " RScratch"
  :keymap racket-scratch-mode-map
  (when racket-scratch-mode
    (require 'racket-show)
    (setq-local racket-show-functions '(racket-scratch--show))))

;;;###autoload
(defun racket-scratch (&optional lang)
  "Create a new interactive Racket scratch session.

With a prefix argument, prompt for an arbitrary #lang.  The scratch
is file-backed and has its own REPL.  Import project code with
`racket-scratch-import-file' or `racket-scratch-import-module'."
  (interactive
   (list (if current-prefix-arg
             (read-string "Racket #lang: " racket-scratch-lang)
           racket-scratch-lang)))
  (require 'racket-mode)
  (require 'racket-show)
  (let* ((file (racket-scratch--new-file lang))
         (buffer (find-file-noselect file)))
    (with-current-buffer buffer
      (unless (derived-mode-p 'racket-mode)
        (racket-mode))
      (rename-buffer (generate-new-buffer-name "*Racket Scratch*") t)
      (setq-local racket-repl-buffer-name
                  (generate-new-buffer-name "*Racket Scratch REPL*"))
      (racket-scratch-mode 1))
    (pop-to-buffer buffer)
    (when racket-scratch-auto-start
      (racket-scratch-run))
    buffer))

(provide 'config-racket)
;;; config-racket.el ends here
