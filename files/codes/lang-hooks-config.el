(defvar language-modes-list
  (list
   'racket-mode-hook
   'c-mode-common-hook
   'c-mode-hook
   'c++-mode-hook
   'java-mode-hook
   'haskell-mode-hook
   'emacs-lisp-mode-hook
   'lisp-interaction-mode-hook
   'lisp-mode-hook
   'maxima-mode-hook
   'ielm-mode-hook
   'sh-mode-hook
   'makefile-gmake-mode-hook
   'php-mode-hook
   'python-mode-hook
   'js-mode-hook
   'go-mode-hook
   'qml-mode-hook
   'jade-mode-hook
   'css-mode-hook
   'ruby-mode-hook
   'coffee-mode-hook
   'rust-mode-hook
   'rust-ts-mode-hook
   'qmake-mode-hook
   'lua-mode-hook
   'swift-mode-hook
   'web-mode-hook
   'markdown-mode-hook
   'llvm-mode-hook
   'conf-toml-mode-hook
   'nim-mode-hook
   'typescript-mode-hook
   'c-ts-mode-hook
   'c++-ts-mode-hook
   'cmake-ts-mode-hook
   'toml-ts-mode-hook
   'css-ts-mode-hook
   'js-ts-mode-hook
   'json-ts-mode-hook
   'python-ts-mode-hook
   'bash-ts-mode-hook
   'typescript-ts-mode-hook
   'tsx-ts-mode-hook
   )
  "A list of all language modes.")
(defun add-hook-list (list function)
  (dolist (hook list)
    (add-hook hook function))
  )
(provide 'lang-hooks-config)
