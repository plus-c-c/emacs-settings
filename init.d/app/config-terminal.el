(use-package vterm :ensure t :defer 1.0
  :bind ("C-x T" . vterm)
  :hook (vterm-mode . (lambda () (message "Vterm mode enabled. Press C-c C-t to copy text."))))
(provide 'config-terminal)
