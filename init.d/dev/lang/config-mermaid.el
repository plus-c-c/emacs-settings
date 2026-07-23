;;; config-mermaid.el --- Mermaid diagram configuration -*- lexical-binding: t -*-

(use-package mermaid-mode
  :ensure t)

(use-package ob-mermaid
  :ensure t
  :custom (ob-mermaid-cli-path "mmdc"))

(add-to-list 'org-babel-custom-load-languages '(mermaid . t))
(provide 'config-mermaid)
