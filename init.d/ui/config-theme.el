;;; config-theme.el --- Theme and icon configuration -*- lexical-binding: t -*-

(use-package all-the-icons :ensure t

  :if (display-graphic-p))

(use-package dracula-theme :ensure t)
(load-theme 'dracula t)
;; Re-apply fonts — load-theme resets default face to tty
(cabins--font-setup)
(set-face-attribute 'default nil :height 110)
(use-package page-break-lines :ensure t
  :diminish page-break-lines-mode)

(use-package org-superstar :ensure t :after org
  :hook
  (org-mode . org-superstar-mode)
  (org-capture-mode . org-superstar-mode))
(add-to-list 'load-path (expand-file-name "ui/faces" emacs-config-path))
(use-package face-hydra :after hydra)
(provide 'config-theme)
