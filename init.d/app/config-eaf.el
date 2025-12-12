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

(defun eaf-org-open-file (file &optional link) "An wrapper function on eaf-(or )pen."
       (eaf-open file))
(use-package eaf-browser :after eaf
  :custom
  (eaf-proxy-port "7890")
  (eaf-proxy-type "http")
  (eaf-proxy-host "127.0.0.1")
  (browse-url-browser-function 'eaf-open-browser)
  (eaf-browser-enable-adblocker nil)
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-chrome-browser-name "Chromium")
  (eaf-chrome-bookmark-file "~/.config/chromium/Default/Bookmarks")
  (eaf-browser-chrome-history-file "~/.config/chromium/Default/History")
  (eaf-browser-blank-page-url "https://zjuers.com")
  (eaf-webengine-default-zoom "2.0")
  (eaf-webengine-font-size 20)
  (eaf-webengine-fixed-font-size 20)
  (eaf-webengine-fixed-font-family "WenQuanyi Micro Hei Mono")
  (eaf-webengine-font-family "WenQuanYi Micro Hei Mono")
  (eaf-browser-extension-list
   '("html" "htm"))
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
      :after eaf))
(use-package eaf-image-viewer :after eaf)
(use-package eaf-video-player :after eaf)

(use-package eaf-video-editor :after eaf)
(use-package eaf-org-previewer :after eaf)
(use-package eaf-markdown-previewer :after eaf)

(provide 'config-eaf)
