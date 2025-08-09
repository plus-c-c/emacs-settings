
(setq treesit-language-source-alist
      '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
        (c . ("https://github.com/tree-sitter/tree-sitter-c"))
        (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
        (css . ("https://github.com/tree-sitter/tree-sitter-css"))
        (cmake . ("https://github.com/uyha/tree-sitter-cmake"))
        (csharp     . ("https://github.com/tree-sitter/tree-sitter-c-sharp.git"))
        (dockerfile . ("https://github.com/camdencheek/tree-sitter-dockerfile"))
        (elisp . ("https://github.com/Wilfred/tree-sitter-elisp"))
        (go . ("https://github.com/tree-sitter/tree-sitter-go"))
        (gomod      . ("https://github.com/camdencheek/tree-sitter-go-mod.git"))
        (html . ("https://github.com/tree-sitter/tree-sitter-html"))
        (java       . ("https://github.com/tree-sitter/tree-sitter-java.git"))
        (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
        (json . ("https://github.com/tree-sitter/tree-sitter-json"))
        (lua . ("https://github.com/Azganoth/tree-sitter-lua"))
        (make . ("https://github.com/alemuller/tree-sitter-make"))
        (markdown . ("https://github.com/MDeiml/tree-sitter-markdown" nil "tree-sitter-markdown/src"))
        (ocaml . ("https://github.com/tree-sitter/tree-sitter-ocaml" nil "ocaml/src"))
        (org . ("https://github.com/milisims/tree-sitter-org"))
        (python . ("https://github.com/tree-sitter/tree-sitter-python"))
        (php . ("https://github.com/tree-sitter/tree-sitter-php"))
        (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" nil "typescript/src"))
        (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" nil "tsx/src"))
        (ruby . ("https://github.com/tree-sitter/tree-sitter-ruby"))
        (racket . ("https://github.com/6cdh/tree-sitter-racket.git"))
        (rust . ("https://github.com/tree-sitter/tree-sitter-rust"))
        (sql . ("https://github.com/m-novikov/tree-sitter-sql"))
        (vue . ("https://github.com/merico-dev/tree-sitter-vue"))
        (yaml . ("https://github.com/ikatyang/tree-sitter-yaml"))
        (toml . ("https://github.com/tree-sitter/tree-sitter-toml"))
        (zig . ("https://github.com/GrayJack/tree-sitter-zig"))))
(add-hook 'markdown-mode-hook #'(lambda () (treesit-parser-create 'markdown)))
(add-hook 'zig-mode-hook #'(lambda () (treesit-parser-create 'zig)))

(add-hook 'emacs-lisp-mode-hook #'(lambda () (treesit-parser-create 'elisp)))
(add-hook 'racket-mode-hook #'(lambda () (treesit-parser-create 'racket)))

(add-hook 'ielm-mode-hook #'(lambda () (treesit-parser-create 'elisp)))

(add-hook 'json-mode-hook #'(lambda () (treesit-parser-create 'json)))

(add-hook 'go-mode-hook #'(lambda () (treesit-parser-create 'go)))

(add-hook 'java-mode-hook #'(lambda () (treesit-parser-create 'java)))
(add-hook 'java-ts-mode-hook #'(lambda () (treesit-parser-create 'java)))

(add-hook 'javascript-mode-hook #'(lambda () (treesit-parser-create 'javascript)))
(add-hook 'javascript-ts-mode-hook #'(lambda () (treesit-parser-create 'javascript)))
(add-hook 'typescript-mode-hook #'(lambda () (treesit-parser-create 'typescript)))
(add-hook 'typescript-ts-mode-hook #'(lambda () (treesit-parser-create 'typescript)))
(add-hook 'typescript-tsx-mode-hook #'(lambda () (treesit-parser-create 'tsx)))

(add-hook 'php-mode-hook #'(lambda () (treesit-parser-create 'php)))
(add-hook 'php-ts-mode-hook #'(lambda () (treesit-parser-create 'php)))

(add-hook 'sh-mode-hook #'(lambda () (treesit-parser-create 'bash)))
(add-hook 'sh-ts-mode-hook #'(lambda () (treesit-parser-create 'bash)))

(add-hook 'web-mode-hook #'(lambda ()
                             (let ((file-name (buffer-file-name)))
                               (when file-name
                                 (treesit-parser-create
                                  (pcase (file-name-extension file-name)
                                    ("vue" 'vue)
                                    ("html" 'html)
                                    ("php" 'php))))
                               )))
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install t)
  (treesit-font-lock-level 4)
  :config (global-treesit-auto-mode))

(use-package fingertip
  :load-path "~/.emacs.d/site-lisp/fingertip"
  :config
  (add-hook-list language-modes-list 'fingertip-mode)
  (define-key fingertip-mode-map (kbd "(") 'fingertip-open-round)
  (define-key fingertip-mode-map (kbd "[") 'fingertip-open-bracket)
  (define-key fingertip-mode-map (kbd "{") 'fingertip-open-curly)
  (define-key fingertip-mode-map (kbd ")") 'fingertip-close-round)
  (define-key fingertip-mode-map (kbd "]") 'fingertip-close-bracket)
  (define-key fingertip-mode-map (kbd "}") 'fingertip-close-curly)
  (define-key fingertip-mode-map (kbd "=") 'fingertip-equal)

  (define-key fingertip-mode-map (kbd "（") 'fingertip-open-chinese-round)
  (define-key fingertip-mode-map (kbd "「") 'fingertip-open-chinese-bracket)
  (define-key fingertip-mode-map (kbd "【") 'fingertip-open-chinese-curly)
  (define-key fingertip-mode-map (kbd "）") 'fingertip-close-chinese-round)
  (define-key fingertip-mode-map (kbd "」") 'fingertip-close-chinese-bracket)
  (define-key fingertip-mode-map (kbd "】") 'fingertip-close-chinese-curly)

  (define-key fingertip-mode-map (kbd "%") 'fingertip-match-paren)
  (define-key fingertip-mode-map (kbd "\"") 'fingertip-double-quote)
  (define-key fingertip-mode-map (kbd "'") 'fingertip-single-quote)

  (define-key fingertip-mode-map (kbd "SPC") 'fingertip-space)
  (define-key fingertip-mode-map (kbd "RET") 'fingertip-newline)

  (define-key fingertip-mode-map (kbd "M-o") 'fingertip-backward-delete)
  (define-key fingertip-mode-map (kbd "C-d") 'fingertip-forward-delete)
  (define-key fingertip-mode-map (kbd "C-k") 'fingertip-kill)

  (define-key fingertip-mode-map (kbd "M-\"") 'fingertip-wrap-double-quote)
  (define-key fingertip-mode-map (kbd "M-'") 'fingertip-wrap-single-quote)
  (define-key fingertip-mode-map (kbd "M-[") 'fingertip-wrap-bracket)
  (define-key fingertip-mode-map (kbd "M-{") 'fingertip-wrap-curly)
  (define-key fingertip-mode-map (kbd "M-(") 'fingertip-wrap-round)
  (define-key fingertip-mode-map (kbd "M-)") 'fingertip-unwrap)

  (define-key fingertip-mode-map (kbd "M-p") 'fingertip-jump-right)
  (define-key fingertip-mode-map (kbd "M-n") 'fingertip-jump-left)
  (define-key fingertip-mode-map (kbd "M-:") 'fingertip-jump-out-pair-and-newline)

  (define-key fingertip-mode-map (kbd "C-M-j") 'fingertip-jump-up)

  (defun fingertip-is-lisp-mode-p ()
    (or (derived-mode-p 'lisp-mode)
	(derived-mode-p 'racket-mode)
	(derived-mode-p 'emacs-lisp-mode)
	(derived-mode-p 'inferior-emacs-lisp-mode)
	(derived-mode-p 'clojure-mode)
	(derived-mode-p 'clojure-ts-mode)))
  )
(provide 'treesit-config)
