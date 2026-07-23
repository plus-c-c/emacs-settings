;;; config-interleave.el --- EAF interleave for PDF notes -*- lexical-binding: t -*-

(add-to-list 'load-path (expand-file-name "site-lisp/emacs-application-framework" user-emacs-directory))

(defun eaf-interleave-open-notes-file-auto-create () "Auto create version for eaf-interleave-open-notes-file"
       (interactive)
       (progn (expand-file-name-auto-create
         (concat (file-name-base eaf--buffer-url) ".org")
         interleave-path)
        (eaf-interleave-open-notes-file)))

(defun eaf-interleave-add-note-auto-create () "Auto create version for eaf-interleave-open-notes-file"
       (interactive)
       (progn
   (eaf-interleave-open-notes-file-auto-create)
   (let ((buffer-org (concat (file-name-base eaf--buffer-url) ".org"))
         (buffer-app (eaf-interleave--find-buffer eaf--buffer-url))
         (page (number-to-string (eaf-interleave--pdf-viewer-current-page eaf--buffer-url))))
     (switch-to-buffer buffer-org)
     (let ((pos (point-max)))
       (switch-to-buffer buffer-app)
       (eaf-interleave-add-note)
       (switch-to-buffer buffer-org)
       (unless  (>= pos (- (point-max) 1))
         (progn
           (search-backward ":PROPERTIES:")
           (previous-line)
           (if (eq (point) (point-min))
         (insert "#+filetags: :interleave:\n#+title: "
           (read-string "Global Title: " (file-name-base eaf--buffer-url)) "\n"
           ))
           (kill-whole-line)
           (insert "* "
             (read-string "Interleave Title: " (concat "Notes for Page " page " of " (org-get-title) ))
             "\n")
           (org-id-get-create)
           (org-fold-hide-drawer-toggle)
           (next-line)
           )
         )
     )))
       )

(use-package eaf-interleave
  :after (org-roam eaf)
  :defer 0.5
  :custom
  (eaf-interleave-org-notes-dir-list (cons interleave-path nil))
  (eaf-interleave-split-direction 'vertical)
  (eaf-interleave-disable-narrowing t)
  (eaf-interleave-split-lines 20)
  :hook
  ((org-mode . eaf-interleave-mode)
   (eaf-browser . eaf-interleave-app-mode)
   (eaf-pdf-viewer . eaf-interleave-app-mode))
  :bind ( :map eaf-interleave-mode-map
    ("M-." . eaf-interleave-sync-current-note)
    ("M-p" . eaf-interleave-sync-previous-note)
    ("M-n" . eaf-interleave-sync-next-note)
    :map eaf-interleave-app-mode-map
    ("C-c M-a" . eaf-interleave-add-note-auto-create)
    ("C-c M-o" . eaf-interleave-open-notes-file-auto-create)
    ("C-c M-q" . eaf-interleave-quit))
  :hydra
  (eaf-interleave-app-hydra (:color blue :hint nil)
        "
 ^Interleave^
^^^^^^^──────────────────────
 _a_ Add Note       _o_ Open Notes
 _q_ Quit
"
        ("a" eaf-interleave-add-note-auto-create)
        ("o" eaf-interleave-open-notes-file-auto-create)
        ("q" eaf-interleave-quit))
  (eaf-interleave-hydra (:color blue :hint nil)
        "
 ^Interleave Sync^
^^^^^^^──────────────────────
 _._ Sync Current
 _p_ Previous Note
 _n_ Next Note
"
        ("." eaf-interleave-sync-current-note)
        ("p" eaf-interleave-sync-previous-note)
        ("n" eaf-interleave-sync-next-note)))

(provide 'config-interleave)
