(setq org-latex-pdf-process '("latexmk -xelatex -shell-escape -pdf %f"))
(use-package ox-bibtex-chinese
  :after (org ox-bibtex)
  :ensure t
  :config
  (ox-bibtex-chinese-enable))
(use-package ox-latex-chinese
  :after org
  :config
  (oxlc/toggle-ox-latex-chinese t)
  )
(provide 'org-export-lisp)
