;;; config-snippets.el --- Yasnippet configuration -*- lexical-binding: t -*-

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :config
  (yas-global-mode 1)
  (define-key yas-minor-mode-map [(tab)]   nil)
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  :bind
  (:map yas-minor-mode-map ("S-TAB" . yas-expand)))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)
(provide 'config-snippets)
