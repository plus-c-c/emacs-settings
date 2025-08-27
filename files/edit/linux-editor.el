(use-package auto-save :load-path "~/.emacs.d/site-lisp/auto-save"
  :custom
  (auto-save-idle 10)
  (auto-save-silent t)
  (auto-save-delete-trailing-whitespace t)
  (auto-save-disable-predicates
	'((lambda ()
      (string-suffix-p
       "gpg"
      (file-name-extension (buffer-name)) t))))
  :config
  (auto-save-enable)
  )
(provide 'linux-editor)
