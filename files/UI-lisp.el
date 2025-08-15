(use-package all-the-icons :ensure t
  :if (display-graphic-p))
(use-package dracula-theme :ensure t
  :config
  (load-theme 'dracula t))
(use-package page-break-lines :ensure t)
(use-package dashboard :ensure t :after (all-the-icons projectile)
  :init
  (dashboard-setup-startup-hook)
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-startupify-list '(dashboard-insert-banner
			       dashboard-insert-newline
			       dashboard-insert-banner-title
			       dashboard-insert-navigator
			       dashboard-insert-init-info
			       dashboard-insert-items
			       dashboard-insert-footer))
  (dashboard-page-separator "\f\n")
  (dashboard-center-content t)
  (dashboard-navigator-buttons
      `(;; line1
        (
	 (,(all-the-icons-octicon "mark-github" :height 1.1 :v-adjust 0.0)
          "Github"
          "Browse Github"
          (lambda (&rest _) (browse-url "github.com")))
	 (,(all-the-icons-faicon "google" :height 1.1 :v-adjust -0.1)
          "Google"
          "Browse Google"
          (lambda (&rest _) (browse-url "github.com")))
         (,(all-the-icons-material "bubble_chart" :height 1.1 :v-adjust -0.2)
	  "ORUI"
	  "Show org-roam-ui page"
	  (lambda (&rest _) (org-roam-ui-open)))
         )
	(
	 (,(all-the-icons-faicon "database" :height 1.1 :v-adjust -0.2)
          "Ebib"
          "Open Ebib"
          (lambda (&rest _) (ebib))
	  warning)
	 )
	))
  (dashboard-projects-backend 'projectile)
  (dashboard-icon-type 'all-the-icons)
  (dashboard-items '((recents . 5)
		     (projects . 3)
		     (bookmarks . 3)
		     (agenda . 10)))
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
