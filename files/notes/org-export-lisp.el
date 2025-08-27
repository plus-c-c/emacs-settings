(setq org-latex-pdf-process '("latexmk -xelatex -shell-escape -pdf %f"))
(use-package ox-bibtex-chinese
  :after (org ox-bibtex)
  :defer 0.8
  :ensure t
  :config
  (ox-bibtex-chinese-enable))
(use-package ox-latex-chinese
  :after org
  :defer 0.8
  :config
  (oxlc/toggle-ox-latex-chinese t)
  )
(provide 'org-export-lisp)
