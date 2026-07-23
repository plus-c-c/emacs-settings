;;; config-org-export.el --- Org LaTeX export configuration -*- lexical-binding: t -*-

(setq org-latex-pdf-process '("latexmk -xelatex -shell-escape -pdf %f"))

(use-package ox-latex-chinese
  :after org
  :defer 0.8
  :config
  (oxlc/toggle-ox-latex-chinese t)
  )
(provide 'config-org-export)
