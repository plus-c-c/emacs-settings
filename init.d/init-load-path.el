;;; init-load-path.el --- Load all config modules -*- lexical-binding: t -*-
;; Load path setup
(add-to-list 'load-path (expand-file-name "util" emacs-config-path))

;; Synchronous: needed by everything else
(require 'init-util)
(require 'init-packages)

;; Deferred loading: non-critical modules load after startup
(add-to-list 'load-path (expand-file-name "ui" emacs-config-path))
(add-to-list 'load-path (expand-file-name "edit" emacs-config-path))
(add-to-list 'load-path (expand-file-name "app" emacs-config-path))
(add-to-list 'load-path (expand-file-name "dev" emacs-config-path))
(add-to-list 'load-path (expand-file-name "org" emacs-config-path))

;; ui must load synchronously (dashboard needs setup-startup-hook before after-init-hook)
(require 'init-ui)
(use-package init-dev :defer 0.8)
(use-package init-edit :defer 1.0)
(use-package init-app :defer 1.5)
(use-package init-org :defer 2.0)

(provide 'init-load-path)
