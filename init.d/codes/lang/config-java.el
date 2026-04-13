(add-to-list 'auto-mode-alist '("\\.kt\\'" . java-ts-mode))
(set-language-protocol 'java 'java-ts-mode-hook
		       '("https://github.com/6cdh/tree-sitter-racket.git"))
(provide 'config-java)
