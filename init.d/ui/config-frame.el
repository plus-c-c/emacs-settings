;;; config-frame.el --- Frame and tab-bar configuration -*- lexical-binding: t -*-

(require 'tab-bar)
(require 'seq)

(defvar cabins--tab-bar-saved-tabs nil
  "Tabs saved from the last GUI frame before it was deleted.
Used so new `emacsclient -c' frames in the same daemon session restore
the tab count, names, and window layouts.")

(defun cabins--tab-bar-only-gui-frame-p (frame)
  "Return non-nil when FRAME is the only live GUI frame."
  (null (seq-filter (lambda (other)
                      (and (not (eq other frame))
                           (display-graphic-p other)))
                    (frame-list))))

(defun cabins--tab-bar-ensure (&optional frame)
  "Make sure the tab bar is enabled on FRAME or the selected frame.
Daemon startup can load this configuration after `window-setup-hook'
has already run, so relying on that hook alone leaves new GUI frames
without a tab bar."
  (when (display-graphic-p (or frame (selected-frame)))
    (tab-bar-mode 1)
    (force-mode-line-update t)))

(defun cabins--tab-bar-capture (frame)
  "Return FRAME's tabs with the current tab's live window state.
`tab-bar-tabs' keeps only the state from the last tab switch, so
capture the current tab explicitly before deleting the frame."
  (let* ((tabs (copy-tree (tab-bar-tabs frame)))
         (index (tab-bar--current-tab-index tabs frame))
         (current (tab-bar--tab frame)))
    (setcar current 'current-tab)
    (if (and index (< index (length tabs)))
        (setf (nth index tabs) current)
      (push current tabs))
    tabs))

(defun cabins--tab-bar-save (frame)
  "Save the tabs of FRAME when it is the last GUI frame.
The saved value also keeps the window states, so restoring it brings
back the buffer layout of every tab, not just their names."
  (when (and (display-graphic-p frame)
             (bound-and-true-p tab-bar-mode)
             (cabins--tab-bar-only-gui-frame-p frame))
    (setq cabins--tab-bar-saved-tabs
          (cabins--tab-bar-capture frame))))

(defun cabins--tab-bar-restore (frame)
  "Restore saved tab-bar tabs and layout into the first new GUI FRAME."
  (when (and (display-graphic-p frame)
             (cabins--tab-bar-only-gui-frame-p frame)
             cabins--tab-bar-saved-tabs)
    (let ((tabs (copy-tree cabins--tab-bar-saved-tabs))
          (current (tab-bar--current-tab-find cabins--tab-bar-saved-tabs)))
      (tab-bar-tabs-set tabs frame)
      ;; `tab-bar-tabs-set' restores the tab list, but the new frame still
      ;; has its initial window layout.  Apply the saved layout of the
      ;; selected tab explicitly.
      (let ((ws (and current (alist-get 'ws current))))
        (when ws
          (window-state-put ws (frame-root-window frame) 'safe)))
      (force-mode-line-update t))))

(add-hook 'delete-frame-functions #'cabins--tab-bar-save)
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
    (add-hook 'after-make-frame-functions #'cabins--tab-bar-ensure)
    (add-hook 'after-make-frame-functions #'cabins--tab-bar-restore))
  )
(let ((map (if (eq system-type 'gnu/linux) tab-bar-mode-map tab-bar-map)))
  (define-key map (kbd "M-s-n") 'tab-bar-switch-to-next-tab)
  (define-key map (kbd "M-s-p") 'tab-bar-switch-to-prev-tab)
  (define-key map (kbd "M-s-t") 'tab-bar-new-tab)
  (define-key map (kbd "M-s-x") 'tab-bar-close-tab))
(define-key tab-bar-history-mode-map (kbd "M-s-f") 'tab-bar-history-forward)
(define-key tab-bar-history-mode-map (kbd "M-s-b") 'tab-bar-history-back)
(provide 'config-frame)
