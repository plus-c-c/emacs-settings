;;; config-eaf.el --- Emacs Application Framework configuration -*- lexical-binding: t -*-

(add-to-list 'load-path (expand-file-name "site-lisp/emacs-application-framework" user-emacs-directory))

(global-set-key (kbd "C-c w") 'browse-web)

(use-package eaf :diminish eaf-mode
  :custom
  (eaf-find-alternate-file-in-dired t)
  (eaf-webengine-download-path "~/Downloads")
  :init
  ;; In daemon mode, EAF cannot start immediately — eaf-get-render-size
  ;; requires a live frame. Defer startup to server-after-make-frame-hook.
  (when (daemonp)
    (setq eaf-start-python-process-when-require nil))

  ;; Detect Hyprland via hyprctl presence (XDG_CURRENT_DESKTOP is not available
  ;; in systemd user service). Must be set before EAF loads so defvar picks it up.
  (when (executable-find "hyprctl")
    (setq eaf-wm-name "wlroots wm"
          eaf-is-member-of-focus-fix-wms t))

  :config
  ;; Daemon mode: start EAF after the first frame is fully created.
  ;; - Always update eaf-emacs-frame so eaf-monitor-configuration-change
  ;;   can match (equal (window-frame) eaf-emacs-frame) on new frames.
  ;; - Use eaf-epc-live-p to detect if EAF needs (re)starting,
  ;;   instead of a one-shot flag that never resets after process death.
  (when (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (setq eaf-emacs-frame frame)
                (unless (and (boundp 'eaf-epc-process)
                             (eaf-epc-live-p eaf-epc-process))
                  (run-with-timer 1 nil
                    (lambda ()
                      (eaf-start-process)
                      (require 'eaf-browser)
                      (require 'eaf-pdf-viewer)))))))
  ;; Hyprland: Fix first-window focus by using hyprctl to explicitly refocus
  ;; after EAF creates a new buffer. The default focus-change handler relies on
  ;; after-focus-change-function timing which is unreliable on first QT window creation.
  ;; Note: HYPRLAND_INSTANCE_SIGNATURE is not in systemd daemon env, so we
  ;; discover it dynamically from the XDG_RUNTIME_DIR hypr socket directory.
  (when (and (eq system-type 'gnu/linux) (executable-find "hyprctl"))
    (defun eaf-hyprland-instance-sig ()
      "Find the Hyprland instance signature from the runtime socket directory."
      (let ((runtime (or (getenv "XDG_RUNTIME_DIR")
                         (format "/run/user/%d" (user-uid)))))
        (let ((hypr-dir (expand-file-name "hypr" runtime)))
          (when (file-directory-p hypr-dir)
            (let ((entries (directory-files hypr-dir nil "\\`[^.]" t)))
              (car entries))))))

    (defun eaf-hyprland-fix-first-focus ()
      "Ensure Emacs regains focus after creating a new EAF QT window on Hyprland.
This works around the race condition where the first QT window steals focus
before the focus-change handler can properly route it."
      (run-with-timer 0.3 nil
        (lambda ()
          (when-let* ((sig (eaf-hyprland-instance-sig)))
            (let ((hyprctl (format "HYPRLAND_INSTANCE_SIGNATURE=%s hyprctl" sig)))
              (shell-command-to-string (format "%s dispatch focuswindow pid:%d" hyprctl (emacs-pid)))))
          (when (eaf-epc-live-p eaf-epc-process)
            ;; Force show all visible EAF buffers
            (dolist (window (window-list (selected-frame)))
              (with-current-buffer (window-buffer window)
                (when (derived-mode-p 'eaf-mode)
                  (eaf-call-async "show_buffer_view" eaf--buffer-id))))))))

    (advice-add 'eaf--open-new-buffer :after
                (lambda (&rest _)
                  (eaf-hyprland-fix-first-focus))))
  )

(defun eaf-org-open-file (file &optional link) "An wrapper function on eaf-(or )pen."
       (eaf-open file))
(use-package eaf-browser :after eaf
  :custom
  (eaf-proxy-port "7890")
  (eaf-proxy-type "http")
  (eaf-proxy-host "127.0.0.1")
  (browse-url-browser-function 'eaf-open-browser)
  (eaf-browser-enable-adblocker nil)
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-chrome-browser-name "Chromium")
  (eaf-chrome-bookmark-file "~/.config/chromium/Default/Bookmarks")
  (eaf-browser-chrome-history-file "~/.config/chromium/Default/History")
  (eaf-browser-blank-page-url "https://zjuers.com")
  (eaf-webengine-default-zoom "1.0")
  (eaf-webengine-font-size 20)
  (eaf-webengine-fixed-font-size 20)
  (eaf-webengine-fixed-font-family "WenQuanyi Micro Hei Mono")
  (eaf-webengine-font-family "WenQuanYi Micro Hei Mono")
  (eaf-browser-extension-list
   '("html" "htm"))
  :config
  (if (eq system-type 'gnu/linux)
      (setq eaf-browser-auto-import-chrome-cookies t)
    nil
    )
  (defalias 'browse-web #'eaf-open-browser)
  )

(use-package eaf-pdf-viewer :after eaf
  :custom (eaf-pdf-dark-mode nil)
  )

(use-package eaf-all-the-icons  :after all-the-icons)

(if (eq system-type 'gnu/linux)
    (use-package eaf-file-manager
      :after eaf))
(if (eq system-type 'gnu/linux)
    (use-package eaf-file-browser
      :after eaf))
(use-package eaf-image-viewer :after eaf)
(use-package eaf-video-player :after eaf)

(use-package eaf-video-editor :after eaf)
(use-package eaf-music-player :after eaf)
(use-package eaf-org-previewer :after eaf)
(use-package eaf-markdown-previewer :after eaf)
(use-package eaf-file-sender :after eaf)
(use-package eaf-jupyter :after eaf)
(provide 'config-eaf)
