;;; config-shell.el --- Shell configuration -*- lexical-binding: t; -*-

(add-to-list 'org-babel-custom-load-languages '(shell . t))

(set-language-protocol 'bash 'shell-mode-hook
           '("https://github.com/tree-sitter/tree-sitter-bash.git"))

;; DAP configuration for Bash/Shell (bash-debug)
;; Adapter already installed at ~/.emacs.d/debug-adapters/bash-debug/
(with-eval-after-load 'dape
  (add-to-list 'dape-configs
               '(bash-debug
                 modes (sh-mode bash-ts-mode)
                 ensure (lambda (config)
                          (dape-ensure-command config)
                          (let ((dap-debug-server-path
                                 (car (plist-get config 'command-args))))
                            (unless (file-exists-p dap-debug-server-path)
                              (user-error "File %S does not exist" dap-debug-server-path))))
                 command "node"
                 command-args ((expand-file-name
                                (file-name-concat dape-adapter-dir
                                                  "bash-debug"
                                                  "extension"
                                                  "out"
                                                  "bashDebug.js"))
                               :autoport)
                 port :autoport
                 fn (lambda (config)
                      (thread-first config
                                    (plist-put :pathBashdbLib
                                               (expand-file-name
                                                (file-name-concat dape-adapter-dir
                                                                  "bash-debug"
                                                                  "extension"
                                                                  "bashdb_dir")))
                                    (plist-put :pathBashdb
                                               (expand-file-name
                                                (file-name-concat dape-adapter-dir
                                                                  "bash-debug"
                                                                  "extension"
                                                                  "bashdb_dir"
                                                                  "bashdb")))
                                    (plist-put :env
                                               `(:BASHDB_HOME
                                                 ,(expand-file-name
                                                   (file-name-concat dape-adapter-dir
                                                                     "bash-debug"
                                                                     "extension"
                                                                     "bashdb_dir"))
                                                 . ,(plist-get config :env)))))
                 :type "bashdb"
                 :cwd dape-cwd
                 :program dape-buffer-default
                 :args []
                 :pathBash "bash"
                 :pathCat "cat"
                 :pathMkfifo "mkfifo"
                 :pathPkill "pkill")))

(provide 'config-shell)
;;; config-shell.el ends here
