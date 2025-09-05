(use-package ellama
  :ensure t
  :bind ("C-c e" . ellama)
  ;; send last message in chat buffer with C-c C-c
  :hook (org-ctrl-c-ctrl-c-final . ellama-chat-send-last-message)
  :init
  (setopt ellama-auto-scroll t)
  (setopt ellama-language "Chinese")
  :config
  ;; show ellama context in header line in all buffers
  (ellama-context-header-line-global-mode +1)
  ;; show ellama session id in header line in all buffers
  (ellama-session-header-line-global-mode +1)
  (require 'llm-ollama)
  (setopt ellama-provider
	(make-llm-ollama
	 ;; this model should be pulled to use it
	 ;; value should be the same as you print in terminal during pull
	 :chat-model "deepseek-r1:1.5b"
	 :embedding-model "nomic-embed-text"
	 :default-chat-non-standard-params '(("num_ctx" . 8192))))
  )

(provide 'config-ellama)
