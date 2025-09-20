(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :after markdown-mode
  :init
  (yas-global-mode 1)
  :config
  (define-key yas-minor-mode-map [(tab)]        nil)
  (define-key yas-minor-mode-map (kbd "TAB")    nil)
  (define-key yas-minor-mode-map (kbd "<tab>")  nil)
  :bind
  (:map yas-minor-mode-map ("S-<tab>" . yas-expand))
  )

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)
(provide 'config-snippets)
