(add-to-list 'load-path (expand-file-name "site-lisp/emacs-application-framework" user-emacs-directory))

(global-set-key (kbd "C-c w") 'browse-web)

(use-package eaf :diminish eaf-mode
  :custom
  (eaf-find-alternate-file-in-dired t)
  (eaf-webengine-download-path "~/Downloads")
  :init
  (if (string-equal (shell-command-to-string "echo $XDG_CURRENT_DESKTOP") "Hyprland\n")
      (setq eaf-wm-name "wlroots wm"
	    eaf-is-member-of-focus-fix-wms t))
  )

(use-package eaf-browser :after eaf
  :custom
  (eaf-proxy-port "7890")
  (eaf-proxy-type "http")
  (eaf-proxy-host "127.0.0.1")
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-enable-adblocker nil)
  (browse-url-browser-function 'eaf-open-browser)
  (eaf-browser-blank-page-url "https://zjuers.com")
  (eaf-webengine-default-zoom "2.0")
  (eaf-webengine-font-size 20)
  (eaf-webengine-fixed-font-size 20)
  (eaf-webengine-fixed-font-family "WenQuanyi Micro Hei Mono")
  (eaf-webengine-font-family "WenQuanYi Micro Hei Mono")
  (eaf-browser-extension-list
   '("html" "htm"))
  (eaf-browser-chrome-browser-name "Chromium")
  (eaf-chrome-bookmark-file "~/.config/chromium/Default/Bookmarks")
  (eaf-browser-chrome-history-file "~/.config/chromium/Default/History")
  :config
  (if (eq system-type 'gnu/linux)
      (setq eaf-browser-auto-import-chrome-cookies t)
    nil
    )
  (defalias 'browse-web #'eaf-open-browser)
  )

(use-package eaf-pdf-viewer :after eaf
  :custom (eaf-pdf-dark-mode nil)
  )

(use-package eaf-all-the-icons  :after all-the-icons)

(if (eq system-type 'gnu/linux)
    (use-package eaf-file-manager
      :after eaf
      :load-path "~/.emacs.d/site-lisp/emacs-application-framework"))

(provide 'config-eaf)
