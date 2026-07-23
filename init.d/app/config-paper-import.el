;;; config-paper-import.el --- Import papers from browser to BibTeX -*- lexical-binding: t -*-

(require 'plz)
(setq resize-mini-windows t)

(defcustom paper-import-download-dir
  (expand-file-name "bibtex-pdfs" (or (bound-and-true-p bibliography-directory)
                                       (expand-file-name "bibtex" user-emacs-directory)))
  "Directory to store downloaded PDFs."
  :type 'directory
  :group 'paper-import)

(defcustom paper-import-default-notify t
  "If non-nil, show notification after import."
  :type 'boolean
  :group 'paper-import)

;;; --- URL Pattern Detection ---

(defvar paper-import--url-patterns
  '(;; DOI
    (doi . "https?://doi\\.org/\\(.+\\)")
    ;; arXiv
    (arxiv . "https?://arxiv\\.org/\\(?:abs\\|pdf\\)/\\([0-9]+\\.[0-9]+\\(?:v[0-9]+\\)?\\)")
    ;; PubMed
    (pubmed . "https?://pubmed\\.ncbi\\.nlm\\.nih\\.gov/\\([0-9]+\\)")
    ;; Google Scholar
    (scholar . "https?://scholar\\.google\\.com/.*&dq=\\(.+\\)")
    ;; Semantic Scholar
    (semantic-scholar . "https?://www\\.semanticscholar\\.org/paper/\\(.+\\)")
    ;; IEEE Xplore
    (ieee . "https?://ieeexplore\\.ieee\\.org/\\(?:document\\|stamp\\)/\\([0-9]+\\)")
    ;; ACM Digital Library
    (acm . "https?://dl\\.acm\\.org/doi/\\([0-9.]+/[0-9]+\\)")
    ;; Springer
    (springer . "https?://link\\.springer\\.com/\\(?:article\\|chapter\\)/\\([0-9.]+\\)")
    ;; Elsevier / ScienceDirect
    (elsevier . "https?://www\\.sciencedirect\\.com/\\(?:science\\|science-article\\)/article/pii/\\([A-Z0-9]+\\)")
    ;; Wiley
    (wiley . "https?://onlinelibrary\\.wiley\\.com/doi/\\(?:abs\\|full\\|pdfdirect\\)/\\([0-9.]+/\\(?:[a-zA-Z0-9]+\\.\\)+[0-9]+\\)")
    ;; Nature
    (nature . "https?://www\\.nature\\.com/articles/\\([a-z0-9-]+\\)")
    ;; JSTOR
    (jstor . "https?://www\\.jstor\\.org/stable/\\([0-9]+\\)")
    ;; SSRN
    (ssrn . "https?://papers\\.ssrn\\.com/sol3/papers\\.cfm\\?abstract_id=\\([0-9]+\\)")
    ;; ResearchGate
    (researchgate . "https?://www\\.researchgate\\.net/publication/\\([0-9]+\\)")
    ;; DBLP
    (dblp . "https?://dblp\\.org/rec/\\([a-z0-9-]+\\)")
    ;; DBLP (new URL format)
    (dblp-new . "https?://dblp\\.org/search/\\?q=\\(.+\\)")
    ;; Generic PDF link
    (generic-pdf . "https?://[^/]+/[^/]*\\.pdf\\(?:\\?.*\\)?"))
  "Alist of (TYPE . REGEXP) for detecting academic URLs.")

(defun paper-import--detect-url-type (url)
  "Detect the type of academic URL.
Returns (TYPE . MATCHED-CONTENT) or nil."
  (catch 'found
    (dolist (pattern paper-import--url-patterns)
      (when (string-match (cdr pattern) url)
        (throw 'found (cons (car pattern) (match-string 1 url)))))))

;;; --- BibTeX Generation ---

(defun paper-import--generate-key (authors year title)
  "Generate a BibTeX citation key."
  (let* ((first-author (if (string-match "\\([^,]+\\)" authors)
                           (match-string 1 authors)
                         authors))
         (last-name (if (string-match "\\([A-Za-zÀ-ÿ-]+\\)\\s-*$"
                                      (replace-regexp-in-string "\\s-+" " " first-author))
                        (match-string 1
                                      (replace-regexp-in-string "\\s-+" " " first-author))
                      (replace-regexp-in-string "[^A-Za-z]" "" first-author)))
         (title-word (if (string-match "\\b\\([A-Za-z]+\\)" title)
                         (downcase (match-string 1 title))
                       "untitled")))
    (format "%s%s%s" last-name year (capitalize title-word))))

(defun paper-import--format-authors-bibtex (authors-list)
  "Format AUTHORS-LIST for BibTeX (Last, First and Last, First)."
  (mapconcat
    (lambda (author)
      (let ((trimmed (string-trim author)))
        (if (string-match "\\(.*?\\)\\s-*,\\s-*\\(.*\\)" trimmed)
            (format "%s, %s" (match-string 1 trimmed) (match-string 2 trimmed))
          ;; Detect format: "Last Initial" vs "First Last"
          (if (string-match "\\(\\S-+\\)\\s-+\\(\\S.*\\)" trimmed)
              (let ((part1 (match-string 1 trimmed))
                    (part2 (match-string 2 trimmed)))
                (if (<= (length part2) 2)
                    ;; "Last Initial" (e.g. "Li Q") → "Li, Q"
                    (format "%s, %s" part1 part2)
                  ;; "First Last" (e.g. "Alexander Viand") → "Viand, Alexander"
                  (format "%s, %s" part2 part1)))
            trimmed))))
   authors-list
   " and "))

(defun paper-import--to-bibtex (metadata &optional key)
  "Convert METADATA plist to BibTeX entry string.
KEY is optional citation key."
  (let* ((authors (paper-import--format-authors-bibtex
                   (if (listp (plist-get metadata :authors))
                       (plist-get metadata :authors)
                     (list (or (plist-get metadata :authors) "Unknown")))))
         (year (or (plist-get metadata :year) ""))
         (title (or (plist-get metadata :title) "Untitled"))
         (cite-key (or key (paper-import--generate-key authors year title)))
         (journal (or (plist-get metadata :journal) ""))
         (volume (or (plist-get metadata :volume) ""))
         (issue (or (plist-get metadata :issue) ""))
         (pages (or (plist-get metadata :pages) ""))
         (doi (or (plist-get metadata :doi) ""))
         (entry-type (cond
                      ((string-match "proceeding\\|conference" (downcase journal)) "inproceedings")
                      ((string-match "book\\|chapter" (downcase (or (plist-get metadata :url-type) ""))) "incollection")
                      (t "article"))))
    (concat
     (format "@%s{%s,\n" entry-type cite-key)
     (format "  author       = {%s},\n" authors)
     (format "  title        = {{%s}},\n" title)
     (format "  year         = {%s},\n" year)
     (when (and journal (not (string-empty-p journal)))
       (format "  journal      = {%s},\n" journal))
     (when (and volume (not (string-empty-p volume)))
       (format "  volume       = {%s},\n" volume))
     (when (and issue (not (string-empty-p issue)))
       (format "  number       = {%s},\n" issue))
     (when (and pages (not (string-empty-p pages)))
       (format "  pages        = {%s},\n" pages))
     (when (and doi (not (string-empty-p doi)))
       (format "  doi          = {%s},\n" doi))
     (format "  url          = {%s}\n"
             (or (plist-get metadata :url) ""))
     "}")))

;;; --- Import to Database ---

(defun paper-import--check-duplicate (bibtex-entry bib-file)
  "Check if BIBTEX-ENTRY already exists in BIB-FILE.
Returns the existing key if duplicate found, nil otherwise."
  (when (and bib-file (file-exists-p bib-file))
    (let ((doi (when (string-match "doi\\s-*=\\s-*{\\([^}]+\\)}" bibtex-entry)
                 (match-string 1 bibtex-entry)))
          (key (when (string-match "@\\w+{\\([^,]+\\)," bibtex-entry)
                 (match-string 1 bibtex-entry))))
      (with-temp-buffer
        (insert-file-contents bib-file)
        (let ((content (buffer-string)))
          (cond
           ((and doi (string-match-p (regexp-quote doi) content))
            doi)
           ((and key (string-match-p
                      (concat "@\\w+{" (regexp-quote key) ",")
                      content))
            key)
           (t nil)))))))

(defun paper-import--select-bib-file ()
  "Prompt user to select a .bib file from bibtex-completion-bibliography.
Returns the selected file path."
  (if (and (boundp 'bibtex-completion-bibliography)
           (listp bibtex-completion-bibliography)
           (> (length bibtex-completion-bibliography) 1))
      (let ((choice (completing-read "Save to .bib file: "
                                     bibtex-completion-bibliography
                                     nil t)))
        choice)
    (or (and (boundp 'bibtex-completion-bibliography)
             (car bibtex-completion-bibliography))
        (expand-file-name "refs.bib" (or (bound-and-true-p bibliography-directory)
                                          user-emacs-directory)))))

(defun paper-import--save-bibtex (bibtex-entry &optional bib-file)
  "Save BIBTEX-ENTRY to BIB-FILE with duplicate check.
Returns \\='duplicate, \\='saved, or \\='skipped."
  (let* ((file (or bib-file (paper-import--select-bib-file)))
         (dir (file-name-directory file)))
    (unless (file-exists-p dir)
      (make-directory dir t))
    (let ((dup (paper-import--check-duplicate bibtex-entry file)))
      (if dup
          (progn
            (message "[Paper] Duplicate found: %s exists in %s" dup file)
            (cond
             ((y-or-n-p (format "Entry '%s' already exists. Overwrite?" dup))
              ;; Remove old entry, insert new
              (paper-import--replace-entry file dup bibtex-entry)
              (message "[Paper] Replaced: %s" dup)
              'saved)
             ((y-or-n-p "Skip this import?")
              (message "[Paper] Skipped: %s" dup)
              'skipped)
             (t
              ;; Append as new entry with modified key
              (let* ((new-key (concat dup "-new"))
                     (modified (replace-regexp-in-string
                                (regexp-quote dup) new-key bibtex-entry)))
                (with-temp-buffer
                  (insert modified "\n\n")
                  (append-to-file (point-min) (point-max) file))
                (message "[Paper] Appended as: %s" new-key)
                'saved))))
        ;; No duplicate, save normally
        (with-temp-buffer
          (insert bibtex-entry "\n\n")
          (if (file-exists-p file)
              (append-to-file (point-min) (point-max) file)
            (write-region (point-min) (point-max) file)))
        (message "[Paper] Saved to %s" file)
        'saved))))

(defun paper-import--replace-entry (bib-file old-key new-entry)
  "Replace entry with OLD-KEY in BIB-FILE with NEW-ENTRY."
  (let ((temp-file (make-temp-file "bib-replace" nil ".bib")))
    (with-temp-buffer
      (insert-file-contents bib-file)
      (goto-char (point-min))
      ;; Find and remove old entry
      (when (re-search-forward
             (concat "@\\w+{" (regexp-quote old-key) ",")
             nil t)
        (let ((start (progn (beginning-of-line) (point))))
          ;; Find matching closing brace
          (forward-sexp)
          (delete-region start (point))
          ;; Insert new entry
          (insert new-entry "\n\n")))
      (write-region (point-min) (point-max) temp-file))
    (rename-file temp-file bib-file t)))

;;; --- PDF Download ---

(defun paper-import--download-pdf (pdf-url &optional filename)
  "Download PDF from PDF-URL to `paper-import-download-dir'.
FILENAME is optional; auto-generated if nil."
  (when (and pdf-url (not (string-empty-p pdf-url)))
    (let* ((name (or filename
                     (concat (file-name-nondirectory
                              (directory-file-name
                               (url-filename (url-generic-parse-url pdf-url))))
                              ".pdf")))
           (dest (expand-file-name name paper-import-download-dir)))
      (make-directory paper-import-download-dir t)
      (message "[Paper] Downloading PDF to %s..." dest)
      (plz 'get pdf-url :as `(file ,dest)
        :then (lambda (_) (message "[Paper] PDF saved: %s" dest))
        :else (lambda (err) (message "[Paper] PDF download failed: %s" err))))))

;;; --- PubMed E-utilities API ---

(defun paper-import--fetch-pubmed (pmid callback)
  "Fetch PubMed metadata for PMID via E-utilities API, call CALLBACK with plist."
  (let ((url (format "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=%s&retmode=json" pmid)))
    (message "[Paper] Fetching PubMed %s..." pmid)
    (plz 'get url :as #'json-read
      :then (lambda (data)
              (let* ((result (alist-get 'result data))
                     (item (alist-get (intern pmid) result))
                     (title (or (alist-get 'title item) ""))
                     (source (or (alist-get 'source item) ""))
                     (pubdate (or (alist-get 'pubdate item) ""))
                     (authors-raw (alist-get 'authors item))
                     (authors (mapcar (lambda (a) (alist-get 'name a)) authors-raw))
                     (elocationid (or (alist-get 'elocationid item) ""))
                     (doi "")
                     (year "")
                     (volume (or (alist-get 'volume item) ""))
                     (issue (or (alist-get 'issue item) ""))
                     (pages (or (alist-get 'pages item) "")))
                ;; Extract year from pubdate
                (when (string-match "\\([0-9]\\{4\\}\\)" pubdate)
                  (setq year (match-string 1 pubdate)))
                ;; Extract DOI from elocationid
                (when (string-match "doi: \\(.+\\)" elocationid)
                  (setq doi (match-string 1 elocationid)))
                (funcall callback
                         (list :title title
                               :authors authors
                               :year year
                               :journal source
                               :volume volume
                               :issue issue
                               :pages pages
                               :doi doi
                               :pmid pmid
                               :url (format "https://pubmed.ncbi.nlm.nih.gov/%s" pmid)))))
      :else (lambda (err)
              (message "[Paper] PubMed API error: %s" err)))))

;;; --- arXiv API ---

(defun paper-import--fetch-arxiv (arxiv-id callback)
  "Fetch arXiv metadata via Atom API, call CALLBACK with plist."
  (let ((url (format "https://export.arxiv.org/api/query?id_list=%s" arxiv-id)))
    (message "[Paper] Fetching arXiv %s..." arxiv-id)
    (plz 'get url :as 'string
      :then (lambda (xml-text)
              (let ((title "")
                    (authors '())
                    (year "")
                    (abstract "")
                    (doi "")
                    (entry-start (string-match "<entry>" xml-text))
                    (entry-end (string-match "</entry>" xml-text)))
                ;; Extract <entry> block by position
                (when (and entry-start entry-end)
                  (let ((entry (substring xml-text (+ entry-start 8) entry-end)))
                    ;; Entry title
                    (when (string-match "<title>\\([^<]+\\)</title>" entry)
                      (setq title (match-string 1 entry)))
                    ;; Authors
                    (let ((xml entry))
                      (while (string-match "<name>\\([^<]+\\)</name>" xml)
                        (push (match-string 1 xml) authors)
                        (setq xml (substring xml (match-end 0)))))))
                ;; Year
                (when (string-match "<published>\\([0-9]\\{4\\}\\)" xml-text)
                  (setq year (match-string 1 xml-text)))
                ;; Abstract
                (when (string-match "<summary>\\([^<]+\\)</summary>" xml-text)
                  (setq abstract (replace-regexp-in-string "\n\\|\\s-+" " " (match-string 1 xml-text))))
                (funcall callback
                         (list :title title
                               :authors authors
                               :year year
                               :abstract abstract
                               :doi doi
                               :url (format "https://arxiv.org/abs/%s" arxiv-id)))))
      :else (lambda (err)
              (message "[Paper] arXiv API error: %s" err)))))

;;; --- DOI via CrossRef API ---

(defun paper-import--fetch-doi (doi callback)
  "Fetch metadata for DOI via CrossRef API, call CALLBACK with plist."
  (let ((url (format "https://api.crossref.org/works/%s" doi)))
    (message "[Paper] Fetching DOI %s..." doi)
    (plz 'get url :as #'json-read
      :then (lambda (data)
              (condition-case err
                  (let* ((message-data (alist-get 'message data))
                         (title-vec (alist-get 'title message-data))
                         (title (if (vectorp title-vec) (aref title-vec 0) (car title-vec)))
                         (authors (mapcar (lambda (a)
                                            (concat (alist-get 'family a) ", "
                                                    (alist-get 'given a)))
                                          (alist-get 'author message-data)))
                         (pubdate (or (alist-get 'published-print message-data)
                                      (alist-get 'published-online message-data)))
                         (date-parts-raw (when pubdate (alist-get 'date-parts pubdate)))
                         (date-parts-vec (when date-parts-raw
                                           (if (vectorp date-parts-raw) (aref date-parts-raw 0) (car date-parts-raw))))
                         (year (when (and date-parts-vec (>= (length date-parts-vec) 1))
                                 (let ((y (if (vectorp date-parts-vec) (aref date-parts-vec 0) (car date-parts-vec))))
                                   (if (numberp y) (number-to-string y) (format "%s" y)))))
                         (journal-vec (alist-get 'container-title message-data))
                         (journal (if (vectorp journal-vec) (aref journal-vec 0) (car journal-vec)))
                         (volume (alist-get 'volume message-data))
                         (issue (alist-get 'issue message-data))
                         (pages (alist-get 'page message-data)))
                    (funcall callback
                             (list :title title
                                   :authors authors
                                   :year (or year "")
                                   :journal journal
                                   :volume volume
                                   :issue issue
                                   :pages pages
                                   :doi doi
                                   :url (format "https://doi.org/%s" doi))))
                (error
                 (message "[Paper] CrossRef parse error: %s" err))))
      :else (lambda (err)
              (message "[Paper] CrossRef API error: %s" err)))))

;;; --- Main Import Workflow ---

(defun paper-import-from-browser (&optional arg)
  "Import paper info from current EAF browser page.
With prefix ARG, also download PDF."
  (interactive "P")
  (if (not (and (boundp 'eaf--buffer-app-name)
                (string= eaf--buffer-app-name "browser")))
      (user-error "[Paper] Not in an EAF browser buffer")
    (let* ((url eaf--buffer-url)
           (detected (paper-import--detect-url-type url)))
      (if (not detected)
          (message "[Paper] URL not recognized. Use M-x paper-import-raw.")
        (let ((type (car detected))
              (id (cdr detected)))
          (message "[Paper] Detected %s: %s" type id)
          (paper-import--fetch-and-save type id arg))))))

(defun paper-import--fetch-and-save (type id download-p)
  "Fetch metadata via API based on TYPE and ID, then save.
DOWNLOAD-P: if non-nil, also download PDF."
  (let ((callback
         (lambda (metadata)
           (let* ((full-metadata (append metadata
                                         (list :url-type (symbol-name type))))
                  (bibtex (paper-import--to-bibtex full-metadata)))
             (if (y-or-n-p (format "%s\nImport?" bibtex))
                 (progn
                   (message "")
                   (let ((file (paper-import--select-bib-file)))
                     (let ((result (paper-import--save-bibtex bibtex file)))
                       (when (eq result 'saved)
                         (when download-p
                           (let ((pdf-url (or (plist-get full-metadata :pdfUrl)
                                              (plist-get full-metadata :pdf-url))))
                             (if pdf-url
                                 (paper-import--download-pdf
                                  pdf-url
                                  (concat (paper-import--generate-key
                                           (paper-import--format-authors-bibtex
                                            (plist-get full-metadata :authors))
                                           (plist-get full-metadata :year)
                                           (plist-get full-metadata :title))
                                          ".pdf"))
                               (message "[Paper] No PDF URL available for download"))))
                         (minibuffer-message "[Paper] Imported: %s"
                                  (truncate-string-to-width
                                   (plist-get full-metadata :title)
                                   (- (frame-width) 14) nil nil "..."))))))
               (minibuffer-message "[Paper] Import cancelled"))))))
    (pcase type
      ('pubmed (paper-import--fetch-pubmed id callback))
      ('arxiv (paper-import--fetch-arxiv id callback))
      ('doi (paper-import--fetch-doi id callback))
      (_ (message "[Paper] No API available for type '%s'. Use manual import." type)))))

;;; --- Manual/Raw Import ---

(defun paper-import-raw (&optional arg)
  "Manually import paper with custom URL.
Prompts for BibTeX fields. With prefix ARG, download PDF."
  (interactive "P")
  (let* ((url (if (and (boundp 'eaf--buffer-app-name)
                       (string= eaf--buffer-app-name "browser"))
                  eaf--buffer-url
                (read-string "URL: ")))
         (title (read-string "Title: "))
         (authors (read-string "Authors (comma-separated): "))
         (year (read-string "Year: "))
         (journal (read-string "Journal/Venue: "))
         (doi (read-string "DOI: "))
         (metadata (list :title title
                         :authors (split-string authors "," t)
                         :year year
                         :journal journal
                         :doi doi
                         :url url))
         (bibtex (paper-import--to-bibtex metadata)))
     (if (y-or-n-p (format "%s\nSave?" bibtex))
         (progn
           (message "")
           (let ((file (paper-import--select-bib-file)))
             (paper-import--save-bibtex bibtex file)
             (minibuffer-message "[Paper] Imported: %s"
                      (truncate-string-to-width title (- (frame-width) 14) nil nil "..."))))
       (minibuffer-message "[Paper] Import cancelled"))))

;;; --- Import from ID (interactive) ---

(defun paper-import-pubmed (&optional arg)
  "Import paper from PubMed ID.
With prefix ARG, download PDF."
  (interactive "P")
  (let ((pmid (read-string "PubMed ID: ")))
    (paper-import--fetch-and-save 'pubmed pmid arg)))

(defun paper-import-arxiv (&optional arg)
  "Import paper from arXiv ID.
With prefix ARG, download PDF."
  (interactive "P")
  (let ((id (read-string "arXiv ID (e.g. 2301.07041): ")))
    (paper-import--fetch-and-save 'arxiv id arg)))

(defun paper-import-doi (&optional arg)
  "Import paper from DOI.
With prefix ARG, download PDF."
  (interactive "P")
  (let ((doi (read-string "DOI: ")))
    (paper-import--fetch-and-save 'doi doi arg)))

;;; --- Batch Download PDFs from BibTeX ---

(defun paper-import-download-bibtex-pdfs ()
  "Download PDFs for all entries in bibtex-completion-bibliography.
Uses DOI to construct PDF URLs."
  (interactive)
  (let ((entries (bibtex-completion-find-pdf-in-library)))
    (if (null entries)
        (message "[Paper] No PDFs to download")
      (dolist (entry entries)
        (let* ((key (bibtex-completion-get-value "=key=" entry))
               (doi (bibtex-completion-get-value "doi" entry))
               (url (and doi (format "https://doi.org/%s" doi))))
          (when url
            (paper-import--download-pdf
             url
             (concat key ".pdf"))))))))

;;; --- Import BibTeX from Clipboard ---

(defun paper-import-bibtex-from-clipboard ()
  "Import BibTeX entry from clipboard to bibliography file."
  (interactive)
  (let* ((bibtex-text (with-current-buffer (window-buffer)
                        (if (and (boundp 'eaf--buffer-app-name)
                                 (string= eaf--buffer-app-name "browser"))
                            (or (eaf-call-sync "execute_function" eaf--buffer-id "get_text")
                                (error "No text selected"))
                          ;; Fallback to clipboard
                          (current-kill 0))))
         (cleaned (string-trim bibtex-text)))
    (when (and cleaned (not (string-empty-p cleaned)))
      (if (string-match-p "@\\(article\\|inproceedings\\|incollection\\|book\\|phdthesis\\|mastersthesis\\)" cleaned)
          (progn
            (paper-import--save-bibtex cleaned)
            (message "[Paper] BibTeX imported"))
        (message "[Paper] No valid BibTeX entry found in clipboard")))))

;;; --- Import RIS from Clipboard ---

(defun paper-import-ris-from-clipboard ()
  "Import RIS entry from clipboard, convert to BibTeX, and save."
  (interactive)
  (let* ((ris-text (with-current-buffer (window-buffer)
                     (if (and (boundp 'eaf--buffer-app-name)
                              (string= eaf--buffer-app-name "browser"))
                         (or (eaf-call-sync "execute_function" eaf--buffer-id "get_text")
                             (error "No text selected"))
                       (current-kill 0))))
         (cleaned (string-trim ris-text)))
    (when (and cleaned (not (string-empty-p cleaned)))
      (if (string-match-p "^TY  -" cleaned)
          (let ((temp-ris (make-temp-file "ris-" nil ".ris"))
                (temp-bib (make-temp-file "bib-" nil ".bib")))
            (with-temp-file temp-ris
              (insert cleaned))
            (shell-command (format "ris2xml %s | xml2bib > %s" temp-ris temp-bib))
            (let ((bibtex (with-temp-buffer
                           (insert-file-contents temp-bib)
                           (buffer-string))))
              (delete-file temp-ris)
              (delete-file temp-bib)
              (when (and bibtex (not (string-empty-p bibtex)))
                (paper-import--save-bibtex bibtex)
                (message "[Paper] RIS converted and imported"))))
        (message "[Paper] No valid RIS entry found in clipboard")))))

(provide 'config-paper-import)
;;; config-paper-import.el ends here
