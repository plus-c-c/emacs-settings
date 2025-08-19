(add-to-list 'load-path (expand-file-name "file" emacs-config-path))
(require 'external-device-methods)
(if (eq system-type 'gnu/linux)
    (require 'file-linux)
  (require 'file-win)
)

(provide 'init-file)
