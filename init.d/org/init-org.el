;;; init-org.el --- Org-mode configuration -*- lexical-binding: t -*-
(defcustom note-directory
  (expand-directory-name-auto-create
   "notes" "~/.emacs.d/")
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
(use-package org
  :hook
  (org-mode . (lambda () (let ((inhibit-message t)) (toggle-truncate-lines -1))))
  :custom
  (org-directory (expand-directory-name-auto-create
      "org-notes"
      note-directory))
  (org-modules nil)
  (org-image-actual-width '(1024 512 256))
  :config
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 2.5))
  (add-to-list 'org-file-apps '("\\.pdf\\'" . eaf-org-open-file))
  (add-to-list 'org-file-apps '("\\.x?html?\\'" . eaf-org-open-file)))
(require 'config-display)
(require 'config-org-export)
(use-package init-agenda
  :after (org projectile)
  :defer 0.5
  :hydra
  (org-agenda-hydra (:color blue :hint nil)
        "
 ^Agenda^
^^^^^^^──────────────────────
 _a_ Open Agenda    _t_ Set Todo
 _s_ Set Schedule   _,_ Set Priority
 _d_ Set Deadline
"
        ("a" org-agenda)
        ("s" org-schedule)
        ("d" org-deadline)
        ("t" org-todo)
        ("," org-priority))
  :config
  (global-set-key (kbd "C-c a") 'org-agenda)
  (define-key org-mode-map (kbd "C-c a") 'org-agenda-hydra/body))
;; Heavy reference/roam packages: defer until after startup
(use-package init-ref
  :after org
  :defer 1.0)
(use-package init-roam
  :after org
  :defer 1.5)
(require 'config-interleave)
(provide 'init-org)
