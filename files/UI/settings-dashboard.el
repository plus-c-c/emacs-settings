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
	 (,(all-the-icons-octicon "mark-github" :height 1.0 :v-adjust 0.0)
          "Github"
          "Browse Github"
          (lambda (&rest _) (browse-url "github.com")))
	 (,(all-the-icons-material "search" :height 1.2 :v-adjust -0.25)
          "Search"
          "Browse Search engine"
          (lambda (&rest _) (browse-url "duckduckgo.com")))
	 )

	(
	 (,(all-the-icons-faicon "database" :height 1.0 :v-adjust -0.1)
          "Ebib"
          "Open Ebib"
          (lambda (&rest _) (ebib))
	  warning)
	 (,(all-the-icons-faicon "calendar" :height 1.0 :v-adjust -0.1)
          "Agenda"
          "Open Agenda"
          (lambda (&rest _) (projectile-switch-project-by-name org-agenda-directory))
	  warning)
	 (,(all-the-icons-material "bubble_chart" :height 1.2 :v-adjust -0.25)
	  "ORUI"
	  "Show org-roam-ui page"
	  (lambda (&rest _) (org-roam-ui-open))
	  warning)
	)
	(
	 (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
          "Scopus"
          "Open Scopus"
          (lambda (&rest _) (browse-web "scopus.com"))
	  link)
	 (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
          "WOS"
          "Open WOS"
          (lambda (&rest _) (browse-web "webofscience.com"))
	  link)
	 (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
          "PubMed"
          "Open PubMed"
          (lambda (&rest _) (browse-web "https://pubmed.ncbi.nlm.nih.gov/"))
	  link)
	 )
	(
	 (,(all-the-icons-fileicon "brain" :height 1.0 :v-adjust 0.0)
          "AI"
          "Open ellama"
          (lambda (&rest _) (ellama))
	  success)
	)
	))
  (dashboard-projects-backend 'projectile)
  (dashboard-icon-type 'all-the-icons)
  (dashboard-items '((recents . 5)
		     (projects . 10)
		     (bookmarks . 3)
		     (agenda . 10)))
  :bind
  (("C-c d" . dashboard-open)
   :map dashboard-mode-map
   ("O" . org-roam-ui-open))
  )
(provide 'settings-dashboard)
