;;; init-packages.el --- Load packages. -*- lexical-binding: t -*-
(require 'package)
(require 'internet-methods)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(use-package benchmark-init
  :ensure t
  :init
  (benchmark-init/activate)
  :hook
  (after-init . benchmark-init/deactivate))
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
(provide 'init-packages)
