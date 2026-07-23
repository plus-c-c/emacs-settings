;;; elisp-lsp-daemon.el --- Daemon-side LSP handler -*- lexical-binding: t; -*-
;;; Commentary: Functions loaded into Emacs daemon to handle LSP operations.
;;; Code:
(require 'json)

(defvar elisp-lsp-daemon-initialized nil)

(defun elisp-lsp-daemon-init ()
  "Initialize."
  (unless elisp-lsp-daemon-initialized
    (setq elisp-lsp-daemon-initialized t)
    (message "elisp-lsp-daemon: initialized")))

(defun elisp-lsp--make-response (id result)
  "Make response."
  (json-encode `(:jsonrpc "2.0" :id ,id :result ,result)))

(defun elisp-lsp--make-notification (method params)
  "Make notification."
  (json-encode `(:jsonrpc "2.0" :method ,method :params ,params)))

(defun elisp-lsp-sync-buffer (uri text)
  "Sync buffer."
  (let* ((path (if (string-prefix-p "file://" uri) (substring uri 7) uri))
         (buf (get-buffer-create (format " *elisp-lsp:%s*" uri))))
    (with-current-buffer buf
      (erase-buffer)
      (insert text)
      (delay-mode-hooks (emacs-lisp-mode))
      (setq-local buffer-file-name path)
      buf)))

(defun elisp-lsp--get-buffer (uri)
  "Get buffer."
  (get-buffer (format " *elisp-lsp:%s*" uri)))

(defun elisp-lsp-hover (uri line character)
  "Hover."
  (let ((buf (elisp-lsp--get-buffer uri)))
    (when buf
      (with-current-buffer buf
        (goto-char (point-min))
        (forward-line line)
        (forward-char (min character (1- (line-end-position))))
        (let ((sym (symbol-at-point)))
          (when sym
            (let ((desc (cond
                         ((fboundp sym)
                          (format "```elisp\n%s\n```\n\n%s"
                                  (format "(%s ...)" sym)
                                  (or (documentation sym t) "")))
                         ((boundp sym)
                          (format "```elisp\n%s = %s\n```"
                                  sym (prin1-to-string (symbol-value sym))))
                         (t (format "`%s`" sym)))))
              (list :contents (list :kind "markdown" :value desc)
                    :range (list :start (list :line line :character character)
                                  :end (list :line line :character (1+ character)))))))))))

(defun elisp-lsp-complete (uri line character)
  "Complete."
  (let ((buf (elisp-lsp--get-buffer uri)))
    (when buf
      (with-current-buffer buf
        (goto-char (point-min))
        (forward-line line)
        (forward-char (min character (1- (line-end-position))))
        (let* ((bounds (bounds-of-thing-at-point 'symbol))
               (start (if bounds (car bounds) (point)))
               (end (if bounds (cdr bounds) (point)))
               (prefix (buffer-substring-no-properties start end))
               (completions '()))
          (mapatoms
           (lambda (sym)
             (when (string-prefix-p prefix (symbol-name sym))
               (push (list :label (symbol-name sym)
                           :kind (cond ((fboundp sym) 3) ((boundp sym) 6) (t 1))
                           :detail (condition-case nil
                                       (or (documentation sym t) "")
                                     (error "")))
                     completions)))
           obarray)
          (list :isIncomplete json-false
                :items (vconcat (nreverse completions))))))))

(defun elisp-lsp-get-diagnostics (uri)
  "Diagnostics."
  (let ((path (if (string-prefix-p "file://" uri) (substring uri 7) uri))
        (diags '()))
    (when (and path (file-exists-p path))
      (let ((temp-file (make-temp-file "elisp-lsp-check")))
        (with-temp-file temp-file (insert-file-contents path))
        (with-current-buffer (generate-new-buffer " *bytecompile*")
          (call-process "emacs" nil t nil "-Q" "--batch"
                        "-f" "batch-byte-compile" temp-file)
          (goto-char (point-min))
          (while (re-search-forward
                  "\\(.+?\\):\\([0-9]+\\):\\([0-9]+\\): \\(Warning\\|Error\\): \\(.+\\)" nil t)
            (let ((ln (string-to-number (match-string 2)))
                  (col (string-to-number (match-string 3)))
                  (tp (match-string 4))
                  (msg (match-string 5)))
              (push (list :range (list :start (list :line (1- ln) :character (1- col))
                                       :end (list :line (1- ln) :character (+ col 10)))
                          :severity (if (string= tp "Error") 1 2)
                          :message msg
                          :source "byte-compile")
                    diags)))
          (kill-buffer))
        (ignore-errors (delete-file temp-file)))
      (vconcat (nreverse diags)))))

(defun elisp-lsp-process-message (message-json)
  "Process message."
  (let* ((parsed (json-read-from-string message-json))
         (id (alist-get 'id parsed))
         (method (alist-get 'method parsed))
         (params (alist-get 'params parsed))
         (result nil))
    (pcase method
      ("initialize"
       (setq result
             (list :capabilities
                   (list :textDocumentSync (list :openClose t :change 1 :save t)
                         :hoverProvider t
                         :completionProvider (list :resolveProvider json-false
                                                   :triggerCharacters ["(" " " "-"])
                         :publishDiagnostics t))))
      ("textDocument/hover"
       (setq result
             (elisp-lsp-hover
              (plist-get (plist-get params :textDocument) :uri)
              (plist-get (plist-get params :position) :line)
              (plist-get (plist-get params :position) :character))))
      ("textDocument/completion"
       (setq result
             (elisp-lsp-complete
              (plist-get (plist-get params :textDocument) :uri)
              (plist-get (plist-get params :position) :line)
              (plist-get (plist-get params :position) :character))))
      ("textDocument/didOpen"
       (let ((uri (plist-get (plist-get params :textDocument) :uri)))
         (elisp-lsp-sync-buffer uri (plist-get (plist-get params :textDocument) :text))
         (let ((diags (elisp-lsp-get-diagnostics uri)))
           (when diags
             (princ (elisp-lsp--make-notification
                     "textDocument/publishDiagnostics"
                     (list :uri uri :diagnostics diags)))))))
      ("textDocument/didChange"
       (let ((uri (plist-get (plist-get params :textDocument) :uri)))
         (when (> (length (plist-get params :contentChanges)) 0)
           (elisp-lsp-sync-buffer uri
                                  (plist-get (aref (plist-get params :contentChanges) 0) :text)))
         (let ((diags (elisp-lsp-get-diagnostics uri)))
           (when diags
             (princ (elisp-lsp--make-notification
                     "textDocument/publishDiagnostics"
                     (list :uri uri :diagnostics diags)))))))
      ("textDocument/didSave"
       (let ((uri (plist-get (plist-get params :textDocument) :uri)))
         (let ((diags (elisp-lsp-get-diagnostics uri)))
           (when diags
             (princ (elisp-lsp--make-notification
                     "textDocument/publishDiagnostics"
                     (list :uri uri :diagnostics diags)))))))
      (_ nil))
    (when id (elisp-lsp--make-response id result))))

(defun elisp-lsp-hover-json (uri line character)
  "Hover, print JSON to stdout."
  (let ((result (elisp-lsp-hover uri line character)))
    (princ (if result (json-encode result) "null"))))

(defun elisp-lsp-complete-json (uri line character)
  "Complete, print JSON to stdout."
  (let ((result (elisp-lsp-complete uri line character)))
    (princ (if result (json-encode result) "null"))))

(defun elisp-lsp-diagnostics-json (uri)
  "Diagnostics, print JSON to stdout."
  (let ((result (elisp-lsp-get-diagnostics uri)))
    (princ (if result (json-encode result) "null"))))

(provide 'elisp-lsp-daemon)
;;; elisp-lsp-daemon.el ends here
