;;; elisp-lsp-completion.el --- Completion Provider -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides completion for Emacs Lisp symbols.

;;; Code:

(require 'elisp-lsp)

(defun elisp-lsp--get-completions (prefix)
  "Get completions for PREFIX."
  (let ((completions nil))
    ;; Complete functions
    (mapatoms
     (lambda (sym)
       (when (and (fboundp sym)
                  (string-prefix-p prefix (symbol-name sym)))
         (push `(:label ,(symbol-name sym)
                 :kind 3  ; Function
                 :detail ,(documentation sym t))
               completions)))
     obarray)
    ;; Complete variables
    (mapatoms
     (lambda (sym)
       (when (and (boundp sym)
                  (string-prefix-p prefix (symbol-name sym))
                  (not (assoc (symbol-name sym) completions)))
         (push `(:label ,(symbol-name sym)
                 :kind 6  ; Variable
                 :detail ,(format "%s" (symbol-value sym)))
               completions)))
     obarray)
    ;; Complete keywords
    (mapatoms
     (lambda (sym)
       (when (and (keywordp sym)
                  (string-prefix-p prefix (symbol-name sym))
                  (not (assoc (symbol-name sym) completions)))
         (push `(:label ,(symbol-name sym)
                 :kind 14  ; Keyword
                 :detail "keyword")
               completions)))
     obarray)
    completions))

(defun elisp-lsp--get-completion-item (label)
  "Get completion item for LABEL."
  (let ((sym (intern-soft label)))
    `(:label ,label
      :kind (cond
             ((fboundp sym) 3)   ; Function
             ((boundp sym) 6)    ; Variable
             ((keywordp sym) 14) ; Keyword
             (t 1))              ; Text
      :detail ,(cond
                ((fboundp sym) (documentation sym t))
                ((boundp sym) (format "%s" (symbol-value sym)))
                (t "")))))

(defun elisp-lsp--handle-completion (id params)
  "Handle textDocument/completion request with ID and PARAMS."
  (let* ((text-document (plist-get params :textDocument))
         (uri (plist-get text-document :uri))
         (position (plist-get params :position))
         (line (plist-get position :line))
         (character (plist-get position :character))
         (text (elisp-lsp--get-buffer-text uri)))
    (when text
      (with-temp-buffer
        (insert text)
        (goto-char (point-min))
        (forward-line line)
        (forward-char character)
        ;; Find prefix
        (let* ((start (point))
               (prefix (buffer-substring-no-properties
                        (progn (skip-chars-backward "a-zA-Z0-9_-") (point))
                        start))
               (completions (elisp-lsp--get-completions prefix)))
          (elisp-lsp--send-response
           id
           `(:isIncomplete nil
             :items ,(vconcat (mapcar (lambda (c) (elisp-lsp--get-completion-item (plist-get c :label)))
                                      completions)))))))))

(provide 'elisp-lsp-completion)
;;; elisp-lsp-completion.el ends here
