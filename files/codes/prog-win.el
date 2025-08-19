(use-package company
  :ensure t
  :diminish company-mode
  :config
  (global-company-mode)
  (setq company-idle-delay 0.5)
  (setq company-minimum-prefix-length 3))
(use-package lsp-mode
  :defer t
  :custom
  (lsp-keymap-prefix "C-c l")
  :hook
    ((c-mode-common
    c-mode
    c++-mode
    java-mode
    haskell-mode
    maxima-mode
    ielm-mode
    sh-mode
    makefile-gmake-mode
    php-mode
    python-mode
    js-mode
    go-mode
    qml-mode
    jade-mode
    css-mode
    ruby-mode
    coffee-mode
    rust-mode
    qmake-mode
    lua-mode
    swift-mode
    typescript-mode
    minibuffer-inactive-mode) .
    lsp-deferred)
  :ensure t)
(use-package dap-mode
  :defer 1.5
  :after lsp-mode
  :ensure t)
(provide 'prog-win)
