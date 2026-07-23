;;; config-dape.el --- DAP configuration -*- lexical-binding: t; -*-

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

        ("t" dape-select-thread))
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
  (setq dape-cwd-fn 'projectile-project-root))

(provide 'config-dape)
;;; config-dape.el ends here
