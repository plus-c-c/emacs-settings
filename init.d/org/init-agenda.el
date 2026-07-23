;;; init-agenda.el --- Agenda configuration -*- lexical-binding: t -*-
(setq org-agenda-directory
      (expand-directory-name-auto-create
       "agenda"
       org-directory))

(setq org-agenda-files
      (directory-files-recursively org-agenda-directory "\\.org$"))

(unless (file-exists-p (expand-file-name projectile-dirconfig-file org-agenda-directory))
  (with-temp-file (expand-file-name projectile-dirconfig-file org-agenda-directory)
    (insert "-/.dir-locals.el")))

(provide 'init-agenda)
