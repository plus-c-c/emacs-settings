(use-package all-the-icons :ensure t
  :if (display-graphic-p))

(use-package dracula-theme :ensure t
  :config
  (load-theme 'dracula t))

(use-package page-break-lines :ensure t
  :diminish page-break-lines-mode)

(use-package org-superstar :ensure t :after org
  :hook
  (org-mode . org-superstar-mode)
  (org-capture-mode . org-superstar-mode))
(add-to-list 'load-path (expand-file-name "UI/faces" emacs-config-path))
(use-package face-hydra :after hydra)
(provide 'config-theme)
