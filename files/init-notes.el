(add-to-list 'load-path (expand-file-name "notes" emacs-config-path))

(defcustom note-directory (get-directory-auto-create "" (if (eq system-type 'gnu/linux) "~/Documents/emacs/" "D:/emacs/")) "The directory of my notes.")
(defcustom bibliography-directory (get-directory-auto-create note-directory "bibliography") "The directory of bibliography.")
(defcustom interleave-path (get-directory-auto-create bibliography-directory "interleave") "The directory of interleave")

(use-package org
  :hook
  (org-mode . toggle-truncate-lines)
  )
(require 'init-ref)
(require 'init-roam)
(require 'org-export-lisp)
(if (eq system-type 'gnu/linux)
    (progn (require 'interleave-linux)
	   (defun eaf-org-open-file (file &optional link) "An wrapper function on eaf=open."
		  (eaf-open file))
	   (add-to-list 'org-file-apps '("\\.pdf\\'" . eaf-org-open-file))
	   (add-to-list 'org-file-apps '("\\.x?html?\\'" . eaf-org-open-file))
	   )
  (progn (add-to-list 'org-file-apps '("\\.pdf\\'" . emacs))
	 (add-to-list 'org-file-apps '("\\.x?html?\\'" . emacs)))
  )
(provide 'init-notes)
