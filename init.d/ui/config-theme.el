;;; config-theme.el --- Theme and icon configuration -*- lexical-binding: t -*-

(use-package all-the-icons :ensure t

  :if (display-graphic-p))

(use-package dracula-theme :ensure t)
(load-theme 'dracula t)
;; Re-apply fonts — load-theme resets default face to tty
(cabins--font-setup)
(set-face-attribute 'default nil :height (round (* 55 emacs-hidpi-scale)))

(defun cabins-toggle-theme ()
  "Toggle between dracula (dark) and modus-operandi (light).

Re-applies the font setup because `load-theme' resets the default
face to tty.  Activates whichever theme isn't currently loaded."
  (interactive)
  (let ((next (if (eq (car custom-enabled-themes) 'modus-operandi)
                  'dracula
                'modus-operandi)))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme next t)
    (cabins--font-setup)
    (set-face-attribute 'default nil :height (round (* 55 emacs-hidpi-scale)))
    (dolist (frame (frame-list))
      (set-face-attribute 'default frame :background (face-background 'default frame))
      (frame-set-background-mode frame))
    (message "Theme: %s" next)))
(global-set-key (kbd "C-c T") #'cabins-toggle-theme)
(use-package page-break-lines :ensure t
  :diminish page-break-lines-mode)

(use-package org-superstar :ensure t :after org
  :hook
  (org-mode . org-superstar-mode)
  (org-capture-mode . org-superstar-mode))
(add-to-list 'load-path (expand-file-name "ui/faces" emacs-config-path))
(use-package face-hydra :after hydra)
(provide 'config-theme)
