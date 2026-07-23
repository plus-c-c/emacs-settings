;;; config-emacs-lisp.el --- Emacs Lisp configuration -*- lexical-binding: t -*-

(diminish 'eldoc-mode)

(add-to-list 'org-babel-custom-load-languages '(emacs-lisp . t))

(add-to-list 'lisp-mode-list 'lisp-interaction-mode)
(add-to-list 'lisp-mode-list 'emacs-lisp-mode)

(set-language-protocol 'elisp 'emacs-lisp-mode-hook
           '("https://github.com/Wilfred/tree-sitter-elisp"))

(setq trusted-content :all)

(use-package flymake
  :hook (emacs-lisp-mode . flymake-mode)
  :config
  (require 'flymake-proc)
  (add-hook 'emacs-lisp-mode-hook
            (lambda ()
              (setq-local flymake-diagnostic-functions
                          '(elisp-flymake-byte-compile
                            elisp-flymake-checkdoc))
              (flymake-mode 1)))
  :bind (:map flymake-mode-map
              ("M-n" . flymake-goto-next-error)
              ("M-p" . flymake-goto-prev-error)))

(provide 'config-emacs-lisp)
