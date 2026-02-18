(require 'org-mobile)
(if (eq system-type 'gnu/linux)
    (setq org-mobile-directory (expand-directory-name-auto-create "mobile/org" "/cloud/webdav"))
  (setq org-mobile-directory  "z:/mobile/org"))
(if (eq system-type 'windows-nt)
    (setq org-mobile-checksum-binary "z:/mobile/shasum.ps1") nil)
(setq org-agenda-mobile-directory
      (expand-directory-name-auto-create
       "agenda"
       org-mobile-directory
       ))

(setq org-mobile-inbox-for-pull
       (expand-file-name-auto-create
	"agenda/temp.org"
	org-directory
	))

(defun org-mobile-write-orgzlyignore ()
  "Write .orgzlyignore file."
  (let ((sumfile (expand-file-name ".orgzlyignore" org-mobile-directory))
	(files '("index.org" "agendas.org"))
	entry file)
    (with-temp-file sumfile
      (set-buffer-file-coding-system 'utf-8-unix nil)
      (while (setq entry (pop files))
	(setq file entry)
	(insert (format "%s\n" file))))))

(if (file-exists-p (expand-file-name ".orgzlyignore" org-mobile-directory))
    nil
  (org-mobile-write-orgzlyignore))

(defun org-agenda-reload ()
  "Reload org-agenda to avoid error \"Selecting deleted buffer.\""
  (org-agenda-list)
  (org-agenda-exit)
  )
(defun org-mobile-push-if-connected ()
  (if (network-connected-p) (org-mobile-push)))
(defun org-mobile-pull-if-connected ()
  (if (network-connected-p) (org-mobile-pull)))
(org-mobile-pull-if-connected)
(org-mobile-push-if-connected)
(org-agenda-reload)
(add-to-list 'dashboard-items '(agenda . 10) -3)
(dashboard-refresh)
(provide 'init-mobile)
