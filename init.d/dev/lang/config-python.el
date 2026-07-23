;;; config-python.el --- Python configuration -*- lexical-binding: t; -*-

(setq lsp-bridge-python-lsp-server "pyright")
(setq lsp-bridge-python-multi-lsp-server "pyright_ruff")

(when (eq system-type 'gnu/linux)
  (setq lsp-bridge-python-command "/usr/bin/python3"))

(use-package pet
  :ensure t
  :diminish pet-mode)

(use-package pyvenv
  :ensure t
  :hook (python-base-mode . pyvenv-mode))

(add-hook 'python-base-mode-hook
          (lambda ()
            (setq-local pyvenv-activate (pet-virtualenv-root)))
          -10)

(add-hook 'pyvenv-post-activate-hooks
          (lambda ()
            (lsp-bridge-restart-process)))

(add-to-list 'org-babel-custom-load-languages '(python . t))

(set-language-protocol 'python 'python-base-mode-hook
           '("https://github.com/tree-sitter/tree-sitter-python"))

;; DAP configuration for Python (debugpy)
;; Ensure debugpy is installed: pip install debugpy
(with-eval-after-load 'dape
  (add-to-list 'dape-configs
               '(debugpy
                 modes (python-mode python-ts-mode)
                 ensure (lambda (config)
                          (dape-ensure-command config)
                          (let ((python (dape-config-get config 'command)))
                            (unless (zerop (process-file-shell-command
                                            (format "%s -c \"import debugpy.adapter\"" python)))
                              (user-error "%s module debugpy is not installed" python))))
                 command "python"
                 command-args ("-m" "debugpy.adapter" "--host" "0.0.0.0" "--port" :autoport)
                 port :autoport
                 :request "launch"
                 :type "python"
                 :cwd dape-cwd
                 :program dape-buffer-default
                 :args []
                 :justMyCode nil
                 :console "integratedTerminal"
                 :showReturnValue t
                 :stopOnEntry nil)))

(provide 'config-python)
;;; config-python.el ends here
