(add-to-list 'load-path (expand-file-name "UI" emacs-config-path))
(require 'settings-theme)
(require 'settings-buffer)
(require 'settings-dashboard)


(if (eq system-type 'gnu/linux)
    (require 'UI-linux)
  (require 'UI-win))
(provide 'init-UI)
