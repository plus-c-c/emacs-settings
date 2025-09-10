(provide 'external-device-methods)

(defun expand-file-name-auto-create (file env)
  "Get file directory and create a new empty file if it does not exist."
       (let ((complete-dir (expand-file-name file env)))
	 (progn
	   (unless (file-exists-p complete-dir)
	     (write-region "" nil complete-dir))
	   complete-dir
	   )
	 ))

(defun expand-directory-name-auto-create (dir env)
  "Get directory and create a new empty directory if it does not exist."
       (let ((complete-dir (expand-file-name dir env)))
	 (progn
	   (unless (file-exists-p complete-dir)
	     (make-directory complete-dir))
	   (concat complete-dir "/")
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

(defun device-detailed-list ()
  (cond ((eq system-type 'gnu/linux)
	 (mapcar
	  (lambda (x)
	    (empty-string-filter x))
	  (mapcar
	   (lambda (x)
	     (split-string x " "))
	   (cdr (split-string (shell-command-to-string "df -h") "\n")))))
	((memq system-type '(cygwin windows-nt ms-dos))
	 (mapcar
	  (lambda (x)
	    (empty-string-filter x))
	  (mapcar
	   (lambda (x)
	     (split-string x " "))
	   (empty-string-filter
	    (cdddr
	     (split-string
	      (shell-command-to-string "powershell -Command Get-Volume") "\n"))))))
	))
(defun match-device-details-by-path (path list)
  (if (eq system-type 'gnu/linux)
  (cond
   ((eq list nil)
    nil)
   ((string-equal (car (last (car list))) path)
    (car list))
   (t
    (match-device-details-by-path path (cdr list))))
    (cond
   ((eq list nil)
    nil)
   ((string-equal (car (car list)) path)
    (car list))
   (t
    (match-device-details-by-path path (cdr list))))
  ))
(defun match-device-letter-win (list)
  (cond
   ((eq list nil)
    nil)
   ((length> (car list) 9)
    (cons (car (car list))
	  (match-device-letter-win (cdr list))
	  ))
   (t
    (match-device-letter-win (cdr list))))
  )
(defun external-device-names ()
  "Get names of external devices."
  (if (eq system-type 'gnu/linux)
      (if (file-exists-p (concat (expand-file-name (user-login-name) "/run/media") "/"))
	  (cddr (directory-files (expand-file-name (user-login-name) "/run/media")))
	nil)
    (match-device-letter-win (device-detailed-list))
    )
  )
(defun external-device-path (x)
  (if (eq system-type 'gnu/linux)
  (expand-file-name x (expand-file-name (user-login-name) "/run/media"))
  (concat x ":/")
  ))

