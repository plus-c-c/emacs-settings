;;memory optimize
(setq package-enable-at-startup nil)
(setq gc-cons-threshold (* most-positive-fixnum))
;; package settings
(add-hook 'after-init-hook #'(lambda () (setq gc-cons-threshold 800000)))
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
;;GUI optimize
(setq inhibit-startup-message t)
(setq inhibit-splash-screen t)
(setq use-file-dialog nil)
(setq frame-inhibit-implied-resize t)
(setq ring-bell-function 'ignore)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;;file settings
(setq make-backup-files nil)
(global-auto-revert-mode t)
;;edit setting
(delete-selection-mode t)
(setq mouse-yank-at-point t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(setq scroll-preserve-screen-position 1)
(setq jit-lock-defer-time 0.1)
(setq kill-read-only-ok t)
(if (eq system-type 'windows-nt)
    (progn
      (set-default 'process-coding-system-alist
     '(("[pP][lL][iI][nN][kK]" gbk-dos . gbk-dos)
	("[cC][mM][dD][pP][rR][oO][xX][yY]" gbk-dos . gbk-dos)))
      (set-language-environment "UTF-8")
      (set-default-coding-systems 'utf-8)
      (set-buffer-file-coding-system 'utf-8-unix)
      (set-file-name-coding-system 'utf-8-unix)
      (set-keyboard-coding-system 'utf-8-unix)

      (set-next-selection-coding-system 'utf-8-unix)
      (set-selection-coding-system 'utf-8-unix)
      (set-clipboard-coding-system 'utf-8-unix)

      (set-terminal-coding-system 'utf-8-unix)
      (prefer-coding-system 'utf-8)
      (setq locale-coding-system 'utf-8)
      ))
(provide 'early-init)
