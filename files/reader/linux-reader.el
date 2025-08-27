(add-to-list 'load-path (expand-file-name "site-lisp/emacs-application-framework" user-emacs-directory))

(use-package eaf :diminish eaf-mode
  :custom
  (eaf-find-alternate-file-in-dired t))

(use-package eaf-git :after eaf)

(use-package eaf-browser :after eaf
  :custom
  (eaf-proxy-port "7890")
  (eaf-proxy-type "http")
  (eaf-proxy-host "127.0.0.1")
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-enable-adblocker nil)
  (eaf-browser-chrome-browser-name "Chromium")
  (browse-url-browser-function 'eaf-open-browser)
  (eaf-browse-blank-page-url "https://zjuers.com")
  (eaf-webengine-default-zoom "2.0")
  (eaf-webengine-font-size 20)
  (eaf-webengine-fixed-font-size 20)
  (eaf-webengine-fixed-font-family "WenQuanyi Micro Hei Mono")
  (eaf-webengine-font-family "WenQuanYi Micro Hei Mono")
  (eaf-browser-extension-liste
   '("html" "htm"))
  (eaf-browser-auto-import-chrome-cookies t)
  :config
  (defalias 'browse-web #'eaf-open-browser)
  )

(use-package eaf-pdf-viewer :after eaf
  :custom (eaf-pdf-dark-mode nil)
  )

(use-package eaf-pyqterminal :after eaf
  :custom
  (eaf-pyqterminal-font-family "CaskaydiaCove Nerd Font Mono")
  (eaf-pyqterminal-font-size 32))

(use-package eaf-all-the-icons  :after all-the-icons)

(provide 'linux-reader)
