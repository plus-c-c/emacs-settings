(add-to-list 'load-path (expand-file-name "site-lisp/emacs-application-framework" user-emacs-directory))

(defun eaf-interleave-open-notes-file-auto-create () "Auto create version for eaf-interleave-open-notes-file"
       (interactive)
       (progn (get-file-auto-create
	       interleave-path
	       (concat (file-name-base eaf--buffer-url) ".org"))
	      (eaf-interleave-open-notes-file)))

(defun eaf-interleave-add-note-auto-create () "Auto create version for eaf-interleave-open-notes-file"
       (interactive)
       (progn
	 (eaf-interleave-open-notes-file-auto-create)
	 (let ((buffer-org (concat (file-name-base eaf--buffer-url) ".org"))
	       (buffer-app (eaf-interleave--find-buffer eaf--buffer-url))
	       (page (number-to-string (eaf-interleave--pdf-viewer-current-page eaf--buffer-url))))
	   (switch-to-buffer buffer-org)
	   (let ((pos (point-max)))
	     (switch-to-buffer buffer-app)
	     (eaf-interleave-add-note)
	     (switch-to-buffer buffer-org)
	     (unless  (>= pos (- (point-max) 1))
		     (progn
		       (search-backward ":PROPERTIES:")
		       (previous-line)
		       (if (eq (point) (point-min))
			   (insert "#+filetags: :interleave:\n#+title: "
				   (read-string "Global Title: " (file-name-base eaf--buffer-url)) "\n"
				   ))
		       (kill-whole-line)
		       (insert "* "
			       (read-string "Interleave Title: " (concat "Notes for Page " page " of " (org-get-title) ))
			       "\n")
		       (org-id-get-create)
		       (org-fold-hide-drawer-toggle)
		       (next-line)
		       )
		     )
	   )))
       )

(use-package eaf-interleave
  :after (org-roam eaf)
  :defer 0.5
  :custom
  (eaf-interleave-org-notes-dir-list (cons interleave-path nil))
  (eaf-interleave-split-direction 'vertical)
  (eaf-interleave-disable-narrowing t)
  (eaf-interleave-split-lines 20)
  :hook
  ((org-mode . eaf-interleave-mode)
   (eaf-browser . eaf-interleave-app-mode)
   (eaf-pdf-viewer . eaf-interleave-app-mode))
  :bind ( :map eaf-interleave-mode-map
	  ("s-i" . eaf-interleave-hydra/body)
	  ("M-." . eaf-interleave-sync-current-note)
	  ("M-p" . eaf-interleave-sync-previous-note)
	  ("M-n" . eaf-interleave-sync-next-note)
	  :map eaf-interleave-app-mode-map
	  ("s-i" . eaf-interleave-app-hydra/body)
	  ("C-c M-a" . eaf-interleave-add-note-auto-create)
	  ("C-c M-o" . eaf-interleave-open-notes-file-auto-create)
	  ("C-c M-q" . eaf-interleave-quit))
  :hydra
  (eaf-interleave-app-hydra (:color blue :hint nil)
			    "Interleave Option:"
			    ("a" eaf-interleave-add-note-auto-create "Add Note(C-c M-a)")
			    ("o" eaf-interleave-open-notes-file-auto-create "Start Interleave Mode(C-c M-o)")
			    ("q" eaf-interleave-quit "Quit Interleave Mode(C-c M-q)")
			    ("c" nil "cancel"))
  (eaf-interleave-hydra (:color blue :hint nil)
			"Interleave Option:"
			("." eaf-interleave-sync-current-note "Sync Current Note(M-.)")
			("p" eaf-interleave-sync-previous-note "Sync Previous Note(M-p)")
			("n" eaf-interleave-sync-next-note "Sync Next Note(M-n)"))
  )

(provide 'config-interleave)
