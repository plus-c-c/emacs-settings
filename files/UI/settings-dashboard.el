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
	 )

	(
	 (,(all-the-icons-faicon "database" :height 1.1 :v-adjust -0.1)
          "Ebib"
          "Open Ebib"
          (lambda (&rest _) (ebib))
	  warning)
	 (,(all-the-icons-material "bubble_chart" :height 1.1 :v-adjust -0.2)
	  "ORUI"
	  "Show org-roam-ui page"
	  (lambda (&rest _) (org-roam-ui-open))
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
(provide 'settings-dashboard)
