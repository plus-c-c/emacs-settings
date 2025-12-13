(use-package markdown-mode
  :custom
  (markdown-command "pandoc -f markdown -t html")
  :ensure t
  :defer t)

;;;elisp
(diminish 'eldoc-mode)
(use-package racket-mode
  :ensure t
  :config
  (add-to-list 'language-modes-list 'racket-mode)
  :defer t
  :mode ("\\.rktl\\'" . racket-mode)
  )

;;;python
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

;;;js
(use-package typescript-mode
  :ensure t
  :defer t)
(use-package jtsx
  :ensure t
  :mode (("\\.jsx\\'" . jtsx-js-mode)
	 ("\\.tsx\\'" . jtsx-tsx-mode))
  :defer t)


;;;mindmap
(defun plantuml-jar-online-path ()
  (concat "https://github.com/plantuml/plantuml/releases/latest/download/"
	  "/plantuml.jar"))
(use-package plantuml-mode
  :ensure t
  :custom
  (plantuml-jar-path
   (expand-file-name
    "plantuml.jar"
    (expand-directory-name-auto-create "plantuml" user-emacs-directory)))
  )
(if (eq system-type 'gnu/linux)
    (setq plantuml-default-exec-mode 'executable)
  (setq plantuml-default-exec-mode 'jar)
  )
(if (not (file-exists-p plantuml-jar-path))
    (prog1
	(message "Downloading plantuml.jar")
      (auto-download-from-web (plantuml-jar-online-path) plantuml-jar-path)
      ))

(setq org-plantuml-exec-mode 'plantuml)

(use-package mermaid-mode
  :ensure t)
(use-package ob-mermaid
  :ensure t
  :custom (ob-mermaid-cli-path "mmdc"))
;;;graph
(use-package ess :ensure t)

;;;tex

;;;babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   (python . t)
   (plantuml . t)
   (R . t)
   (mermaid . t)
   ))
(setq org-confirm-babel-evaluate nil)
(provide 'config-lang-modes)
