;;; elisp-lsp-diagnostics.el --- Diagnostics Provider -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides diagnostics for Emacs Lisp using byte-compile and checkdoc.

;;; Code:

(require 'elisp-lsp)

(defun elisp-lsp--run-byte-compile (file)
  "Run byte-compile on FILE and return diagnostics."
  (let ((diags nil)
        (temp-file (make-temp-file "elisp-lsp-byte-compile")))
    (with-temp-file temp-file
      (insert-file-contents file))
    (with-current-buffer (generate-new-buffer " *byte-compile*")
      (let ((exit-code (call-process "emacs" nil t nil
                                     "-Q" "--batch"
                                     "-f" "batch-byte-compile"
                                     temp-file)))
        (goto-char (point-min))
        (while (re-search-forward "^.*:\\([0-9]+\\):\\([0-9]+\\): \\(Warning\\|Error\\): \\(.*\\)$" nil t)
          (let ((line (string-to-number (match-string 1)))
                (col (string-to-number (match-string 2)))
                (type (match-string 3))
                (msg (match-string 4)))
            (push `(:range (:start (:line ,(1- line) :character ,(1- col))
                           :end (:line ,(1- line) :character ,col))
                  :severity ,(if (string= type "Error") 1 2)
                  :message ,msg
                  :source "byte-compile")
                  diags)))
        (kill-buffer)))
    (ignore-errors (delete-file temp-file))
    (nreverse diags)))

(defun elisp-lsp--run-checkdoc (file)
  "Run checkdoc on FILE and return diagnostics."
  (let ((diags nil))
    (with-current-buffer (generate-new-buffer " *checkdoc*")
      (insert-file-contents file)
      (goto-char (point-min))
      (let ((checkdoc-diagnostic nil))
        ;; Simple checkdoc checks
        (when (not (re-search-forward "^;;; .* --- " nil t))
          (push `(:range (:start (:line 0 :character 0)
                         :end (:line 0 :character 0))
                :severity 3
                :message "File should start with \";;; filename --- description\""
                :source "checkdoc")
                diags))
        (goto-char (point-min))
        (when (not (re-search-forward "^;;; Commentary:" nil t))
          (push `(:range (:start (:line 0 :character 0)
                         :end (:line 0 :character 0))
                :severity 3
                :message "Missing \";;; Commentary:\" section"
                :source "checkdoc")
                diags))
        (goto-char (point-min))
        (when (not (re-search-forward "^;;; Code:" nil t))
          (push `(:range (:start (:line 0 :character 0)
                         :end (:line 0 :character 0))
                :severity 3
                :message "Missing \";;; Code:\" section"
                :source "checkdoc")
                diags)))
      (kill-buffer))
    (nreverse diags)))

(defun elisp-lsp--get-diagnostics (uri)
  "Get diagnostics for URI."
  (let ((path (elisp-lsp--uri-to-path uri)))
    (when (and path (file-exists-p path))
      (append (elisp-lsp--run-byte-compile path)
              (elisp-lsp--run-checkdoc path)))))

(defun elisp-lsp--publish-diagnostics (uri)
  "Publish diagnostics for URI."
  (let ((diags (elisp-lsp--get-diagnostics uri)))
    (elisp-lsp--send-notification
     "textDocument/publishDiagnostics"
     `(:uri ,uri
       :diagnostics ,(vconcat diags)))))

(provide 'elisp-lsp-diagnostics)
;;; elisp-lsp-diagnostics.el ends here
