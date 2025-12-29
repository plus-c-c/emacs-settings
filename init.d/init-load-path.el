(add-to-list 'load-path (expand-file-name "file" emacs-config-path))
(require 'init-file)

(require 'init-packages)

(add-to-list 'load-path (expand-file-name "UI" emacs-config-path))
(require 'init-UI)

(add-to-list 'load-path (expand-file-name "edit" emacs-config-path))
(use-package init-edit :defer 0.5)

(add-to-list 'load-path (expand-file-name "app" emacs-config-path))
(use-package init-app :defer 1.0)

(add-to-list 'load-path (expand-file-name "codes" emacs-config-path))
(use-package init-codes :defer 0.5)

(add-to-list 'load-path (expand-file-name "notes" emacs-config-path))
(use-package init-notes :defer 1.0)

(provide 'init-load-path)
