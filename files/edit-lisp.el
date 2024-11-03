(use-package ivy :ensure t
  :hook (after-init .ivy-mode)
  :custom
  (ivy-use-virtual-buffers t)
  (search-default-mode #'char-fold-to-regexp)
  (ivy-count-format "(%d/%d) ")
  :config
  :diminish ivy-mode
  :bind
  (("C-s" . swiper)
   ("C-x b" . ivy-switch-buffer)
   ("C-c v" . ivy-push-view)
   ("C-c s" . ivy-switch-view)
   ("C-c V" . ivy-pop-view)
   ("C-x C-@" . counsel-mark-ring)
   ("C-x C-SPC" . counsel-mark-ring)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history)))
(use-package swiper :ensure t)
(use-package counsel
  :ensure t
  :diminish counsel-mode
  :hook (after-init . counsel-mode))
(use-package ivy-hydra :ensure t)
;; better M-x
(use-package amx :ensure t :init (amx-mode) :diminish amx-mode)
;;better C-a and C-e
(use-package highlight-parentheses :ensure t
  :diminish highlight-parentheses-mode
  :hook
  (prog-mode . highlight-parentheses-mode)
  :custom
  (highlight-parentheses-colors '("IndianRed1" "orange" "gold" "lawn green" "cyan" "deep sky blue" "orchid")))
(use-package mwim :ensure t :defer 0.5
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))
;;better C-x u
(use-package vundo :ensure t)
;;move or copy the whole line or region
(use-package move-dup :ensure t :defer 0.5
  :hook (after-init . global-move-dup-mode)
  :diminish move-dup-mode
  :bind (("M-P"   . move-dup-move-lines-up)
	 ("C-M-P" . move-dup-duplicate-up)
	 ("M-N"   . move-dup-move-lines-down)
	 ("C-M-N" . move-dup-duplicate-down)))
(add-to-list 'load-path (expand-file-name "files/edit" user-emacs-directory))
(if (eq system-type 'gnu/linux)
    (require 'edit-linux)
  (require 'edit-win))
(provide 'edit-lisp)
