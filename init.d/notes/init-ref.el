(use-package bibtex-completion
  :defer 0.8
  :ensure ivy-bibtex)
(use-package ivy-bibtex
  :ensure t
  :defer 0.8
  :after (bibtex-completion ivy)
  :init
  (setq bibtex-completion-library-path
	(mapcar (lambda (dir) (expand-directory-name-auto-create dir bibliography-directory))
		'("bibtex-pdfs")
		)
	bibtex-completion-notes-path interleave-path
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
  ("C-c e" . ebib)
  (:map ebib-index-mode-map
	("C-c r" . ebib-index-hydra/body))
;  ("C-c r" . ebib-hydra/body)
;  (:map ebib-multiline-mode-map
;   ("C-c C-c" . ebib-quit-multiline-buffer-and-save)
;   ("C-c C-q" . ebib-cancel-multiline-buffer)
;   ("C-c C-s" . ebib-save-from-multiline-buffer)))
  :hydra
  (ebib-index-hydra (:color blue :hint nil)
		    "
| ^^^^Database           | ^^Entry         | ^^Search & Mark    | ^^Sort           | ^^Reference      |
|^^^^--------------------|-^^--------------|-^^-----------------|-^^---------------|-^^---------------|
| _s_,_S_: Save          | _a_: Add        | _/_: Search        | _<_: Asending    | _uu_: Browse url |
|   ^^_w_: Save As       | _d_: Delete     | _?_: Search Next   | _>_: Desending   | _ud_: Browse doi |
| _r_,_R_: Reload        | _k_: Kill (Cut) | ^^                 | _=_: Default     | ^^               |
|   ^^_o_: Open File     | _y_: Yank       | _m_: Mark one      | ^^               |  _p_: Open pdf   |
|   ^^_i_: Import From   | _c_: Copy (Ce)  | _M_: Mark All/None | _f_: Filter Menu |  _n_: Open Note  |
| ^^^^     (no Short)    | _e_: Edit       | ^^   (C-u m)       | ^^   (F)         | ^^               |
"
		    ("s" ebib-save-current-database)
		    ("S" ebib-save-all-databases)
		    ("w" ebib-write-database)
		    ("r" ebib-reload-current-database)
		    ("R" ebib-reload-all-databases)
		    ("o" ebib-open-bibtex-file)
		    ("i" ebib-merge-bibtex-file)

		    ("a" ebib-add-entry)
		    ("d" ebib-delete-entry)
		    ("k" ebib-kill-entry)
		    ("y" ebib-yank-entry)
		    ("c" ebib-copy-entry)
		    ("e" ebib-edit-entry)

		    ("/" ebib-search)
		    ("?" ebib-search-next)
		    ("m" ebib-mark-entry)
		    ("M" ebib-mark-all-entries)

		    ("<" ebib-index-sort-ascending)
		    (">" ebib-index-sort-descending)
		    ("=" ebib-index-default-sort)

		    ("uu" ebib-browse-url)
		    ("ud" ebib-browse-doi)
		    ("p" ebib-view-file)
		    ("n" (lambda (file)
			   (interactive)
			   (ebib-view-file file)
			   (eaf-interleave-open-notes-file-auto-create)
			   ))

		    ("f" ebib-filters-hydra/body))

  (ebib-filters-hydra (:color blue :hint nil)
		      "
| ^^^^File        | ^^Operator |
|-^^^^------------|------------|
|   ^^_s_: Save   | _&_: And   |
|   ^^_l_: Load   | _|_: Or    |
|   ^^_r_: Rename | _~_: Not   |
| _d_,_D_: Delete |            |
"
		      ("s" ebib-filters-save-filters)
		      ("l" ebib--filters-load-file)
		      ("r" ebib-filters-rename-filter)
		      ("d" ebib-filters-delete-filter)
		      ("D" ebib-filters-delete-all-filters)
		      ("&" ebib-filters-logical-and)
		      ("|" ebib-filters-logical-or)
		      ("~" ebib-filters-logical-not)
		      )
  :custom
  (bibtex-autokey-name-case-convert-function 'capitalize)
  (bibtex-autokey-titlewords 0)
  (bibtex-autokey-year-length 4)
  (ebib-uniquify-keys t)
  (ebib-bibtex-dialect 'biblatex)
  (ebib-index-window-size 10)
  (ebib-preload-bib-files bibtex-completion-bibliography)
  (ebib-notes-directory interleave-path)
  (ebib-notes-storage 'one-file-per-note)
  (ebib-file-search-dirs bibtex-completion-library-path)
  (ebib-filters-default-file (expand-file-name-auto-create "ebib-filters.txt" bibliography-directory))
  (ebib-reading-list-file (expand-file-name-auto-create "readinglist.org" bibliography-directory))
  (ebib-keywords-file (expand-file-name-auto-create "ebib-keywords.txt" bibliography-directory))
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
  (require 'doi-utils)
  (define-key bibtex-mode-map (kbd "C-c r") 'org-ref-bibtex-hydra/body)
  (define-key org-mode-map (kbd "C-c r") 'org-ref-insert-link-hydra/body)
  (use-package org-ref-ivy
    :custom
    (org-ref-insert-link-function 'org-ref-insert-link-hydra/body)
    (org-ref-insert-cite-function 'org-ref-cite-insert-ivy)
    (org-ref-insert-label-function 'org-ref-insert-label-link)
    (org-ref-insert-ref-function 'org-ref-insert-ref-link)
    (org-ref-cite-onclick-function (lambda (_) (org-ref-citation-hydra/body)))
    )
  (require 'org-ref-arxiv)
  (require 'org-ref-scopus)
  (require 'org-ref-wos)
  (require 'org-ref-isbn)
  (require 'org-ref-pubmed)
  (require 'org-ref-sci-id)

  :custom
  (bibtex-autokey-year-length 4)
  (bibtex-autokey-name-year-separator "-")
  (bibtex-autokey-year-title-separator "-")
  (bibtex-autokey-titleword-separator "-")
  (bibtex-autokey-titlewords 2)
  (bibtex-autokey-titlewords-stretch 1)
  (bibtex-autokey-titleword-length 5)
  (bibtex-dialect 'biblatex)
  )


(provide 'init-ref)
