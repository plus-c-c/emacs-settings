;;; config-racket.el --- Racket configuration -*- lexical-binding: t; -*-

(use-package racket-mode
  :ensure t
  :defer t
  :mode ("\\.rktl\\'" . racket-mode)
  :custom
  (racket-show-debug-backtrace t)
  (racket-show-debug-local-values t)
  :bind (:map racket-mode-map
              ("C-c C-d" . racket-debug)
              ("C-c C-r" . racket-run)))

(add-to-list 'lisp-mode-list 'racket-mode)

(set-language-protocol 'racket 'racket-mode-hook
           '("https://github.com/6cdh/tree-sitter-racket.git"))

;; DAP configuration for Racket (using racket-debug-mode)
;; Note: No DAP adapter available for Racket
;; Use racket-mode's built-in debugger instead
(with-eval-after-load 'dape
  (add-to-list 'dape-configs
               '(racket-debug
                 modes (racket-mode)
                 ensure (lambda (config)
                          (unless (executable-find "racket")
                            (user-error "Racket executable not found")))
                 fn (lambda (config)
                      (require 'racket-mode)
                      (let ((proc (racket--repl-and-process)))
                        (unless proc
                          (user-error "No Racket process running. Start one with M-x racket-run"))
                        (unless racket-debug-mode
                          (racket-debug))))
                 :request "launch"
                 :type "racket"
                 :cwd dape-cwd)))

;; Racket-specific dape hydra (needs both dape and racket-debug)
(with-eval-after-load 'dape
  (defhydra racket-dape-hydra (:color pink :hint nil)
    "
Racket DAP: _i_ for information panel.

 ^^Breakpoint ^^Stepping     ^^Watch           ^^Stack      ^^Other               ^^Process
^^-----------------------^^--------------------^^-----------^^----------------------^^--------------
 _b_ : Toggle _s_ : Step      _w_ : Watch       _S_ : Select _x_ : Eval Expr      _r_ : Restart
 _B_ : Remove _o_ : Step Over _d_ : Dump        _<_ : Up     _e_ : Break Expr     _q_ : Quit
 _l_ : Log    _u_ : Step Out  _R_ : REPL        _>_ : Down   _t_ : Select Thread  _D_ : Disconnect
 _h_ : Hits   _n_ : Next      ^ ^               ^ ^          ^ ^                  _Q_ : Quit Menu
"
    ("i" dape-info)
    ("b" racket-debug-toggle-break-expression)
    ("B" racket-debug-remove-all-break-expressions)
    ("l" racket-debug-set-break-expression)
    ("h" racket-debug-help)
    ("s" racket-debug-step)
    ("o" racket-debug-step-over)
    ("u" racket-debug-step-out)
    ("n" racket-debug-forward-breakable)
    ("c" racket-debug-continue)
    ("w" racket-debug-run-to-here)
    ("d" racket-debug-step)
    ("R" racket-run)
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

  ;; Bind Racket-specific hydra to dape-active-mode in racket-mode
  (add-hook 'racket-mode-hook
            (lambda ()
              (when (bound-and-true-p dape-active-mode)
                (local-set-key (kbd "C-c d") 'racket-dape-hydra/body)))))

(provide 'config-racket)
;;; config-racket.el ends here
