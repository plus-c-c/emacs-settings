;;; elisp-lsp-hover.el --- Hover Provider -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides hover information for Emacs Lisp symbols.

;;; Code:

(require 'elisp-lsp)

(defun elisp-lsp--describe-symbol (symbol)
  "Get documentation for SYMBOL."
  (let ((desc nil))
    ;; Check if it's a function
    (when (fboundp symbol)
      (setq desc (or (documentation symbol t)
                     (format "%s is a function" symbol))))
    ;; Check if it's a variable
    (when (boundp symbol)
      (let ((val (symbol-value symbol)))
        (setq desc (format "%s is a variable with value: %s" symbol (prin1-to-string val)))))
    ;; Check if it's a face
    (when (facep symbol)
      (setq desc (format "%s is a face" symbol)))
    desc))

(defun elisp-lsp--handle-hover (id params)
  "Handle textDocument/hover request with ID and PARAMS."
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
        ;; Try to find symbol at point
        (let ((symbol (ignore-errors (symbol-at-point))))
          (when symbol
            (let ((desc (elisp-lsp--describe-symbol symbol)))
              (when desc
                (elisp-lsp--send-response
                 id
                 `(:contents (:kind "markdown"
                              :value ,(format "```elisp\n%s\n```" desc))
                   :range (:start (:line ,line :character ,character)
                           :end (:line ,line :character ,(1+ character)))))))))))))

(provide 'elisp-lsp-hover)
;;; elisp-lsp-hover.el ends here
