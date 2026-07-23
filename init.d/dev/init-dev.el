;;; init-dev.el --- Development tools configuration -*- lexical-binding: t; -*-
;; Language list and treesit: needed early for syntax highlighting
(use-package config-lang-list :defer 0.3)
(use-package config-treesit :defer 0.5)

;; Heavier tools: defer to after startup
(use-package config-projectile :defer 0.8)
(use-package config-lsp :defer 1.0)
(use-package config-dape :defer 1.0)
(use-package config-treemacs :defer 1.5)
(use-package config-snippets :defer 1.0)
(provide 'init-dev)
