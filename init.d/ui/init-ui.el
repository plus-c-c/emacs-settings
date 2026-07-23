;;; init-ui.el --- UI configuration -*- lexical-binding: t -*-
;; Splash screen must load before dashboard (window-setup-hook < after-init-hook)
(require 'config-loading)
;; Fonts must load before theme — load-theme resets default face to tty
(require 'config-fonts)
;; Theme loads fast, keep synchronous for immediate visual feedback
(require 'config-theme)
;; Dashboard must load synchronously so setup-startup-hook registers before after-init-hook fires
(require 'config-dashboard)
(require 'config-dashboard-footer)
(use-package config-buffer :defer 0.5)
(use-package config-device-dashboard :after dashboard :defer 0.5)
(use-package config-frame :defer 0.5)
(provide 'init-ui)
