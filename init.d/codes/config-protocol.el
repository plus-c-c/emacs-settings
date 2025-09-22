(use-package lsp-bridge
  :load-path "site-lisp/lsp-bridge"
  :diminish lsp-bridge-mode
  :bind
  (:map lsp-bridge-mode-map
  ("C-c l" . lsp-bridge-hydra/body))
  :hydra
  (lsp-bridge-hydra (:color blue :hint nil)
		    "
LSP:(uppercase choice - other window)
^^^^Find                        ^^Diagnose
^^^^----------------------------^^-----------------
_d_,_D_: Find Definition        _p_: Jump Previous
_t_,_T_: Find Type Definition   _n_: Jump Next
_i_,_I_: Find Implication       _l_: List Diagnoses
 ^_r_^ : Find References        _C_: Copy Diagnoses
 ^_R_^ : Find Definition Return _c_: Code Action
"
		    ("d" lsp-bridge-find-def)
		    ("D" lsp-bridge-find-def-other-window)
		    ("t" lsp-bridge-find-type-def)
		    ("T" lsp-bridge-find-type-def-other-window)
		    ("i" lsp-bridge-find-impl)
		    ("I" lsp-bridge-find-impl-other-window)
		    ("r" lsp-bridge-find-references)
		    ("R" lsp-bridge-find-def-return)
		    ("p" lsp-bridge-diagnostic-jump-prev)
		    ("n" lsp-bridge-diagnostic-jump-next)
		    ("l" lsp-bridge-diagnostic-list)
		    ("C" lsp-bridge-diagnostic-copy)
		    ("c" lsp-bridge-code-action)
		    ("P" lsp-bridge-peek-through "Peek Through the Cursor")
		    ("f" lsp-bridge-indent-right "Indent Forward")
		    ("b" lsp-bridge-indent-left "Indent Backward")
		    )
  :commands global-lsp-bridge-mode
  )
(global-lsp-bridge-mode)
(setopt lsp-bridge-enable-org-babel t)
(setopt lsp-bridge-python-lsp-server "pylsp")
(setopt lsp-bridge-python-multi-lsp-server "pylsp_ruff")
(add-hook-list language-modes-list 'lsp-bridge-mode)
(use-package dape
  :ensure t
  :preface
  (setq dape-key-prefix "\C-x\C-a")
  :hook
  (dape-display-source . pulse-momentary-highlight-one-line)
  (dape-start . (lambda () (save-some-buffers t t)))
  (dape-compile . kill-buffer)
  :config
  (dape-breakpoint-global-mode)
  (setq dape-buffer-window-arrangement 'right)
  (setq dape-inlay-hints t)
  (setq dape-cwd-fn 'projectile-project-root)
  )
(provide 'config-protocol)
