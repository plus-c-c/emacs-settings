(add-to-list 'load-path (expand-file-name "codes/lang" emacs-config-path))

(defun add-hook-list (list function)
  (dolist (hook list)
    (add-hook hook function))
  )

(defun set-language-protocol (name hook treesit-source)
  (add-to-list 'language-hooks-list hook)
  (add-to-list 'treesit-language-source-alist-custom
	     (cons name treesit-source))
  (add-hook hook (eval `(lambda () (treesit-parser-create ',name))))
  )

(defvar org-babel-custom-load-languages '()
  "Custom org babel load languages.")
(defvar language-hooks-list
  '()
  "Language hooks for LSP&Fingertip.")
(defvar lisp-mode-list '(lisp-mode) "Modes belonging to lisp mode.")
(defvar treesit-language-source-alist-custom '() "Custom treesit-language-source-alist.")
(require 'config-emacs-lisp)
(require 'config-racket)

(require 'config-python)

(require 'config-R)

(require 'config-plantuml)
(require 'config-mermaid)

(require 'config-typescript)

(org-babel-do-load-languages
 'org-babel-load-languages
 org-babel-custom-load-languages)

(setq treesit-language-source-alist treesit-language-source-alist-custom)
(provide 'config-lang-list)
