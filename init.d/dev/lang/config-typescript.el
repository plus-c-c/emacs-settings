;;; config-typescript.el --- TypeScript configuration -*- lexical-binding: t; -*-

(use-package jtsx
  :ensure t
  :mode (("\\.jsx\\'" . jtsx-js-mode)
         ("\\.tsx\\'" . jtsx-tsx-mode))
  :defer t)

(set-language-protocol 'typescript 'typescript-ts-mode-hook
           '("https://github.com/tree-sitter/tree-sitter-typescript"
             nil
             "typescript/src"))

;; DAP configuration for TypeScript/JavaScript (vscode-js-debug)
;; Adapter already installed at ~/.emacs.d/debug-adapters/js-debug/
(with-eval-after-load 'dape
  (add-to-list 'dape-configs
               '(js-debug-node
                 modes (js-mode js-ts-mode)
                 ensure (lambda (config)
                          (dape-ensure-command config)
                          (let ((dap-debug-server-path
                                 (car (plist-get config 'command-args))))
                            (unless (file-exists-p dap-debug-server-path)
                              (user-error "File %S does not exist" dap-debug-server-path))))
                 command "node"
                 command-args ((expand-file-name
                                (file-name-concat dape-adapter-dir
                                                  "js-debug"
                                                  "src"
                                                  "dapDebugServer.js"))
                              :autoport)
                 port :autoport
                 :type "pwa-node"
                 :cwd dape-cwd
                 :program dape-buffer-default
                 :console "internalConsole"))
  (add-to-list 'dape-configs
               '(js-debug-ts-node
                 modes (typescript-mode typescript-ts-mode)
                 ensure (lambda (config)
                          (dape-ensure-command config)
                          (let ((dap-debug-server-path
                                 (car (plist-get config 'command-args))))
                            (unless (file-exists-p dap-debug-server-path)
                              (user-error "File %S does not exist" dap-debug-server-path))))
                 command "node"
                 command-args ((expand-file-name
                                (file-name-concat dape-adapter-dir
                                                  "js-debug"
                                                  "src"
                                                  "dapDebugServer.js"))
                              :autoport)
                 port :autoport
                 :type "pwa-node"
                 :cwd dape-cwd
                 :program dape-buffer-default
                 :console "internalConsole")))

(provide 'config-typescript)
;;; config-typescript.el ends here
