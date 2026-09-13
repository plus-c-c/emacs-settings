;;; config-theme.el --- Theme and icon configuration -*- lexical-binding: t -*-

(use-package all-the-icons :ensure t

  :if (display-graphic-p))

(use-package modus-themes :ensure t)
(load-theme 'modus-operandi t)
;; Re-apply fonts — load-theme resets default face to tty
(cabins--font-setup)
(set-face-attribute 'default nil :height (round (* 55 emacs-hidpi-scale)))
(use-package page-break-lines :ensure t
  :diminish page-break-lines-mode)

(use-package org-superstar :ensure t :after org
  :hook
  (org-mode . org-superstar-mode)
  (org-capture-mode . org-superstar-mode))
(add-to-list 'load-path (expand-file-name "ui/faces" emacs-config-path))
(use-package face-hydra :after hydra)
(provide 'config-theme)
