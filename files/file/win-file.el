(use-package super-save
  :ensure t
  :diminish super-save-mode
  :custom
  (auto-save-default nil)
  (super-save-auto-save-when-idle t)
  (super-save-silent t)
  (super-save-delete-trailing-whitespace t)
  :config
  (super-save-mode +1))
(provide 'win-file)
