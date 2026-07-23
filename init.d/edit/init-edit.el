;;; init-edit.el --- Editing configuration -*- lexical-binding: t -*-
(use-package ivy :ensure t
  :custom
  (ivy-use-virtual-buffers t)
  (search-default-mode #'char-fold-to-regexp)
  (ivy-count-format "(%d/%d) ")
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
  :custom
  (counsel-find-file-extern-extensions nil))
(use-package ivy-hydra :ensure t
  :after ivy)
(ivy-mode 1)
(counsel-mode 1)
(use-package amx :ensure t
  :diminish amx-mode
  :config (amx-mode))
(use-package highlight-parentheses :ensure t
  :diminish highlight-parentheses-mode
  :hook (prog-mode . highlight-parentheses-mode)
  :custom
  (highlight-parentheses-colors '("IndianRed1" "orange" "gold" "lawn green" "cyan" "deep sky blue" "orchid")))
(use-package mwim :ensure t
  :bind ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))
(use-package vundo :ensure t)
(use-package move-dup :ensure t
  :diminish move-dup-mode
  :bind (("M-P"   . move-dup-move-lines-up)
   ("C-M-P" . move-dup-duplicate-up)
   ("M-N"   . move-dup-move-lines-down)
   ("C-M-N" . move-dup-duplicate-down))
  :config (global-move-dup-mode 1))

(use-package auto-save :load-path "~/.emacs.d/site-lisp/auto-save"
  :defer 0.5
  :custom
  (auto-save-idle 10)
  (auto-save-silent t)
  (auto-save-delete-trailing-whitespace t)
  (auto-save-disable-predicates
   (list (lambda ()
           (string-suffix-p "gpg" (file-name-extension (buffer-name)) t))))
  :config (auto-save-enable))

;; GPTel: defer until first command (C-c g)
(use-package gptel
  :ensure t
  :commands (gptel gptel-send gptel-rewrite)
  :bind ("C-c g" . gptel-menu)
  ("C-c G" . gptel)
  :custom
  (gptel-default-mode 'org-mode)
  (gptel-directives
   '((default     . "")
     (programming . "You are a large language model and a careful programmer. Provide code and only code as output without any additional text, prompt or note.")
     (writing     . "You are a large language model and a writing assistant. Respond concisely.")
     (chat        . "You are a large language model and a conversation partner. Respond concisely.")))
  :config
  (setq gptel-expert-commands t)
  (setq ollama-backend-stream
  (gptel-make-ollama "Ollama-stream"
    :models '((deepseek-r1 :description "Deepseek R1" :capabilities (text))
        (gemma3 :description "Gemma 3" :capabilities (text media)))
    :stream t))
  (setq ollama-backend
  (gptel-make-ollama "Ollama"
    :models '((deepseek-r1 :description "Deepseek R1" :capabilities (text))
        (gemma3 :description "Gemma 3" :capabilities (text media)))))
  (setq deepseek-backend (gptel-make-deepseek "Deepseek"
     :stream t
     :key (lambda () (auth-source-pick-first-password :host "api.deepseek.com"))))
  (setq-default gptel-backend ollama-backend-stream)
  (setq-default gptel-model 'deepseek-r1))

(when (eq system-type 'windows-nt)
  (require 'pasteex-mode))
(provide 'init-edit)
