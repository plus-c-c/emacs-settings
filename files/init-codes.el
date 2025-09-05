(add-to-list 'load-path (expand-file-name "codes" emacs-config-path))
(require 'config-lang-hooks)
(require 'config-treesit)
(require 'config-snippets)
(require 'lang-lisp)
(use-package treemacs
  :ensure t
  :defer t
  :config
 (treemacs-tag-follow-mode)
 (use-package treemacs-projectile :ensure t)
 :bind
 (:map global-map
       ("C-x t" . treemacs-hydra/body))
 (:map treemacs-mode-map
	("/" . treemacs-advanced-helpful-hydra)
	("?" . treemacs-common-helpful-hydra))
 :hydra
 (treemacs-hydra (:color blue :hint nil)
		 "Treemacs Basic"
		 ("t" treemacs "Start Treemacs")
		 ("q" treemacs-quit "Close Treemacs")
		 ("p" treemacs-projectile "Import Projectile")
		 ("o" treemacs-select-window "Select Window")
		 ("1" treemacs-delete-other-windows "Delete Other Windows")
		 ("B" treemacs-bookmark "Set Bookmarks")
		 ("C-t" treemacs-find-file "Find File")
		 ("M-t" treemacs-find-tag "Find Tag"))
 )

(use-package config-projectile)

(if (eq system-type 'gnu/linux)
    (require 'linux-codes)
  (require 'win-codes))
(provide 'init-codes)
