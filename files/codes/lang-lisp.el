(use-package markdown-mode
  :custom
  (markdown-command "pandoc -f markdown -t html")
  :ensure t
  :defer t)
(use-package typescript-mode
  :ensure t
  :defer t)
(use-package racket-mode
  :ensure t
  :config
  (add-to-list 'language-modes-list 'racket-mode)
  :defer t
  :mode ("\\.rktl\\'" . racket-mode)
  )
(setq lsp-bridge-python-lsp-server 'pylsp)
(use-package python-mode
  :ensure t
  :defer t)
(use-package jtsx
  :ensure t
  :mode (("\\.jsx\\'" . jtsx-js-mode)
	 ("\\.tsx\\'" . jtsx-tsx-mode))
  :defer t)
(diminish 'eldoc-mode)
(provide 'lang-lisp)
