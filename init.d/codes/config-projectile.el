(defcustom projectile-ignore-path-list
  '("submodule" "site-lisp")
  "Ignored submodule path list.")
(defun projectile-ignore-path-list--function (file lis)
  (if (eq nil lis)
      nil
   (if (string-match-p (car lis) file)
       t
     (projectile-ignore-path-list--function file (cdr lis))
     ))
  )
(defun projectile-ignore-path-function (file)
  (projectile-ignore-path-list--function file projectile-ignore-path-list))

(use-package projectile
  :ensure t
  :custom
  (projectile-indexing-method 'alien)
  (projectile-git-submodule-command nil)
  (projectile-git-use-fd nil)
  (projectile-mode-line "Projectile")
  (projectile-track-known-projects-automatically t)
  (projectile-cleanup-known-projects t)
  (projectile-ignored-project-function 'projectile-ignore-path-function)
  :hook
  (prog-mode . projectile-mode)
  :bind
  ("C-c p" . projectile-hydra/body)
  :hydra
  (projectile-hydra (:color blue :hint nil)
		    "
^Projectile((x+) 4 : other window (x+) 5 : other frame)
^Find File^                         ^Buffer in Project^  ^Project Process^   ^Other
^^^^------------------------------------------------------------------------------------------------------
_f_: in the project(4|5)            _b_: switch(4|5)     _v_: vc             _E_: edit local variables for emacs
_F_: in all known projects          _k_: kill            _V_: browse dirty   _R_: regenerate tag
_a_: with different extensions(4|5) _O_: display(auto 4) _C_: configure      _j_: find tag
_g_: do what i mean(4|5)            _<left>_: previous   _c_: compile
_d_: find dir(4|5)                  _<right>_: next      _K_: package        _r_ : replace regexp in project
_e_: recent                         ^ ^                  _L_: install        _o_ : search regexp in project
^ ^                                 ^ ^                  _P_: test
^ ^                                 ^ ^                  _u_: Run
"
    ("a" projectile-find-other-file)
    ("x 4 a" projectile-find-other-file-other-window)
    ("x 5 a" projectile-find-other-file-other-frame)
    ("d" projectile-find-dir)
    ("x 4 d" projectile-find-dir-other-window)
    ("x 5 d" projectile-find-dir-other-frame)
    ("f" projectile-find-file)
    ("x 4 f" projectile-find-file-other-window)
    ("x 5 f" projectile-find-file-other-frame)
    ("g" projectile-find-file-dwim)
    ("x 4 g" projectile-find-file-dwim-other-window)
    ("x 5 g" projectile-find-file-dwim-other-frame)
    ("F" projectile-find-file-in-known-projects)
    ("e" projectile-recentf)

    ("x 4 b" projectile-switch-to-buffer-other-window)
    ("x 5 b" projectile-switch-to-buffer-other-frame)
    ("O" projectile-display-buffer)
    ("b" projectile-switch-to-buffer)
    ("k" projectile-kill-buffers)
    ("<left>" projectile-previous-project-buffer)
    ("<right>" projectile-next-project-buffer)
    ("ESC" projectile-project-buffers-other-buffer)
    ("p" projectile-switch-project)
    ("q" projectile-switch-open-project)

    ("z" projectile-cache-current-file)
    ("i" projectile-invalidate-cache)

    ("r" projectile-replace)
    ("o" projectile-multi-occur)

    ("j" projectile-find-tag)
    ("R" projectile-regenerate-tags)

    ("E" projectile-edit-dir-locals)
    ("v" projectile-vc)
    ("V" projectile-browse-dirty-projects)
    ("C" projectile-configure-project)
    ("c" projectile-compile-project)
    ("K" projectile-package-project)
    ("L" projectile-install-project)
    ("P" projectile-test-project)
    ("u" projectile-run-project)
    )
)

(use-package counsel-projectile
  :ensure t
  :after (projectile)
  :config (counsel-projectile-mode))
(provide 'config-projectile)
