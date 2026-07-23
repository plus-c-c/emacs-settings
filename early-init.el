;;; early-init.el --- Emacs early init -*- lexical-binding: t -*-
;; GC threshold: minimize GC during startup, restore after init
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'after-init-hook (lambda () (setq gc-cons-threshold (* 1024 1024))))

;; Package system: load manually after init
(setq package-enable-at-startup nil)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; GUI: suppress all visual elements before frame creation
(setq inhibit-startup-message t
      inhibit-splash-screen t
      use-file-dialog nil
      frame-inhibit-implied-resize t
      ring-bell-function 'ignore
      menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil
      horizontal-scroll-bar-mode nil
      blink-cursor-mode nil)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))

;; File handling
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      global-auto-revert-mode t)

;; Editing
(setq delete-selection-mode t
      mouse-yank-at-point t
      scroll-preserve-screen-position 1
      jit-lock-defer-time 0.1
      kill-read-only-ok t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Encoding (Windows)
(when (eq system-type 'windows-nt)
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
  (setq locale-coding-system 'utf-8))

;; Frame appearance — set font before frame creation to prevent layout shift
(add-to-list 'default-frame-alist '(font . "SauceCodePro Nerd Font"))
(add-to-list 'default-frame-alist '(background-color . "#282a36"))
(provide 'early-init)
;;; early-init.el ends here
