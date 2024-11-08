(defconst bibliography-directory (get-directory-auto-create note-directory "bibliography") "The directory of bibliography.")
(use-package bibtex-completion
  :defer 0.8
  :ensure ivy-bibtex)
(use-package ivy-bibtex
  :ensure t
  :defer 0.8
  :after bibtex-completion
  :init
  (setq bibtex-completion-bibliography
	(mapcar (lambda (file) (get-file-auto-create bibliography-directory file))
		'("references.bib"
		  "dei.bib"
		  "master.bib"
		  "archive.bib")
		)
	bibtex-completion-library-path
	(mapcar (lambda (dir) (get-directory-auto-create bibliography-directory dir))
		'("bibtex-pdfs")
		)
	bibtex-completion-notes-path
	(get-directory-auto-create bibliography-directory "notes")
	bibtex-completion-notes-template-multiple-files "* ${author-or-editor}, ${title}, ${journal}, (${year}) :${=type=}: \n\nSee [[cite:&${=key=}]]\n"

	bibtex-completion-additional-search-fields '(keywords)
	bibtex-completion-display-formats
	'((article       . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${journal:40}")
	  (inbook        . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
	  (incollection  . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (inproceedings . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (t             . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*}"))
	bibtex-completion-pdf-open-function
	(lambda (fpath)
	  (call-process "open" nil 0 nil fpath))))

(use-package ebib
  :ensure t
  :defer 0.8
  :after org-ref
  :bind
  (("<f5>" . ebib)
  (:map ebib-multiline-mode-map
   ("C-c C-c" . ebib-quit-multiline-buffer-and-save)
   ("C-c C-q" . ebib-cancel-multiline-buffer)
   ("C-c C-s" . ebib-save-from-multiline-buffer)))
  :custom
  (bibtex-autokey-name-case-convert-function 'capitalize)
  (bibtex-autokey-titlewords 0)
  (bibtex-autokey-year-length 4)
  (ebib-uniquify-keys t)
  (ebib-bibtex-dialect 'biblatex)
  (ebib-index-window-size 10)
  (ebib-preload-bib-files bibtex-completion-bibliography)
  (ebib-notes-directory bibtex-completion-notes-path)
  (ebib-file-search-dirs bibtex-completion-library-path)
  (ebib-reading-list-file (get-file-auto-create bibliography-directory "readinglist.org"))
  (ebib-keywords-file (get-file-auto-create bibliography-directory "ebib-keywords.txt"))
  (ebib-keywords-field-keep-sorted t)
  (ebib-keywords-file-save-on-exit 'always)
  (ebib-file-associations '(("pdf")) "using Emacs to open pdf")
  (ebib-use-timestamp t "recording the time that entries are added")
  (ebib-index-columns '(("Entry Key" 20 t)
			("Author/Editor" 40 nil)
			("Year" 6 t)
			("Title" 50 t)))
  (ebib-index-default-sort '("timestamp" . descend)))

(use-package org-ref
  :ensure t
  :defer 0.8
  :after ivy-bibtex
  :init
  (require 'bibtex)
  (setq bibtex-dialect 'biblatex)
  (setq bibtex-autokey-year-length 4
	bibtex-autokey-name-year-separator "-"
	bibtex-autokey-year-title-separator "-"
	bibtex-autokey-titleword-separator "-"
	bibtex-autokey-titlewords 2
	bibtex-autokey-titlewords-stretch 1
	bibtex-autokey-titleword-length 5)
  (define-key bibtex-mode-map (kbd "s-b") 'org-ref-bibtex-hydra/body)
  (define-key org-mode-map (kbd "C-c r") 'org-ref-insert-link)
  (define-key org-mode-map (kbd "s-r") 'org-ref-insert-link-hydra/body)
  (use-package org-ref-ivy
    :custom
    (org-ref-insert-link-function 'org-ref-insert-link-hydra/body)
    (org-ref-insert-cite-function 'org-ref-cite-insert-ivy)
    (org-ref-insert-label-function 'org-ref-insert-label-link)
    (org-ref-insert-ref-function 'org-ref-insert-ref-link)
    (org-ref-cite-onclick-function (lambda (_) (org-ref-citation-hydra/body)))
    )
  (require 'org-ref-ivy)
  (require 'org-ref-arxiv)
  (require 'org-ref-scopus)
  (require 'org-ref-wos))


(provide 'ref-lisp)
