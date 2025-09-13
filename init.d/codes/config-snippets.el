(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :after markdown-mode
  :init
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)
(provide 'config-snippets)
