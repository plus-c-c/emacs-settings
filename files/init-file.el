(add-to-list 'load-path (expand-file-name "file" emacs-config-path))
(require 'external-device-methods)
(if (eq system-type 'gnu/linux)
    (require 'linux-file)
  (require 'win-file))

(provide 'init-file)
