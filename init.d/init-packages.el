(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(use-package benchmark-init
  :ensure t
  :init
  (benchmark-init/activate)
  :hook
  (after-init . benchmark-init/deactivate))
(use-package esup
  :ensure t
  :init
  (setq esup-child-profile-require-level 2)
  )
(use-package auto-package-update :ensure t
  :custom
  (auto-package-update-delete-old-versions t)
  (auto-package-update-interval 4)
  :config
  (if (network-connected-p)
      (auto-package-update-maybe)))
(use-package hydra :ensure t)
(use-package use-package-hydra :ensure t :after hydra)
(use-package diminish :ensure t)
(if (eq system-type 'gnu/linux)
    (progn (add-to-list 'load-path (expand-file-name "site-lisp/emacs-application-framework" user-emacs-directory))
	   (use-package eaf :diminish eaf-mode
	     :custom
	     (eaf-find-alternate-file-in-dired t))))
(provide 'init-packages)
