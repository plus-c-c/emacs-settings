(setq org-agenda-directory
      (expand-directory-name-auto-create
       "agenda"
       org-directory
       ))

(setq org-agenda-files
      (directory-files-recursively org-agenda-directory "\\.org$"))

;(setq org-mobile-capture-file "agenda/mobileorg.org")

(if (file-exists-p (expand-file-name dir-locals-file org-agenda-directory))
    nil
  (with-temp-file (expand-file-name dir-locals-file org-agenda-directory)
    (insert "((org-mode (eval add-hook 'after-save-hook 'org-mobile-push-if-connected nil t)))")
    ))

(if (file-exists-p (expand-file-name projectile-dirconfig-file org-agenda-directory))
    nil
  (with-temp-file (expand-file-name projectile-dirconfig-file org-agenda-directory)
    (insert "-/.dir-locals.el")
    ))

(provide 'init-agenda)
