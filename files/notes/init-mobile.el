(require 'org-mobile)

(if (eq system-type 'gnu/linux)
    (setq org-mobile-directory (expand-directory-name-auto-create "mobile/org" "/cloud/webdav"))
  (setq org-mobile-directory (expand-directory-name-auto-create "mobile/org" "D:/emacs"))
  )

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
      (set-buffer-file-coding-system 'undecided-unix nil)
      (while (setq entry (pop files))
	(setq file entry)
	(insert (format "%s\n" file))))))

(if (file-exists-p (expand-file-name ".orgzlyignore" org-mobile-directory))
    nil
  (org-mobile-write-orgzlyignore))

(add-hook 'dashboard-after-initialize-hook 'org-mobile-push)
(add-hook 'dashboard-before-initialize-hook (lambda ()
					      (org-mobile-pull)
					      (org-agenda-list)
					      (org-agenda-exit)))




(provide 'init-mobile)
