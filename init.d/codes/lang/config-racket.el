(use-package racket-mode
  :ensure t
  :config
  (add-to-list 'language-modes-list 'racket-mode)
  :defer t
  :mode ("\\.rktl\\'" . racket-mode)
  )
;(add-to-list 'org-babel-custom-load-languages '(racket . t))
(add-to-list 'lisp-mode-list 'racket-mode)

(set-language-protocol 'racket 'racket-mode-hook
		       '("https://github.com/6cdh/tree-sitter-racket.git"))
(provide 'config-racket)
