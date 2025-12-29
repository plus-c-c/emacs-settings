(setq lsp-bridge-python-lsp-server "pyright")
(setq lsp-bridge-python-multi-lsp-server "pyright_ruff")
(if (eq system-type 'gnu/linux)
    (setq lsp-bridge-python-command "/usr/bin/python3"))
(use-package pet :ensure t
  :diminish pet-mode)
(add-hook 'python-base-mode-hook 'pet-mode -10)
(use-package pyvenv :ensure t)

(add-hook 'python-base-mode-hook (lambda ()
				   (setq-local pyvenv-activate (pet-virtualenv-root))
				   (message (format "Setting virtual environment: %s" (pet-virtualenv-root)))
				   )
	  -9)
(pyvenv-mode)
(add-hook 'pyvenv-post-activate-hooks
          (lambda ()
            (lsp-bridge-restart-process)))

(add-to-list 'org-babel-custom-load-languages '(python . t))

(set-language-protocol 'python 'python-base-mode-hook
		       '("https://github.com/tree-sitter/tree-sitter-python"))
(provide 'config-python)
