;;; elisp-lsp.el --- Minimal Elisp LSP Server via Emacs Daemon -*- lexical-binding: t; -*-

;;; Commentary:
;; A minimal LSP server for Emacs Lisp that delegates to Emacs daemon via emacsclient.

;;; Code:

(require 'json)
(require 'cl-lib)

;; --- State ---
(defvar elisp-lsp--running-p t)
(defvar elisp-lsp--buffer-cache '()
  "Alist of (uri . text) for open buffers.")

;; --- Helpers ---
(defun elisp-lsp--send-response (id result)
  "Send JSON-RPC response."
  (let ((resp (json-encode `(:jsonrpc "2.0" :id ,id :result ,result))))
    (princ (format "Content-Length: %d\r\n\r\n%s" (string-bytes resp) resp))
    (force-standard-output)))

(defun elisp-lsp--send-notification (method params)
  "Send JSON-RPC notification."
  (let ((notif (json-encode `(:jsonrpc "2.0" :method ,method :params ,params))))
    (princ (format "Content-Length: %d\r\n\r\n%s" (string-bytes notif) notif))
    (force-standard-output)))

(defun elisp-lsp--uri-to-path (uri)
  (if (string-prefix-p "file://" uri) (substring uri 7) uri))

(defun elisp-lsp--path-to-uri (path)
  (concat "file://" (expand-file-name path)))

(defun elisp-lsp--daemon-eval (form-str)
  "Evaluate FORM-STR in Emacs daemon and return result."
  (let ((result (shell-command-to-string
                 (format "emacsclient -e '%s' 2>/dev/null"
                         (shell-quote-argument form-str)))))
    (string-trim result)))

(defun elisp-lsp--daemon-eval-json (form-str)
  "Evaluate FORM-STR in daemon, parse JSON result."
  (let ((raw (elisp-lsp--daemon-eval form-str)))
    (when (and raw (not (string-empty-p raw)))
      (ignore-errors (json-read-from-string raw)))))

;; --- Buffer Management ---
(defun elisp-lsp--sync-buffer (uri text)
  "Sync buffer content to daemon."
  (elisp-lsp--daemon-eval
   (format "(elisp-lsp-sync-buffer \"%s\" %S)" uri text)))

;; --- Request Handlers ---
(defun elisp-lsp--handle-initialize (id _params)
  (elisp-lsp--send-response
   id
   `(:capabilities
     (:textDocumentSync (:openClose t :change 1 :save t)
      :hoverProvider t
      :completionProvider (:resolveProvider json-false :triggerCharacters ["(" " " "-"])
      :publishDiagnostics t))))

(defun elisp-lsp--handle-did-open (_id params)
  (let* ((td (plist-get params :textDocument))
         (uri (plist-get td :uri))
         (text (plist-get td :text)))
    (push (cons uri text) elisp-lsp--buffer-cache)
    (elisp-lsp--sync-buffer uri text)
    ;; Publish diagnostics
    (let ((diags (elisp-lsp--daemon-eval-json
                  (format "(elisp-lsp-get-diagnostics \"%s\")" uri))))
      (when diags
        (elisp-lsp--send-notification
         "textDocument/publishDiagnostics"
         `(:uri ,uri :diagnostics ,diags))))))

(defun elisp-lsp--handle-did-change (_id params)
  (let* ((td (plist-get params :textDocument))
         (uri (plist-get td :uri))
         (changes (plist-get params :contentChanges)))
    (when (> (length changes) 0)
      (let ((new-text (plist-get (aref changes 0) :text)))
        (setq elisp-lsp--buffer-cache
              (cons (cons uri new-text)
                    (assq-delete-all uri elisp-lsp--buffer-cache)))
        (elisp-lsp--sync-buffer uri new-text)
        ;; Publish diagnostics
        (let ((diags (elisp-lsp--daemon-eval-json
                      (format "(elisp-lsp-get-diagnostics \"%s\")" uri))))
          (when diags
            (elisp-lsp--send-notification
             "textDocument/publishDiagnostics"
             `(:uri ,uri :diagnostics ,diags))))))))

(defun elisp-lsp--handle-did-save (_id params)
  (let* ((td (plist-get params :textDocument))
         (uri (plist-get td :uri)))
    (let ((diags (elisp-lsp--daemon-eval-json
                  (format "(elisp-lsp-get-diagnostics \"%s\")" uri))))
      (when diags
        (elisp-lsp--send-notification
         "textDocument/publishDiagnostics"
         `(:uri ,uri :diagnostics ,diags))))))

(defun elisp-lsp--handle-hover (id params)
  (let* ((td (plist-get params :textDocument))
         (uri (plist-get td :uri))
         (pos (plist-get params :position))
         (line (plist-get pos :line))
         (char (plist-get pos :character))
         (result (elisp-lsp--daemon-eval-json
                  (format "(elisp-lsp-hover \"%s\" %d %d)" uri line char))))
    (elisp-lsp--send-response id (or result `(:contents nil)))))

(defun elisp-lsp--handle-completion (id params)
  (let* ((td (plist-get params :textDocument))
         (uri (plist-get td :uri))
         (pos (plist-get params :position))
         (line (plist-get pos :line))
         (char (plist-get pos :character))
         (result (elisp-lsp--daemon-eval-json
                  (format "(elisp-lsp-complete \"%s\" %d %d)" uri line char))))
    (elisp-lsp--send-response
     id
     (or result `(:isIncomplete json-false :items [])))))

;; --- Dispatch ---
(defun elisp-lsp--dispatch (method id params)
  (pcase method
    ("initialize"              (elisp-lsp--handle-initialize id params))
    ("initialized"             nil)
    ("shutdown"                (setq elisp-lsp--running-p nil)
                               (elisp-lsp--send-response id nil))
    ("textDocument/hover"      (elisp-lsp--handle-hover id params))
    ("textDocument/completion" (elisp-lsp--handle-completion id params))
    ("textDocument/didOpen"    (elisp-lsp--handle-did-open id params))
    ("textDocument/didChange"  (elisp-lsp--handle-did-change id params))
    ("textDocument/didSave"    (elisp-lsp--handle-did-save id params))
    (_ (message "Unknown method: %s" method))))

;; --- LSP Protocol Parser ---
(defun elisp-lsp--read-headers ()
  "Read LSP message headers, return content-length."
  (let ((content-length 0)
        (line ""))
    (while (not (string= line "\r"))
      (setq line (read-string ""))
      (when (string-match "Content-Length: \\([0-9]+\\)" line)
        (setq content-length (string-to-number (match-string 1 line)))))
    content-length))

(defun elisp-lsp--read-body (length)
  "Read LSP message body of LENGTH bytes."
  (let ((body (make-string length ?\0)))
    (dotimes (i length)
      (let ((ch (read-char)))
        (when ch (aset body i ch))))
    body))

(defun elisp-lsp--read-message ()
  "Read one LSP message from stdin."
  (let ((content-length (elisp-lsp--read-headers)))
    (when (> content-length 0)
      (elisp-lsp--read-body content-length))))

;; --- Main ---
(defun elisp-lsp-main ()
  "Main loop."
  (message "elisp-lsp: starting...")
  (while elisp-lsp--running-p
    (condition-case err
        (let ((msg (elisp-lsp--read-message)))
          (when msg
            (let* ((parsed (json-read-from-string msg))
                   (id     (alist-get 'id parsed))
                   (method (alist-get 'method parsed))
                   (params (alist-get 'params parsed)))
              (when method
                (elisp-lsp--dispatch method id params)))))
      (error (message "elisp-lsp error: %s" (error-message-string err)))))
  (message "elisp-lsp: stopped."))

(provide 'elisp-lsp)
;;; elisp-lsp.el ends here
