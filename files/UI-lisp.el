(use-package all-the-icons :ensure t
  :if (display-graphic-p))
(use-package dracula-theme :ensure t
  :config
  (load-theme 'dracula t))
(use-package dashboard :ensure t :after all-the-icons
  :init
  (dashboard-setup-startup-hook)
  :custom
  (dashboard-set-navigator t)
  (dashboard-icon-type 'all-the-icons)
  (dashboard-items '((recents . 5) (bookmarks . 5) (agenda . 10)))
  :bind
  (("C-c d" . dashboard-open)
   :map dashboard-mode-map
   ("O" . org-roam-ui-open)
))
(use-package org-superstar :ensure t :after org
  :hook
  (org-mode . org-superstar-mode)
  (org-capture-mode . org-superstar-mode))
(add-to-list 'load-path (expand-file-name "files/UI" user-emacs-directory))
(use-package hydra-face :after hydra)
(if (eq system-type 'gnu/linux)
    (require 'UI-linux)
  (require 'UI-win))
(provide 'UI-lisp)
