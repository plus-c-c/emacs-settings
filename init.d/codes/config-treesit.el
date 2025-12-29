
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install t)
  (treesit-font-lock-level 4)
  :config (global-treesit-auto-mode))

(use-package fingertip
  :load-path "~/.emacs.d/site-lisp/fingertip"
  :config
  (add-hook-list language-hooks-list 'fingertip-mode)
  (define-key fingertip-mode-map (kbd "(") 'fingertip-open-round)
  (define-key fingertip-mode-map (kbd "[") 'fingertip-open-bracket)
  (define-key fingertip-mode-map (kbd "{") 'fingertip-open-curly)
  (define-key fingertip-mode-map (kbd ")") 'fingertip-close-round)
  (define-key fingertip-mode-map (kbd "]") 'fingertip-close-bracket)
  (define-key fingertip-mode-map (kbd "}") 'fingertip-close-curly)
  (define-key fingertip-mode-map (kbd "=") 'fingertip-equal)

  (define-key fingertip-mode-map (kbd "（") 'fingertip-open-chinese-round)
  (define-key fingertip-mode-map (kbd "「") 'fingertip-open-chinese-bracket)
  (define-key fingertip-mode-map (kbd "【") 'fingertip-open-chinese-curly)
  (define-key fingertip-mode-map (kbd "）") 'fingertip-close-chinese-round)
  (define-key fingertip-mode-map (kbd "」") 'fingertip-close-chinese-bracket)
  (define-key fingertip-mode-map (kbd "】") 'fingertip-close-chinese-curly)

  (define-key fingertip-mode-map (kbd "%") 'fingertip-match-paren)
  (define-key fingertip-mode-map (kbd "\"") 'fingertip-double-quote)
  (define-key fingertip-mode-map (kbd "'") 'fingertip-single-quote)

  (define-key fingertip-mode-map (kbd "SPC") 'fingertip-space)
  (define-key fingertip-mode-map (kbd "RET") 'fingertip-newline)

  (define-key fingertip-mode-map (kbd "M-o") 'fingertip-backward-delete)
  (define-key fingertip-mode-map (kbd "C-d") 'fingertip-forward-delete)
  (define-key fingertip-mode-map (kbd "C-k") 'fingertip-kill)

  (define-key fingertip-mode-map (kbd "M-\"") 'fingertip-wrap-double-quote)
  (define-key fingertip-mode-map (kbd "M-'") 'fingertip-wrap-single-quote)
  (define-key fingertip-mode-map (kbd "M-[") 'fingertip-wrap-bracket)
  (define-key fingertip-mode-map (kbd "M-{") 'fingertip-wrap-curly)
  (define-key fingertip-mode-map (kbd "M-(") 'fingertip-wrap-round)
  (define-key fingertip-mode-map (kbd "M-)") 'fingertip-unwrap)

  (define-key fingertip-mode-map (kbd "M-p") 'fingertip-jump-right)
  (define-key fingertip-mode-map (kbd "M-n") 'fingertip-jump-left)
  (define-key fingertip-mode-map (kbd "M-:") 'fingertip-jump-out-pair-and-newline)

  (define-key fingertip-mode-map (kbd "C-M-j") 'fingertip-jump-up)

  (defun fingertip-is-lisp-mode-p ()
    (or (derived-mode-p 'lisp-mode)
	(derived-mode-p 'racket-mode)
	(derived-mode-p 'emacs-lisp-mode)
	(derived-mode-p 'lisp-interaction-mode)
	(derived-mode-p 'inferior-emacs-lisp-mode)
	(derived-mode-p 'clojure-mode)
	(derived-mode-p 'clojure-ts-mode)))
  )
(provide 'config-treesit)
