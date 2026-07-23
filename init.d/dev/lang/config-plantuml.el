;;; config-plantuml.el --- PlantUML configuration -*- lexical-binding: t -*-

(defun plantuml-jar-online-path ()
  (concat "https://github.com/plantuml/plantuml/releases/latest/download/"
          "plantuml.jar"))

(use-package plantuml-mode
  :ensure t
  :custom
  (plantuml-jar-path
   (expand-file-name
    "plantuml.jar"
    (expand-directory-name-auto-create "plantuml" user-emacs-directory))))

(when (eq system-type 'gnu/linux)
  (setq plantuml-default-exec-mode 'executable))
(unless (eq system-type 'gnu/linux)
  (setq plantuml-default-exec-mode 'jar))

(unless (file-exists-p plantuml-jar-path)
  (message "Downloading plantuml.jar")
  (auto-download-from-web (plantuml-jar-online-path) plantuml-jar-path))

(setq org-plantuml-exec-mode 'plantuml)

(add-to-list 'org-babel-custom-load-languages '(plantuml . t))
(provide 'config-plantuml)
