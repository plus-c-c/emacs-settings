;;; init-app.el --- Application configuration -*- lexical-binding: t -*-
;; Lightweight, load immediately
(require 'config-converter)
(require 'config-terminal)

;; Heavier apps: defer to after startup
(use-package config-git :defer 0.5)
(use-package config-guess-word :defer 1.0)
(use-package config-eaf :defer 1.5)
(use-package config-eaf-hydra :defer 2.0)
(use-package config-paper-import :defer 2.5)
(use-package config-opencode :defer 3.0)
(use-package config-opencode-status :defer 3.5)
(provide 'init-app)
