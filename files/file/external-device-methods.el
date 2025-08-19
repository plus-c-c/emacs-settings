(provide 'external-device-methods)

(defun get-file-auto-create (env file)
  "Get file directory and create a new empty file if it does not exist."
       (let ((complete-dir (expand-file-name file env)))
	 (progn
	   (unless (file-exists-p complete-dir)
	     (write-region "" nil complete-dir))
	   complete-dir
	   )
	 ))

(defun get-directory-auto-create (env dir)
  "Get directory and create a new empty directory if it does not exist."
       (let ((complete-dir (expand-file-name dir env)))
	 (progn
	   (unless (file-exists-p complete-dir)
	     (make-directory complete-dir))
	   complete-dir
	   )
	 ))

(defun empty-string-filter (l)
  "Drop empty string in list."
  (cond ((eq l nil)
	 nil)
	((string-equal (car l) "")
	 (empty-string-filter (cdr l)))
	(t (cons (car l) (empty-string-filter (cdr l))))
	))

(defun device-space-list ()
  (mapcar
 (lambda (x)
   (empty-string-filter x))
 (mapcar
  (lambda (x)
    (split-string x " "))
  (cdr (split-string (shell-command-to-string "df -h") "\n")))))

(defun match-device-space (path list)
  (cond
   ((eq list nil)
    nil)
   ((string-equal (car (last (car list))) path)
    (car list))
   (t
    (match-device-space path (cdr list))))
  )

(defun external-device-names ()
  "Get names of external devices."
  (if (directory-name-p (expand-file-name (user-login-name) "/run/media"))
      (cddr (directory-files (expand-file-name (user-login-name) "/run/media")))
    nil
      )
  )

(defun external-device-path (x)
   (expand-file-name x (expand-file-name (user-login-name) "/run/media")))
