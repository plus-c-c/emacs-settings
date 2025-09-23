(use-package markdown-mode
  :custom
  (markdown-command "pandoc -f markdown -t html")
  :ensure t
  :defer t)
(use-package typescript-mode
  :ensure t
  :defer t)
(use-package racket-mode
  :ensure t
  :config
  (add-to-list 'language-modes-list 'racket-mode)
  :defer t
  :mode ("\\.rktl\\'" . racket-mode)
  )

(use-package jtsx
  :ensure t
  :mode (("\\.jsx\\'" . jtsx-js-mode)
	 ("\\.tsx\\'" . jtsx-tsx-mode))
  :defer t)
(diminish 'eldoc-mode)
;mindmap
(defun plantuml-jar-version ()
  "get plantuml.jar version"
  "v1.2025.7")
(defun plantuml-jar-online-path ()
  (concat "https://github.com/plantuml/plantuml/releases/download/"
	  (plantuml-jar-version)
	  "/plantuml.jar"))
(use-package plantuml-mode
  :ensure t
  :custom
  (plantuml-jar-path
   (expand-file-name
    "plantuml.jar"
    (expand-directory-name-auto-create "plantuml" user-emacs-directory)))
  :config
  (if (not (file-exists-p plantuml-jar-path))
      (prog1
	  (message "Downloading plantuml.jar")
	  (auto-download-from-web (plantuml-jar-online-path) plantuml-jar-path)
	  ))
  )
(provide 'config-lang-modes)
