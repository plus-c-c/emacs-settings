;;; config-lang-list.el --- Language list and babel configuration -*- lexical-binding: t -*-

(add-to-list 'load-path (expand-file-name "dev/lang" emacs-config-path))

(defun add-hook-list (list function)
  "Add FUNCTION to each hook in LIST."
  (dolist (hook list)
    (add-hook hook function)))

(defun set-language-protocol (name hook treesit-source)
  "Register NAME with HOOK and TREE-SOURCE for treesit."
  (add-to-list 'language-hooks-list hook)
  (add-to-list 'treesit-language-source-alist-custom
       (cons name treesit-source))
  (add-hook hook `(lambda () (treesit-parser-create ',name))))

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

(require 'config-r)

(require 'config-plantuml)
(require 'config-mermaid)

(require 'config-java)

(require 'config-shell)

(require 'config-typescript)

(org-babel-do-load-languages
 'org-babel-load-languages
 org-babel-custom-load-languages)
(setq org-src-preserve-indentation t)
(setq treesit-language-source-alist treesit-language-source-alist-custom)
(provide 'config-lang-list)
