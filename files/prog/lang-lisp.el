(use-package markdown-mode
  :ensure t
  :defer t)
(use-package typescript-mode
  :ensure t
  :defer t)
(use-package racket-mode
  :ensure t
  :defer t
  :mode ("\\.rktl\\'" . racket-mode))
(use-package python-mode
  :ensure t
  :defer t)
(provide 'lang-lisp)
