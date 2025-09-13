(use-package gptel
  :ensure t
  :commands (gptel gptel-send gptel-rewrite)
  :bind ("C-c g" . gptel-menu)
  ("C-c G" . gptel)
  :custom
  (gptel-expert-commands t)
  :config
  (setq-default
   gptel-backend
  (gptel-make-ollama "Ollama"
    :models '((deepseek-r1
	       :description "Deepseek R1"
	       :capabilities (text)
	       )
	      (gemma3
	       :description "Gemma 3"
	       :capabilities (text media)
	       ))
    ;:stream t
    ))
  (setq-default gptel-model 'deepseek-r1)
  )
(provide 'config-gptel)
