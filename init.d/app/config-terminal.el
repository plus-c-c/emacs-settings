(use-package vterm :ensure t
  :bind ("C-x T" . vterm)
  :hook (vterm-mode . (lambda () (message "Vterm mode enabled. Press C-c C-t to copy text."))))
(provide 'config-terminal)
