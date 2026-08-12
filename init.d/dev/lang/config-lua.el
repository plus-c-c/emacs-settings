;;; config-lua.el --- Lua configuration -*- lexical-binding: t; -*-

(setq lsp-bridge-lua-lsp-server "sumneko")

(add-to-list 'auto-mode-alist '("\\.lua\\'" . lua-ts-mode))

(add-to-list 'org-babel-custom-load-languages '(lua . t))

(set-language-protocol 'lua 'lua-ts-mode-hook
           '("https://github.com/tree-sitter/tree-sitter-lua"))

(provide 'config-lua)
;;; config-lua.el ends here
