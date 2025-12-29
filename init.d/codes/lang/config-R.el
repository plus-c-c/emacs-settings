(use-package ess :ensure t)
(add-to-list 'org-babel-custom-load-languages '(R . t))

(set-language-protocol 'r 'ess-r-mode-hook
		       '("https://github.com/r-lib/tree-sitter-r.git"))
(provide 'config-R)
