;;; config-dashboard.el --- Initial buffer for emacs. -*- lexical-binding: t -*-
(require 'recentf)
(add-to-list 'recentf-exclude "/cloud/webdav/")
(add-to-list 'recentf-exclude "/agenda/")
(add-to-list 'recentf-exclude "bookmarks")

(defvar dashboard-refresh--timer nil "Timer for debounced dashboard refresh.")
(defvar dashboard-refresh--pending nil "Non-nil if a refresh is pending.")

(defun dashboard-refresh ()
  "Refresh dashboard with debounce to avoid rapid successive re-renders."
  (when (get-buffer "*dashboard*")
    (setq dashboard-refresh--pending t)
    (when (timerp dashboard-refresh--timer)
      (cancel-timer dashboard-refresh--timer))
    (setq dashboard-refresh--timer
          (run-with-timer 0.5 nil
            (lambda ()
              (when (and dashboard-refresh--pending
                         (get-buffer "*dashboard*"))
                (setq dashboard-refresh--pending nil)
                (let ((inhibit-message t))
                  (dashboard-open))))))))

(defun dashboard-refresh-now ()
  "Refresh dashboard immediately (no debounce)."
  (when (get-buffer "*dashboard*")
    (dashboard-open)))

(use-package dashboard :ensure t
  :init
  (require 'all-the-icons)
  (dashboard-setup-startup-hook)
  :config
  (defun config-dashboard--initial-buffer ()
    "Return the dashboard buffer as the initial buffer for emacsclient."
    (let ((buf (get-buffer "*dashboard*")))
      (unless buf
        (dashboard-open)
        (setq buf (get-buffer "*dashboard*")))
      buf))
  (setq initial-buffer-choice #'config-dashboard--initial-buffer)
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
         (bookmarks . 3)))
  (dashboard-navigator-buttons
   `(
     (;;line 1
      (,(all-the-icons-fileicon "brain" :height 1.0 :v-adjust 0.0)
       "AI"
       "Open gptel"
       (lambda (&rest _) (gptel (format "*%s*" (gptel-backend-name (default-value 'gptel-backend))) nil nil t))
       success)
      (,(all-the-icons-octicon "book" :height 1.0 :v-adjust 0.0)
       "Guess"
       "Open guess-word game"
       (lambda (&rest _) (guess-word))
       success))
     (;;line 2
       (,(all-the-icons-octicon "mark-github" :height 1.0 :v-adjust 0.0)
        "Github"
        "Browse Github"
        (lambda (&rest _) (browse-url "github.com")))
       (,(all-the-icons-material "search" :height 1.2 :v-adjust -0.25)
        "Search"
        "Browse Search engine"
        (lambda (&rest _) (browse-url "https://duckduckgo.com"))))
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
       warning))
     (;;line 4
      (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
       "Scopus" "Open Scopus"
       (lambda (&rest _) (browse-url "scopus.com")) link)
      (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
       "WOS" "Open WOS"
       (lambda (&rest _) (browse-url "webofscience.com")) link)
      (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
       "PubMed" "Open PubMed"
       (lambda (&rest _) (browse-url "https://pubmed.ncbi.nlm.nih.gov/")) link))
      (;;line 5
       (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
        "NCBI" "Open NCBI"
        (lambda (&rest _) (browse-url "https://www.ncbi.nlm.nih.gov/#!/landingpage")) link)
       (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
        "BLAST" "Open BLAST"
        (lambda (&rest _) (browse-url "https://www.ncbi.nlm.nih.gov/#!/landingpage")) link)
       (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
        "UniProt" "Open UniProt"
        (lambda (&rest _) (browse-url "https://www.uniprot.org/")) link)
       (,(all-the-icons-fileicon "netlogo" :height 1.0 :v-adjust 0.0)
        "EMBI" "Open EMBI"
        (lambda (&rest _) (browse-url "https://www.ebi.ac.uk/jdispatcher/")) link))))
  :bind
  ("C-c m" . dashboard-open))

(provide 'config-dashboard)
