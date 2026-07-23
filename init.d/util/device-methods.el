;;; device-methods.el --- Device interface for emacs. -*- lexical-binding: t -*-
(provide 'device-methods)

(defun expand-file-name-auto-create (file env)
  "Get file directory and create a new empty file if it does not exist."
  (let ((filepath (expand-file-name file env)))
    (unless (file-exists-p filepath)
      (write-region "" nil filepath))
    filepath))

(defun expand-directory-name-auto-create (dir env)
  "Get directory and create a new empty directory if it does not exist."
  (let ((dirpath (expand-file-name dir env)))
    (unless (file-exists-p dirpath)
      (make-directory dirpath))
    (concat dirpath "/")))

(defun empty-string-filter (l)
  "Drop empty string in list."
  (cond ((eq l nil) nil)
  ((string-equal (car l) "") (empty-string-filter (cdr l)))
  (t (cons (car l) (empty-string-filter (cdr l))))))

(defun device-detailed-list ()
  "Get detailed device information for the current system."
  (cond ((eq system-type 'gnu/linux)
   (mapcar
    (lambda (x) (empty-string-filter x))
    (mapcar
     (lambda (x) (split-string x " "))
     (cdr (split-string (shell-command-to-string "df -h") "\n")))))
  ((memq system-type '(cygwin windows-nt ms-dos))
   (mapcar
    (lambda (x) (empty-string-filter x))
    (mapcar
     (lambda (x) (split-string x " "))
     (empty-string-filter
      (cdddr
       (split-string
        (shell-command-to-string "powershell -Command Get-Volume") "\n"))))))))

(defun match-device-details-by-path (path list)
  "Match device by PATH in LIST."
  (if (eq system-type 'gnu/linux)
      (cond
       ((eq list nil) nil)
       ((string-equal (car (last (car list))) path) (car list))
       (t (match-device-details-by-path path (cdr list))))
    (cond
     ((eq list nil) nil)
     ((string-equal (car (car list)) path) (car list))
     (t (match-device-details-by-path path (cdr list))))))

(defun match-device-letter-win (list)
  "Extract device letters from LIST on Windows."
  (cond
   ((eq list nil) nil)
   ((length> (car list) 9)
    (cons (car (car list))
    (match-device-letter-win (cdr list))))
   (t (match-device-letter-win (cdr list)))))

(defun external-device-names ()
  "Get names of external devices."
  (if (eq system-type 'gnu/linux)
      (if (file-exists-p (concat (expand-file-name (user-login-name) "/run/media") "/"))
    (cddr (directory-files (expand-file-name (user-login-name) "/run/media")))
  nil)
    (match-device-letter-win (device-detailed-list))))

(defun external-device-path (x)
  "Get the full path for external device X."
  (if (eq system-type 'gnu/linux)
      (expand-file-name x (expand-file-name (user-login-name) "/run/media"))
    (concat x ":/")))
