(use-package emacsql :ensure t)
(require 'attachment-lisp)

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (get-directory-auto-create note-directory "roam-notes"))
  (org-directory (get-directory-auto-create note-directory "org-notes"))
  (org-roam-dailies-directory "daily/")
  (org-roam-db-gc-threshold most-positive-fixnum)
  (org-roam-capture-templates
      '(("o" "opinion" plain
         "%?"
         :if-new (file+head "opinion/${slug}.org"
                            "#+title: ${title}\n")
         :immediate-finish t
         :unnarrowed t)
        ("r" "reference" plain "%?"
         :if-new
         (file+head "reference/${title}.org" "#+title: ${title}\n")
         :immediate-finish t
         :unnarrowed t)
        ("a" "article" plain "%?"
         :if-new
         (file+head "articles/${title}.org" "#+title: ${title}\n#+filetags: :article:\n")
         :immediate-finish t
         :unnarrowed t)))
  (org-capture-templates
   '(("t" "Tasks" entry (file+headline "tasks.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
     ("s" "Slipbox" entry  (file "inbox.org")
      "* %?\n")))
  (org-roam-node-display-template
      (concat "${type:15} ${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  :bind (("C-c n" . org-roam-hydra/body))
;  :bind-keymap
;  ("C-c n d" . org-roam-dailies-map)
  :hydra
  (org-roam-dailies-hydra (:color blue :hint nil)
			  "
^Org Dailies Command:
^View Date^           ^View Note^
_d_: Today            _f_: Next
_y_: Yesterday        _b_: Previous
_t_: Tomorrow         ^Capture Date^
_c_: Date in Calendar _n_: Today
^ ^                   _c_: Date in Calendar
"
			  ("d" org-roam-dailies-goto-today)
			  ("y" org-roam-dailies-goto-yesterday)
			  ("t" org-roam-dailies-goto-tomorrow)
			  ("c" org-roam-dailies-goto-date)
			  ("f" org-roam-dailies-goto-next-note)
			  ("b" org-roam-dailies-goto-previous-note)
			  ("n" org-roam-dailies-capture-today)
			  ("v" org-roam-dailies-capture-date)
			  )
  (org-roam-hydra (:color blue :hint nil)
		  "
^Org Note Command:
^Notes^           ^Modification^   ^Other
^^^-----------------------------------------------
_C_: Capture Org  _C-c_: Create Id _u_: Open Ui
_c_: Capture Roam _t_: Add Tag     _D_: Sync Database
_f_: Find Roam    _T_: Remove Tag  _d_: Open Dailies
_i_: Insert Roam  _I_: Import File
"
		  ("c" org-roam-capture)
		  ("C" org-capture)
		  ("f" org-roam-node-find)
		  ("i" org-roam-node-insert)
		  ("C-c" org-id-get-create)
		  ("t" org-roam-tag-add)
		  ("T" org-roam-tag-remove)
		  ("I" org-import-attachments)
		  ("u" org-roam-ui-open)
		  ("D" org-roam-db-sync)
		  ("d" org-roam-dailies-hydra/body)
		  )
  :config
  (cl-defmethod org-roam-node-type ((node org-roam-node))
  "Return the TYPE of NODE."
  (condition-case nil
      (file-name-nondirectory
       (directory-file-name
        (file-name-directory
         (file-relative-name (org-roam-node-file node) org-roam-directory))))
    (error "")))
  (get-directory-auto-create org-roam-directory "daily")
  (require 'org-roam-dailies)
  (setq org-roam-database-connector 'sqlite)
  (org-roam-db-autosync-mode))

(use-package org-roam-ui
  :ensure t
  :after org-roam
  :custom
  (org-roam-ui-sync-theme t)
  (org-roam-ui-follow t)
  (org-roam-ui-update-on-save t))
(provide 'roam-lisp)
