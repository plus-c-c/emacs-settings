(use-package pdf-tools
  :ensure t
  :defer 0.8
  :init
  (pdf-loader-install)
  )
(setq TeX-PDF-mode t)
(setq TeX-source-correlate-mode t)
(setq TeX-source-correlate-method 'synctex)
(setq TeX-source-correlate-start-server t)
(setq TeX-view-program-selection '((output-pdf "PDF Tools")))
(add-hook 'TeX-after-compilation-finished-functions
          #'TeX-revert-document-buffer)
(setq browse-url-browser-function 'eww-browse-url)
(provide 'win-reader)
