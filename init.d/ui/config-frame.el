;;; config-frame.el --- Frame and tab-bar configuration -*- lexical-binding: t -*-

(require 'tab-bar)

(defun cabins--tab-bar-ensure (&optional frame)
  "Make sure the tab bar is enabled on FRAME or the selected frame.
Daemon startup can load this configuration after `window-setup-hook'
has already run, so relying on that hook alone leaves new GUI frames
without a tab bar."
  (when (display-graphic-p (or frame (selected-frame)))
    (tab-bar-mode 1)
    (force-mode-line-update t)))

(add-hook 'dashboard-after-initialize-hook 'tab-bar-history-mode)
(use-package tab-bar
  :hook (window-setup . cabins--tab-bar-ensure)
  :config
  (setq tab-bar-separator ""
        tab-bar-new-tab-choice "*dashboard*"
        tab-bar-tab-name-truncated-max 20
        tab-bar-auto-width nil
        tab-bar-close-button-show nil
  tab-bar-border nil)
  (setq tab-bar-tab-name-format-function
        (lambda (tab i)
          (let ((face (funcall tab-bar-tab-face-function tab)))
            (concat
             (propertize " " 'face `(:inherit ,face))
             (propertize (alist-get 'name tab) 'face `(:inherit ,face :weight ultra-bold))
             (propertize " " 'face `(:inherit ,face))))))
  (custom-set-faces
   '(tab-bar ((t (:inherit mode-line :box nil))))
   '(tab-bar-tab ((t (:inherit mode-line :box nil))))
   '(tab-bar-tab-inactive ((t (:inherit mode-line-inactive :box nil)))))
  (cabins--tab-bar-ensure)
  (when (daemonp)
    (add-hook 'after-make-frame-functions #'cabins--tab-bar-ensure))
  )
(let ((map (if (eq system-type 'gnu/linux) tab-bar-mode-map tab-bar-map)))
  (define-key map (kbd "M-s-n") 'tab-bar-switch-to-next-tab)
  (define-key map (kbd "M-s-p") 'tab-bar-switch-to-prev-tab)
  (define-key map (kbd "M-s-t") 'tab-bar-new-tab)
  (define-key map (kbd "M-s-x") 'tab-bar-close-tab))
(define-key tab-bar-history-mode-map (kbd "M-s-f") 'tab-bar-history-forward)
(define-key tab-bar-history-mode-map (kbd "M-s-b") 'tab-bar-history-back)
(provide 'config-frame)
