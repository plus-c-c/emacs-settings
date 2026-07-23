;;; config-java.el --- Java/Kotlin configuration -*- lexical-binding: t; -*-

(add-to-list 'auto-mode-alist '("\\.kt\\'" . java-ts-mode))

(set-language-protocol 'java 'java-ts-mode-hook
           '("https://github.com/tree-sitter/tree-sitter-java"))

;; DAP configuration for Java (JDTLS with Java Debug Server)
;; Requires JDTLS running with java-debug plugin
;; See: https://github.com/microsoft/java-debug
(with-eval-after-load 'dape
  (add-to-list 'dape-configs
               '(java-debug
                 modes (java-mode java-ts-mode)
                 ensure (lambda (config)
                          (unless (executable-find "jdtls")
                            (user-error "jdtls executable not found")))
                 command "jdtls"
                 :request "launch"
                 :type "java"
                 :cwd dape-cwd
                 :program dape-buffer-default)))

(provide 'config-java)
;;; config-java.el ends here
