(diminish 'eldoc-mode)

(add-to-list 'org-babel-custom-load-languages '(emacs-lisp . t))

(add-to-list 'lisp-mode-list 'lisp-interaction-mode)
(add-to-list 'lisp-mode-list 'emacs-lisp-mode)

(set-language-protocol 'elisp 'emacs-lisp-mode-hook
		       '("https://github.com/Wilfred/tree-sitter-elisp"))
(provide 'config-emacs-lisp)
