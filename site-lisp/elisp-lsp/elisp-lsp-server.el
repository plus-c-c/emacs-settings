;;; elisp-lsp-server.el --- Main LSP Server Entry Point -*- lexical-binding: t; -*-

;;; Commentary:
;; Main entry point for the minimal Elisp LSP server.

;;; Code:

(require 'elisp-lsp)
(require 'elisp-lsp-hover)
(require 'elisp-lsp-completion)
(require 'elisp-lsp-diagnostics)

(defun elisp-lsp--handle-initialize (id params)
  "Handle initialize request with ID and PARAMS."
  (elisp-lsp--send-response
   id
   `(:capabilities
     (:textDocumentSync (:openClose t :change 1 :save t)
      :hoverProvider t
      :completionProvider (:resolveProvider nil :triggerCharacters [" "])
      :publishDiagnostics t))))

(defun elisp-lsp--handle-did-open (params)
  "Handle textDocument/didOpen notification with PARAMS."
  (let* ((text-document (plist-get params :textDocument))
         (uri (plist-get text-document :uri))
         (text (plist-get text-document :text)))
    (push (cons uri text) elisp-lsp--buffer-list)
    ;; Publish diagnostics
    (elisp-lsp--publish-diagnostics uri)))

(defun elisp-lsp--handle-did-change (params)
  "Handle textDocument/didChange notification with PARAMS."
  (let* ((text-document (plist-get params :textDocument))
         (uri (plist-get text-document :uri))
         (content-changes (plist-get params :contentChanges)))
    ;; Update buffer content
    (when (> (length content-changes) 0)
      (let ((new-text (plist-get (aref content-changes 0) :text)))
        (setq elisp-lsp--buffer-list
              (cons (cons uri new-text)
                    (assq-delete-all uri elisp-lsp--buffer-list)))))
    ;; Publish diagnostics
    (elisp-lsp--publish-diagnostics uri)))

(defun elisp-lsp--handle-did-save (params)
  "Handle textDocument/didSave notification with PARAMS."
  (let* ((text-document (plist-get params :textDocument))
         (uri (plist-get text-document :uri)))
    ;; Re-publish diagnostics on save
    (elisp-lsp--publish-diagnostics uri)))

(defun elisp-lsp--process-request (method id params)
  "Process LSP request METHOD with ID and PARAMS."
  (cond
   ((string= method "initialize")
    (elisp-lsp--handle-initialize id params))
   ((string= method "initialized")
    nil)  ; No response needed
   ((string= method "shutdown")
    (setq elisp-lsp--running-p nil)
    (elisp-lsp--send-response id nil))
   ((string= method "textDocument/hover")
    (elisp-lsp--handle-hover id params))
   ((string= method "textDocument/completion")
    (elisp-lsp--handle-completion id params))
   ((string= method "textDocument/didOpen")
    (elisp-lsp--handle-did-open params))
   ((string= method "textDocument/didChange")
    (elisp-lsp--handle-did-change params))
   ((string= method "textDocument/didSave")
    (elisp-lsp--handle-did-save params))
   (t
    (message "Unknown method: %s" method))))

(defun elisp-lsp--read-message ()
  "Read a single LSP message from stdin."
  (let ((content-length nil)
        (line nil))
    ;; Read headers
    (while (progn
             (setq line (read-string ""))
             (not (string= line ""))))
    ;; Parse Content-Length
    (when (string-match "Content-Length: \\([0-9]+\\)" line)
      (setq content-length (string-to-number (match-string 1 line))))
    ;; Read body
    (when content-length
      (let ((body (make-string content-length ?\0)))
        (dotimes (i content-length)
          (aset body i (read-char)))
        body))))

(defun elisp-lsp--process-message (message)
  "Process a single JSON-RPC MESSAGE."
  (let ((parsed (json-read-from-string message)))
    (let ((id (alist-get 'id parsed))
          (method (alist-get 'method parsed))
          (params (alist-get 'params parsed)))
      (when method
        (elisp-lsp--process-request method id params)))))

(defun elisp-lsp--main ()
  "Main loop for the LSP server."
  (message "Starting Elisp LSP server...")
  (while elisp-lsp--running-p
    (condition-case err
        (let ((message (elisp-lsp--read-message)))
          (when message
            (elisp-lsp--process-message message)))
      (error
       (message "Error processing message: %s" (error-message-string err)))))
  (message "Elisp LSP server stopped."))

(provide 'elisp-lsp-server)
;;; elisp-lsp-server.el ends here
