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
  (setq gptel-expert-commands t
	ollama-backend-stream
	(gptel-make-ollama "Ollama-stream"
	  :models '((deepseek-r1
		     :description "Deepseek R1"
		     :capabilities (text)
		     )
		    (gemma3
		     :description "Gemma 3"
		     :capabilities (text media)
		     ))
	  :stream t
	  )
	ollama-backend
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
	  )
	)

  (setq-default gptel-backend ollama-backend-stream)

  (setq-default gptel-model 'deepseek-r1)
  )
(provide 'config-gptel)
