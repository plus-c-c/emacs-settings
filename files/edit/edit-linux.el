(use-package blink-search :commands blink-search
    :load-path "~/.emacs.d/site-lisp/blink-search"
    :ensure posframe
    :bind ("C-c b" . blink-search)
    :custom
    (blink-search-search-backends '())
    (blink-search-enable-posframe nil)
    (blink-search-browser-function 'eaf-open-browser)
    (blink-search-grep-pdf-backend 'eaf-pdf-viewer)
    )

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
(provide 'edit-linux)
