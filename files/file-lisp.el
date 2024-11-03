(use-package popper
  :ensure t
  :bind
  (("C-`"   . popper-toggle)
   ("M-`"   . popper-cycle)
   ("C-M-`" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode
          compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1))
(defun get-file-auto-create (env file) "Get file directory and create a new empty file if it does not exist."
       (let ((complete-dir (expand-file-name file env)))
	 (progn
	   (unless (file-exists-p complete-dir)
	     (write-region "" nil complete-dir))
	   complete-dir
	   )
	 ))

(defun get-directory-auto-create (env dir) "Get directory and create a new empty directory if it does not exist."
       (let ((complete-dir (expand-file-name dir env)))
	 (progn
	   (unless (file-exists-p complete-dir)
	     (make-directory complete-dir))
	   complete-dir
	   )
	 ))
(add-to-list 'load-path (expand-file-name "files/file" user-emacs-directory))
(if (eq system-type 'gnu/linux)
    (require 'file-linux)
  (require 'file-win)
)

(provide 'file-lisp)
