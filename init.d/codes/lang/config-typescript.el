
(use-package jtsx
  :ensure t
  :mode (("\\.jsx\\'" . jtsx-js-mode)
	 ("\\.tsx\\'" . jtsx-tsx-mode))
  :defer t)

(add-to-list 'language-hooks-list 'typescript-ts-mode-hook)
;(add-to-list 'treesit-language-source-alist-custom
;             '(javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
;	     )
(add-to-list 'treesit-language-source-alist-custom
             '(typescript . ("https://github.com/tree-sitter/tree-sitter-typescript"
			     nil
			     "typescript/src"))
	     )
(set-language-protocol 'typescript 'typescript-ts-mode-hook
		       '("https://github.com/tree-sitter/tree-sitter-typescript"
			 nil
			 "typescript/src"))
(provide 'config-typescript)
