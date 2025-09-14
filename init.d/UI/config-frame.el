(require 'tab-bar)
(add-hook 'dashboard-after-initialize-hook 'tab-bar-history-mode)
(define-key tab-bar-mode-map (kbd "M-s-n") 'tab-bar-switch-to-next-tab)
(define-key tab-bar-mode-map (kbd "M-s-p") 'tab-bar-switch-to-prev-tab)
(define-key tab-bar-mode-map (kbd "M-s-t") 'tab-bar-new-tab)
(define-key tab-bar-mode-map (kbd "M-s-x") 'tab-bar-close-tab)
(define-key tab-bar-history-mode-map (kbd "M-s-f") 'tab-bar-history-forward)
(define-key tab-bar-history-mode-map (kbd "M-s-b") 'tab-bar-history-back)
(provide 'config-frame)
(use-package tab-bar
  :hook (window-setup . tab-bar-mode)
  :config
  (setq tab-bar-separator ""
        tab-bar-new-tab-choice "*dashboard*"
        tab-bar-tab-name-truncated-max 20
        tab-bar-auto-width nil
        tab-bar-close-button-show nil
	tab-bar-border nil)
  ;; 给 tab 两边加上空格，更好看
  (setq tab-bar-tab-name-format-function
        (lambda (tab i)
          (let ((face (funcall tab-bar-tab-face-function tab)))
            (concat
             (propertize " " 'face `(:inherit ,face))
             (propertize (alist-get 'name tab) 'face `(:inherit ,face :weight ultra-bold))
             (propertize " " 'face `(:inherit ,face))
	     ))))
  (custom-set-faces
   '(tab-bar ((t (:inherit mode-line :box nil))))
   '(tab-bar-tab ((t (:inherit mode-line :box nil))))
   '(tab-bar-tab-inactive ((t (:inherit mode-line-inactive :box nil)))))
  ;; WORKAROUND: update tab-bar for daemon
  (when (daemonp)
    (add-hook 'after-make-frame-functions
              #'(lambda (&rest _) (force-mode-line-update))))
  )
