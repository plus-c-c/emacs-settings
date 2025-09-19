(add-to-list 'load-path (expand-file-name "notes" emacs-config-path))

(defcustom note-directory
  (expand-directory-name-auto-create
   ""
   (if (eq system-type 'gnu/linux)
       "~/Documents/emacs/"
     "D:/emacs/"))
  "The directory of my notes.")
(defcustom bibliography-directory
  (expand-directory-name-auto-create
   "bibliography"
   note-directory)
  "The directory of bibliography.")
(defcustom interleave-path
  (expand-directory-name-auto-create
   "interleave"
   bibliography-directory)
  "The directory of interleave")
(add-to-list 'safe-local-variable-values '(eval add-hook 'after-save-hook 'org-mobile-push-if-connected nil t))
(use-package org
  :defer 0.5
  :hook
  (org-mode . (lambda () (toggle-truncate-lines -1)))
  :custom
  (org-directory (expand-directory-name-auto-create
		  "org-notes"
		  note-directory))
  :config
  (defun eaf-org-open-file (file &optional link) "An wrapper function on eaf-(or )pen."
	 (eaf-open file))
  (add-to-list 'org-file-apps '("\\.pdf\\'" . eaf-org-open-file))
  (add-to-list 'org-file-apps '("\\.x?html?\\'" . eaf-org-open-file))
  )

(require 'org-export-lisp)
(use-package init-mobile
  :after org)
(use-package init-agenda
  :after (org projectile)
  :hydra
  (org-agenda-hydra (:color blue :hint nil)
		    "
Agenda Options:
_a_: Open Agenda view
_s_: Insert Schedule (C-c C-s)
_d_: Insert Deadline (C-c C-d)
_t_: Insert Todo (C-c C-t)
_,_: Insert Priority (C-c C-,)
"
		    ("a" org-agenda)
		    ("s" org-schedule)
		    ("d" org-deadline)
		    ("t" org-todo)
		    ("," org-priority)
		    )
 ; :bind
 ; ("C-c a" . org-agenda)
 ; :bind
 ; (:map org-mode-map
;	("C-c C-a" . org-agenda-hydra/body))
  :config
  (global-set-key (kbd "C-c a") 'org-agenda)
  (define-key org-mode-map (kbd "C-c a") 'org-agenda-hydra/body)
  )
(use-package init-ref  :defer 0.5  :after org)
(use-package init-roam
  :defer 0.5
  :after org)
(require 'config-interleave)
(provide 'init-notes)
