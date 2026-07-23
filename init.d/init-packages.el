;;; init-packages.el --- Load packages. -*- lexical-binding: t -*-
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Bypass proxy for ELPA and localhost (GnuTLS error -110 with proxy)
;; Use "" not nil — nil means "unset" which falls back to env vars
(when (getenv "http_proxy")
  (setq url-proxy-services '(("http" . "") ("https" . ""))))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; use-package-hydra registers :hydra keyword — must load before any use-package with :hydra
(use-package hydra :ensure t)
(use-package use-package-hydra :ensure t :after hydra)
;; diminish must load synchronously: use-package-handler/:diminish checks
;; (fboundp 'diminish) at target package load time — if diminish isn't
;; loaded yet, :diminish silently does nothing.
(use-package diminish :ensure t)

;; Benchmark: manual activation only (M-x benchmark-init/activate)
(use-package benchmark-init
  :ensure t
  :defer t
  :hook (after-init . benchmark-init/deactivate))

;; Auto-update packages: defer to after startup, check interval not on every launch
(use-package auto-package-update
  :ensure t
  :defer 3
  :custom
  (auto-package-update-delete-old-versions t)
  (auto-package-update-interval 4)
  :config
  (auto-package-update-maybe))

(provide 'init-packages)
