;;; elisp-lsp-bytecompile.el --- Batch byte-compile helper -*- lexical-binding: t; -*-

;;; Commentary:
;; Helper for batch byte-compilation diagnostics.

;;; Code:

(defun elisp-lsp-batch-byte-compile ()
  "Byte compile file specified in `command-line-args-left'."
  (let ((file (car command-line-args-left)))
    (when file
      (setq byte-compile-warnings t)
      (setq byte-compile-error-on-warn nil)
      (batch-byte-compile))))

(provide 'elisp-lsp-bytecompile)
;;; elisp-lsp-bytecompile.el ends here
