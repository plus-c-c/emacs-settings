(use-package dashboard :ensure t :after (all-the-icons projectile)
  :init
  (require 'config-theme)
  (load-theme 'dracula t)
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
      `(
	(;;line 1
	 (,(all-the-icons-fileicon "brain" :height 1.0 :v-adjust 0.0)
          "AI"
          "Open ellama"
          (lambda (&rest _) (ellama))
	  success)
	);;line 1 end
        (;;line 2
	 (,(all-the-icons-octicon "mark-github" :height 1.0 :v-adjust 0.0)
          "Github"
          "Browse Github"
          (lambda (&rest _) (browse-url "github.com")))
	 (,(all-the-icons-material "search" :height 1.2 :v-adjust -0.25)
          "Search"
          "Browse Search engine"
          (lambda (&rest _) (browse-url "duckduckgo.com")))
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
	 );;line 4 end
	(;;line 5
	 (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
          "NCBI"
          "Open NCBI"
          (lambda (&rest _) (browse-web "https://www.ncbi.nlm.nih.gov/#!/landingpage"))
	  link)
	 (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
          "BLAST"
          "Open BLAST"
          (lambda (&rest _) (browse-web "https://www.ncbi.nlm.nih.gov/#!/landingpage"))
	  link)
	 (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
          "UniProt"
          "Open UniProt"
          (lambda (&rest _) (browse-web "https://www.uniprot.org/"))
	  link)
	 (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
          "EMBI"
          "Open EMBI"
          (lambda (&rest _) (browse-web "https://www.ebi.ac.uk/jdispatcher/"))
	  link)
	 );;line 5 end
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
  :config
(defun dashboard-external-device-format (dev-name)
  "Format function for 'dashboard-insert-external-devices'."
  (let* ((dev-list (match-device-details-by-path
		    (if (eq system-type 'gnu/linux)
			(external-device-path dev-name)
		      dev-name)
		    (device-detailed-list))))
    (if (eq system-type 'gnu/linux)
	(format "%s : %s / %s - %s used"
		dev-name
		(nth 2 dev-list)
		(nth 3 dev-list)
		(nth 4 dev-list))
      (let* ((dev-space-part (nthcdr (- (length dev-list) 4) dev-list)))
      (format "%s : %s %s%s / %s%s left"
		dev-name
		(nth 2 dev-list)
		(car dev-space-part)
		(cadr dev-space-part)
		(caddr dev-space-part)
		(cadddr dev-space-part))
	))))

(defun dashboard-insert-external-devices (list-size)
  "Add the list of LIST-SIZE items of external devices."
  (setq dashboard--projects-cache-item-format nil)
  (dashboard-insert-section
   "Devices:"
   (dashboard-subseq (external-device-names) list-size)
   list-size
   'external-devices
   (dashboard-get-shortcut 'external-devices)
   `(lambda (&rest _)
     (find-file (external-device-path ,el)))
   (dashboard-external-device-format el)
   )
  )
(if (eq (external-device-names) nil)
    nil
  (add-to-list 'dashboard-item-generators
	       '(external-devices . dashboard-insert-external-devices))

  (add-to-list 'dashboard-items '(external-devices . 10))
  (add-to-list 'dashboard-item-shortcuts '(external-devices . "d"))
  )
  )
(provide 'config-dashboard)
