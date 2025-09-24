(use-package lsp-bridge
  :load-path "site-lisp/lsp-bridge"
  :diminish lsp-bridge-mode
  :bind
  (:map lsp-bridge-mode-map
  ("C-c l" . lsp-bridge-hydra/body))
  :custom
  ;(lsp-bridge-enable-auto-format-code t)
  (lsp-bridge-enable-org-babel t)
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
(add-hook-list language-modes-list 'lsp-bridge-mode)
(use-package dape
  :ensure t
  :hydra
  (dape-hydra (:color pink :hint nil)
	      "
DAP: _i_ for information panel.

 ^^Breakpoint ^^Stepping     ^^Watch           ^^Stack      ^^Other               ^^Process
^^-----------------------^^--------------------^^-----------^^----------------------^^--------------
 _b_ : Toggle _s_ : Step in  _m_ : Memory      _S_ : Select _x_ : Evaluate Expr   _r_ : Restart
 _B_ : Remove _o_ : Step out _R_ : REPL        _<_ : Up     _e_ : Breakpoint Expr _q_ : Quit
 _l_ : Log    _c_ : Continue _M_ : disassemble ^^           ^^                    _Q_ : Quit Menu
 _h_ : Hits   _n_ : Next     _w_ : Dwim        _>_ : Down   _t_ : Select Thread   _D_ : Dissconnect
"
	      ("i" dape-info)

	      ("b" dape-breakpoint-toggle)
	      ("B" dape-breakpoint-remove-all)
	      ("l" dape-breakpoint-log)
	      ("h" dape-breakpoint-hits)

	      ("s" dape-step-in)
	      ("o" dape-step-out)
	      ("n" dape-next)
	      ("c" dape-continue)

	      ("m" dape-memory)
	      ("R" dape-repl)
	      ("w" dape-watch-dwim)
	      ("M" dape-disassemble)

	      ("r" dape-restart :color blue)
	      ("q" dape-quit :color blue)
	      ("D" dape-disconnect-quit :color blue)
	      ("Q" nil :color blue)


	      ("S" dape-select-stack)
	      ("<" dape-stack-select-up)
	      (">" dape-stack-select-down)

	      ("x" dape-evaluate-expression)
	      ("e" dape-breakpoint-expression)

	      ("t" dape-select-thread)
	      )
  :bind
  (("C-c D" . dape)
  (:map dape-active-mode
	("C-c d" . dape-hydra/body)))
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
