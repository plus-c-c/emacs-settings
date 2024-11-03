(use-package emacsql :ensure t)

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
  (org-roam-hydra (:color blue :hint nil)
		  ("c" org-roam-capture "Org Roam Capture")
		  ("C" org-capture "Org Capture")
		  ("C-c" org-id-get-create "Create Id")
		  ("f" org-roam-node-find "Find")
		  ("i" org-roam-node-insert "Insert")
		  ("u" org-roam-ui-open "Open Ui")
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
