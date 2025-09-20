(defun browse-url-new-tab (url)
  (tab-bar-new-tab)
  (browse-url url)
  (sleep-for 0.2)
  (tab-bar-switch-to-prev-tab)
  (tab-bar-switch-to-next-tab)
  )
(require 'recentf)
(add-to-list 'recentf-exclude "/cloud/webdav/")
(add-to-list 'recentf-exclude "/agenda/")
(add-to-list 'recentf-exclude "bookmarks")
(use-package dashboard :ensure t :after (all-the-icons config-theme)
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
  (dashboard-icon-type 'all-the-icons)
  (dashboard-items '((recents . 5)
		     (bookmarks . 3)
		     (agenda . 10)))
  (dashboard-navigator-buttons
   `(
     (;;line 1
      (,(all-the-icons-fileicon "brain" :height 1.0 :v-adjust 0.0)
       "AI"
       "Open gptel"
       (lambda (&rest _) (gptel (format "*%s*" (gptel-backend-name (default-value 'gptel-backend))) nil nil t))
       success)
      );;line 1 end

     (;;line 2
      (,(all-the-icons-octicon "mark-github" :height 1.0 :v-adjust 0.0)
       "Github"
       "Browse Github"
       (lambda (&rest _) (browse-url-new-tab "github.com")))
      (,(all-the-icons-material "search" :height 1.2 :v-adjust -0.25)
       "Search"
       "Browse Search engine"
       (lambda (&rest _) (browse-url-new-tab "duckduckgo.com")))
      );;line 2 end

     (;;line 3
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
      );;line 3 end

     (;;line 4
      (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
       "Scopus"
       "Open Scopus"
       (lambda (&rest _) (browse-url-new-tab "scopus.com"))
       link)
      (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
       "WOS"
       "Open WOS"
       (lambda (&rest _) (browse-url-new-tab "webofscience.com"))
       link)
      (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
       "PubMed"
       "Open PubMed"
       (lambda (&rest _) (browse-url-new-tab "https://pubmed.ncbi.nlm.nih.gov/"))
       link)
      );;line 4 end

     (;;line 5
      (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
       "NCBI"
       "Open NCBI"
       (lambda (&rest _) (browse-url-new-tab "https://www.ncbi.nlm.nih.gov/#!/landingpage"))
       link)
      (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
       "BLAST"
       "Open BLAST"
       (lambda (&rest _) (browse-url-new-tab "https://www.ncbi.nlm.nih.gov/#!/landingpage"))
       link)
      (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
       "UniProt"
       "Open UniProt"
       (lambda (&rest _) (browse-url-new-tab "https://www.uniprot.org/"))
       link)
      (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
       "EMBI"
       "Open EMBI"
       (lambda (&rest _) (browse-url-new-tab "https://www.ebi.ac.uk/jdispatcher/"))
       link)
      );;line 5 end
     ))

  :bind
  (("C-c d" . dashboard-open)
   :map dashboard-mode-map
   ("O" . org-roam-ui-open))
  )
(defun dashboard-refresh ()
  "Refresh dashboard."
  (if (string-equal (buffer-name) "*dashboard*")
      (dashboard-open)))
(provide 'config-dashboard)
