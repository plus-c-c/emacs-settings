;;; config-treemacs.el --- Treemacs file explorer -*- lexical-binding: t; -*-

(use-package treemacs
  :ensure t
  :defer t
  :custom
  (treemacs-width 30)
  (treemacs-is-never-other-window t)
  (treemacs-no-png-images nil)
  (treemacs-indentation 2)
  :config
  (treemacs-tag-follow-mode)
  (treemacs-follow-mode)

  ;; Projectile integration
  (use-package treemacs-projectile
    :ensure t
    :after projectile)

  ;; Dape breakpoint indicators in treemacs
  (use-package dape
    :ensure t
    :after dape
    :config
    (advice-add 'dape-breakpoint-toggle :after
                (lambda (&rest _) (when (get-buffer "*treemacs*") (treemacs))))
    (advice-add 'dape-breakpoint-remove-all :after
                (lambda (&rest _) (when (get-buffer "*treemacs*") (treemacs)))))

  :bind
  (:map global-map
        ("C-x t" . treemacs-hydra/body))
  (:map treemacs-mode-map
        ("/" . treemacs-advanced-helpful-hydra)
        ("?" . treemacs-common-helpful-hydra))
  :hydra
  (treemacs-hydra (:color blue :hint nil)
        "
 ^Treemacs^
^^^^^^^──────────────────────────────────────
 _t_ Start     _p_ Import      _f_ Find File
 _q_ Quit      _o_ Window      _T_ Find Tag
               ^ ^             TAB/Shift-TAB Navigate

 ^Project^               ^Bookmarks^
^^^^^^^──────────────────────────────────────
_P_ Switch Proj         _B_ Set Bookmark
_R_ Refresh             _D_ Remove Bookmark
_I_ Rename
_X_ Remove
"
        ("t" treemacs)
        ("q" treemacs-quit)
        ("p" treemacs-projectile)
        ("o" treemacs-select-window)
        ("f" treemacs-find-file)
        ("T" treemacs-find-tag)
        ("P" projectile-switch-project)
        ("R" treemacs-refresh)
        ("I" treemacs-rename-projectile-project)
        ("X" treemacs-remove-project-from-workspace)
        ("B" treemacs-bookmark)
        ("D" treemacs-delete-bookmark)))

(provide 'config-treemacs)
;;; config-treemacs.el ends here
