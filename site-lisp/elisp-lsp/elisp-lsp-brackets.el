;;; elisp-lsp-brackets.el --- Bracket hierarchy & structure analysis -*- lexical-binding: t; -*-
;;; Commentary:
;; Bracket analysis using syntax-ppss and scan-sexps (not string parsing).
;; Integrates trace_detailed.py (depth trace) and analyze_structure.py (ownership/mismatch).
;; All analysis operates on real Elisp elements via Emacs syntax table.

;;; Code:

(require 'cl-lib)

;;; --- Coordinate helpers ---

(defun elisp-lsp--line-col-to-pos (line col)
  "Convert LINE:COL to buffer position (0-indexed)."
  (save-excursion
    (goto-char (point-min))
    (forward-line line)
    (min (+ (line-beginning-position) col) (line-end-position))))

(defun elisp-lsp--pos-to-line-col (pos)
  "Convert buffer POS to (LINE COL)."
  (save-excursion
    (goto-char pos)
    (cons (line-number-at-pos pos t) (- (point) (line-beginning-position)))))

(defun elisp-lsp--pos-to-uri-range (pos uri)
  "Convert POS to LSP Range with URI."
  (pcase-let ((`(,line . ,col) (elisp-lsp--pos-to-line-col pos)))
    (list :uri uri
          :range (list :start (list :line line :character col)
                       :end (list :line line :character (1+ col))))))

;;; --- Bracket classification ---

(defsubst elisp-lsp--opening-bracket-p (char)
  "Non-nil if CHAR is an opening bracket."
  (memq char '(?\( ?\[ ?\{)))

(defsubst elisp-lsp--closing-bracket-p (char)
  "Non-nil if CHAR is a closing bracket."
  (memq char '(?\) ?\] ?\})))

(defsubst elisp-lsp--matching-bracket (char)
  "Return the matching bracket for CHAR, or nil."
  (pcase char
    (?\( ?\)) (?\) ?\()
    (?\[ ?\]) (?\] ?\[)
    (?\{ ?\}) (?\} ?\{)))

;;; --- Layer 1: Raw pair collection via scan-sexps ---

(defun elisp-lsp--collect-pairs ()
  "Find all matched bracket pairs using scan-lists.
Returns list of (OPEN-POS CLOSE-POS OPEN-CHAR CLOSE-CHAR DEPTH).
Character literals, strings, and comments are skipped automatically
by the syntax table."
  (let (pairs)
    (goto-char (point-min))
    (while (re-search-forward "\\s(" nil t)
      (let* ((pos (match-beginning 0))
             (char (char-after pos))
             (ppss (save-excursion (syntax-ppss pos)))
             (in-str (or (nth 3 ppss) (nth 4 ppss))))
        (when (not in-str)
          (let ((close-pos
                 (condition-case nil
                     (save-excursion (scan-lists pos 1 0))
                   (scan-error nil))))
            (when close-pos
              (let* ((close-char (char-before close-pos))
                     (depth (car ppss))
                     (expected (elisp-lsp--matching-bracket char)))
                (when (and expected (eq close-char expected))
                  (push (list pos (1- close-pos) char close-char depth)
                        pairs))))))))
    (nreverse pairs)))

;;; --- Layer 2: Depth trace (trace_detailed.py equivalent) ---

(defun elisp-lsp--build-depth-trace ()
  "Build line-by-line depth trace using syntax-ppss.
Returns plist with :line-info (per-line data) and :max-depth."
  (let* ((lines-count (count-lines (point-min) (point-max)))
         (line-info (make-vector (1+ lines-count) nil))
         (max-depth 0))
    (save-excursion
      (goto-char (point-min))
      (let ((current-line 0)
            (prev-depth 0)
            (line-min 0)
            (line-max 0)
            (line-opens nil))
        (while (not (eobp))
          (let* (           (pos (point))
                 (ppss (syntax-ppss pos))
                 (depth (car ppss))
                 (bol (line-beginning-position)))
            ;; Reset tracking on new line
            (when (and (= pos bol) (> pos (point-min)))
              (aset line-info current-line
                    (list :line current-line
                          :depth-start prev-depth
                          :depth-min line-min
                          :depth-max line-max
                          :depth-delta (- depth prev-depth)
                          :opens (nreverse line-opens)))
              (cl-incf current-line)
              (setq line-min depth
                    line-max depth
                    line-opens nil))
            ;; Track depth range within this line
            (setq line-min (min line-min depth)
                  line-max (max line-max depth))
            (when (> depth max-depth)
              (setq max-depth depth))
            ;; Record which brackets open at this line
            (when (and (elisp-lsp--opening-bracket-p (char-after pos))
                       (not (or (nth 3 ppss) (nth 4 ppss))))
              (push (list :char (char-after pos) :pos pos :depth depth)
                    line-opens))
            (setq prev-depth depth)
            (forward-char 1)))
        ;; Record final line
        (when (< current-line (length line-info))
          (aset line-info current-line
                (list :line current-line
                      :depth-start prev-depth
                      :depth-min line-min
                      :depth-max line-max
                      :depth-delta 0
                      :opens (nreverse line-opens))))))
    (list :line-info line-info
          :max-depth max-depth
          :line-count (1+ (count-lines (point-min) (point-max))))))

;;; --- Layer 3: Structure analysis (analyze_structure.py equivalent) ---

(defun elisp-lsp--analyze-structure ()
  "Full bracket structure analysis.
Returns plist with :pairs-by-type, :unmatched,
:mismatched, :depth-breakdown."
  (let* ((all-pairs (elisp-lsp--collect-pairs))
         (depth-trace (elisp-lsp--build-depth-trace))
         (max-depth (plist-get depth-trace :max-depth))
         (line-info (plist-get depth-trace :line-info))
         (paren-pairs
          (cl-remove-if-not
           (lambda (p) (eq (nth 2 p) ?\()) all-pairs))
         (bracket-pairs
          (cl-remove-if-not
           (lambda (p) (eq (nth 2 p) ?\[)) all-pairs))
         (brace-pairs
          (cl-remove-if-not
           (lambda (p) (eq (nth 2 p) ?\{)) all-pairs))
         (unmatched '())
         (mismatched '())
         (stack '()))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "[][(){}]" nil t)
        (let* ((pos (match-beginning 0))
               (char (char-after pos))
               (ppss (save-excursion (syntax-ppss pos))))
          (when (not (or (nth 3 ppss) (nth 4 ppss)))
            (if (elisp-lsp--opening-bracket-p char)
                (push (list char pos) stack)
              (if stack
                  (let ((top (pop stack)))
                    (unless (eq (elisp-lsp--matching-bracket char)
                                (car top))
                      (pcase-let
                          ((`(,line . ,col)
                            (elisp-lsp--pos-to-line-col pos)))
                        (push
                         (list :pos pos :char char
                               :line line :col col
                               :type "mismatched"
                               :message
                               (format "Mismatched '%c', expected '%c'"
                                       char (elisp-lsp--matching-bracket
                                             (car top))))
                         mismatched))))
                (pcase-let
                    ((`(,line . ,col)
                      (elisp-lsp--pos-to-line-col pos)))
                  (push
                   (list :pos pos :char char
                         :line line :col col
                         :type "unmatched"
                         :message (format "Unmatched '%c'" char))
                   unmatched)))))))
      (dolist (entry stack)
        (pcase-let
            ((`(,line . ,col)
              (elisp-lsp--pos-to-line-col (nth 1 entry))))
          (push
           (list :pos (nth 1 entry) :char (car entry)
                 :line line :col col
                 :type "unmatched"
                 :message (format "Unmatched '%c'" (car entry)))
           unmatched))))
    (let ((depth-breakdown
           (make-vector (1+ max-depth) nil)))
      (dolist (pair paren-pairs)
        (let ((depth (nth 4 pair)))
          (when (<= depth max-depth)
            (push
             (list :open-pos (nth 0 pair)
                   :close-pos (nth 1 pair)
                   :depth depth)
             (aref depth-breakdown depth)))))
      (dotimes (i (length line-info))
        (when (aref line-info i)
          (let ((li (aref line-info i)))
            (setf (plist-get li :pairs-count)
                  (length
                   (cl-remove-if-not
                    (lambda (p)
                      (= (nth 4 p)
                         (plist-get li :depth-start)))
                    paren-pairs))))))
      (list :pairs-by-type
            (list :paren paren-pairs
                  :bracket bracket-pairs
                  :brace brace-pairs)
            :pairs-by-depth depth-breakdown
            :all-pairs all-pairs
            :unmatched (nreverse unmatched)
            :mismatched (nreverse mismatched)
            :max-depth max-depth
            :depth-trace depth-trace))))

;;; --- Layer 4: Public API ---

(defun elisp-lsp--with-parse-buffer (uri text body)
  "Run BODY in a temp buffer with TEXT in `emacs-lisp-mode'.
Provides fully-initialized syntax table for BODY."
  (let ((buf (get-buffer-create (format " *elisp-lsp-parse:%s*" uri))))
    (unwind-protect
        (with-current-buffer buf
          (erase-buffer)
          (insert text)
          (delay-mode-hooks (emacs-lisp-mode))
          (syntax-ppss-flush-cache (point-min))
          (goto-char (point-min))
          (funcall body))
      (kill-buffer buf))))

(defun elisp-lsp-bracket-hierarchy (uri text line character)
  "Bracket hierarchy at LINE:CHARACTER in TEXT.
Returns plist with :depth, :line, :character, :in-string,
:in-comment, :context (list of enclosing bracket chars)."
  (elisp-lsp--with-parse-buffer
   uri text
   (lambda ()
      (goto-char (point-min))
      (forward-line (max 0 (1- line)))
      (let ((eol (line-end-position)))
        (when (< (point) eol)
          (forward-char
           (min character (max 0 (- eol (point)))))))
      (let* ((ppss (syntax-ppss))
             (depth (car ppss))
             (context nil)
             (state ppss))
        (while (and state (> (car state) 0))
          (let ((open-pos (nth 1 state)))
            (when open-pos
              (push (char-after open-pos) context))
            (setq state
                  (when open-pos
                    (save-excursion (syntax-ppss open-pos))))))
        (list :depth depth
              :line line
              :character character
              :in-string (if (nth 3 ppss) t nil)
              :in-comment (if (nth 4 ppss) t nil)
              :context (vconcat
                        (mapcar (lambda (c) (string c))
                                context)))))))


(defun elisp-lsp-bracket-structure (uri text)
  "Full bracket structure analysis for TEXT.
Returns plist with :pairsByType, :unmatched, :mismatched,
:maxDepth, :depthTrace."
  (elisp-lsp--with-parse-buffer
   uri text
   (lambda ()
     (let* ((result (elisp-lsp--analyze-structure))
            (pairs-by-type (plist-get result :pairs-by-type))
            (paren-pairs (plist-get pairs-by-type :paren))
            (bracket-pairs (plist-get pairs-by-type :bracket))
            (brace-pairs (plist-get pairs-by-type :brace))
            (unmatched (plist-get result :unmatched))
            (mismatched (plist-get result :mismatched))
            (max-depth (plist-get result :max-depth))
            (depth-trace (plist-get result :depth-trace))
            (line-info (plist-get depth-trace :line-info)))
       (let ((line-info-list nil))
         (dotimes (i (length line-info))
           (when (aref line-info i)
             (let* ((li (aref line-info i))
                    (opens (plist-get li :opens)))
               (push
                (list :line (plist-get li :line)
                      :depthStart (plist-get li :depth-start)
                      :depthMin (plist-get li :depth-min)
                      :depthMax (plist-get li :depth-max)
                      :depthDelta (plist-get li :depth-delta)
                      :opens (vconcat
                              (mapcar
                               (lambda (o)
                                 (list :char (string (plist-get o :char))
                                       :depth (plist-get o :depth)))
                               opens)))
                line-info-list))))
         (let ((convert-pair
                (lambda (p)
                  (pcase-let
                      ((`(,open-pos ,close-pos
                           ,open-char ,close-char ,d) p))
                    (let ((olc (elisp-lsp--pos-to-line-col open-pos))
                          (clc (elisp-lsp--pos-to-line-col close-pos)))
                      (list :openLine (car olc)
                            :openCol (cdr olc)
                            :closeLine (car clc)
                            :closeCol (cdr clc)
                            :openChar (string open-char)
                            :closeChar (string close-char)
                            :depth d))))))
           (list
            :pairsByType
            (list :paren (vconcat
                          (mapcar convert-pair paren-pairs))
                  :bracket (vconcat
                            (mapcar convert-pair bracket-pairs))
                  :brace (vconcat
                          (mapcar convert-pair brace-pairs)))
            :unmatched
            (vconcat
             (mapcar
              (lambda (u)
                (list :line (plist-get u :line)
                      :col (plist-get u :col)
                      :char (string (plist-get u :char))
                      :type (plist-get u :type)
                      :message (plist-get u :message)))
              unmatched))
            :mismatched
            (vconcat
             (mapcar
              (lambda (m)
                (list :line (plist-get m :line)
                      :col (plist-get m :col)
                      :char (string (plist-get m :char))
                      :type (plist-get m :type)
                      :message (plist-get m :message)))
              mismatched))
            :maxDepth max-depth
            :depthTrace
            (vconcat (nreverse line-info-list)))))))))

(defun elisp-lsp-bracket-depth-map (uri text)
  "Line-by-line depth map for TEXT (trace_detailed.py equivalent).
Returns plist with :maxDepth and :lineInfo."
  (elisp-lsp--with-parse-buffer
   uri text
   (lambda ()
     (let* ((trace (elisp-lsp--build-depth-trace))
            (line-info (plist-get trace :line-info))
            (line-info-list nil))
       (dotimes (i (length line-info))
         (when (aref line-info i)
           (let* ((li (aref line-info i))
                  (opens (plist-get li :opens)))
             (push (list :line (plist-get li :line)
                         :depthStart (plist-get li :depth-start)
                         :depthMin (plist-get li :depth-min)
                         :depthMax (plist-get li :depth-max)
                         :depthDelta (plist-get li :depth-delta)
                         :opens (vconcat (mapcar
                                         (lambda (o)
                                           (list :char (string (plist-get o :char))
                                                 :depth (plist-get o :depth)))
                                         opens)))
                   line-info-list))))
       (list :maxDepth (plist-get trace :max-depth)
             :lineInfo (vconcat (nreverse line-info-list)))))))

(defun elisp-lsp-bracket-diagnostics (uri text)
  "Bracket diagnostics for TEXT.
Returns vector of LSP diagnostic objects.
Includes structure summary, depth context, and error diagnostics."
  (elisp-lsp--with-parse-buffer
   uri text
   (lambda ()
     (let* ((result (elisp-lsp--analyze-structure))
            (trace (plist-get result :depth-trace))
            (line-info (plist-get trace :line-info))
            (max-depth (plist-get trace :max-depth))
            (total-pairs (length (plist-get result :all-pairs)))
            (paren-count (length (plist-get (plist-get result :pairs-by-type) :paren)))
            (bracket-count (length (plist-get (plist-get result :pairs-by-type) :bracket)))
            (brace-count (length (plist-get (plist-get result :pairs-by-type) :brace)))
            (unmatched-count (length (plist-get result :unmatched)))
            (mismatched-count (length (plist-get result :mismatched)))
            (diags '()))
       ;; Structure summary (info at line 0)
       (let ((total-lines (1+ (count-lines (point-min) (point-max)))))
         (push (list :range (list :start (list :line 0 :character 0)
                                  :end (list :line 0 :character 0))
                     :severity 3
                     :code "bracket-structure"
                     :source "elisp-lsp-brackets"
                     :message (format
                               "Bracket structure: depth %d, %d pairs (p:%d b:%d B:%d), %d lines%s%s"
                               max-depth total-pairs
                               paren-count bracket-count brace-count
                               total-lines
                               (if (> unmatched-count 0)
                                   (format " | %d unmatched" unmatched-count) "")
                               (if (> mismatched-count 0)
                                   (format " | %d mismatched" mismatched-count) "")))
               diags))
       ;; Depth context: annotate lines where depth changes significantly
       (let ((prev-depth 0))
         (dotimes (i (length line-info))
           (when (aref line-info i)
             (let* ((li (aref line-info i))
                    (line (plist-get li :line))
                    (depth-max (plist-get li :depth-max))
                    (depth-start (plist-get li :depth-start))
                    (opens (plist-get li :opens)))
               ;; Annotate when depth changes by 2+ or reaches new max
               (when (or (>= depth-max (+ prev-depth 2))
                         (and (> depth-max 0) (= depth-max max-depth)))
                 (let ((ctx (if opens
                                (mapconcat (lambda (o)
                                             (format "%c@%d" (plist-get o :char) (plist-get o :depth)))
                                           opens " ")
                              "")))
                   (push (list :range (list :start (list :line line :character 0)
                                            :end (list :line line :character 0))
                               :severity 3
                               :code "bracket-context"
                               :source "elisp-lsp-brackets"
                               :message (format "Depth %d-%d | %s"
                                                depth-start depth-max ctx))
                         diags)))
               (setq prev-depth depth-max)))))
       ;; Unmatched brackets
       (dolist (u (plist-get result :unmatched))
         (let ((line (plist-get u :line))
               (col (plist-get u :col)))
           (push (list :range (list :start (list :line line :character col)
                                    :end (list :line line :character (1+ col)))
                       :severity 1
                       :code "unmatched"
                       :source "elisp-lsp-brackets"
                       :message (plist-get u :message))
                 diags)))
       ;; Mismatched brackets
       (dolist (m (plist-get result :mismatched))
         (let ((line (plist-get m :line))
               (col (plist-get m :col)))
           (push (list :range (list :start (list :line line :character col)
                                    :end (list :line line :character (1+ col)))
                       :severity 1
                       :code "mismatched"
                       :source "elisp-lsp-brackets"
                       :message (plist-get m :message))
                 diags)))
       ;; Deep nesting warnings (depth > 8)
       (dotimes (i (length line-info))
         (when (aref line-info i)
           (let ((li (aref line-info i)))
             (when (> (plist-get li :depth-max) 8)
               (push (list :range (list :start (list :line (plist-get li :line) :character 0)
                                        :end (list :line (plist-get li :line) :character 1))
                           :severity 2
                           :code "deep-nesting"
                           :source "elisp-lsp-brackets"
                           :message (format "Deep nesting: depth %d"
                                            (plist-get li :depth-max)))
                     diags)))))
       (vconcat (nreverse diags))))))

(provide 'elisp-lsp-brackets)
;;; elisp-lsp-brackets.el ends here
