;;; config-terminal.el --- Vterm terminal configuration -*- lexical-binding: t -*-
(defvar vterm--counter 0 "Counter for naming vterm buffers.")

(defun vterm-create ()
  "Create a new vterm buffer with an auto-incremented name."
  (interactive)
  (setq vterm--counter (1+ vterm--counter))
  (let ((buf (generate-new-buffer (format "vterm<%d>" vterm--counter))))
    (with-current-buffer buf
      (vterm-mode))
    (switch-to-buffer buf)))

(defun vterm-quit ()
  "Kill the current vterm buffer and its process."
  (interactive)
  (when (eq major-mode 'vterm-mode)
    (let ((proc (get-buffer-process (current-buffer))))
      (when proc (delete-process proc)))
    (kill-buffer)))

(use-package vterm :ensure t
  :bind ("C-x T" . vterm-create)
  :bind (:map vterm-mode-map
         ("C-c C-q" . vterm-quit))
  :hook (vterm-mode . (lambda () (message "vterm<%d> ready" vterm--counter)))
  :custom
  (vterm-max-scrollback 10000)
  (vterm-kill-buffer-on-exit t))

(provide 'config-terminal)
