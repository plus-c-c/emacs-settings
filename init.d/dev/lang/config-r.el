;;; config-r.el --- R configuration -*- lexical-binding: t; -*-

(use-package ess
  :ensure t
  :custom
  (ess-use-tracebug t)
  (ess-tracebug-inject-source t))

(add-to-list 'org-babel-custom-load-languages '(R . t))

(set-language-protocol 'r 'ess-r-mode-hook
           '("https://github.com/r-lib/tree-sitter-r.git"))

;; DAP configuration for R (using ess-tracebreak)
;; Note: R DAP support is limited, use ess-tracebreak instead
;; See: https://ess.r-project.org/Manual/ess.html#Tracebreak
(with-eval-after-load 'dape
  (add-to-list 'dape-configs
               '(ess-tracebreak
                 modes (ess-r-mode)
                 ensure (lambda (config)
                          (unless (executable-find "R")
                            (user-error "R executable not found")))
                 fn (lambda (config)
                      (require 'ess-tracebreak)
                      (let ((proc (ess-get-process)))
                        (unless proc
                          (user-error "No R process running. Start one with M-x R"))
                        (unless (ess-tracebreak-p)
                          (ess-tracebreak))))
                 :request "launch"
                 :type "R"
                 :cwd dape-cwd)))

;; R-specific dape hydra (needs both dape and ess-tracebreak)
(with-eval-after-load 'dape
  (defhydra r-dape-hydra (:color pink :hint nil)
    "
R DAP: _i_ for information panel.

 ^^Breakpoint ^^Stepping     ^^Watch           ^^Stack      ^^Other               ^^Process
^^-----------------------^^--------------------^^-----------^^----------------------^^--------------
 _b_ : Toggle _s_ : Step      _w_ : Watch       _S_ : Select _x_ : Eval Expr      _r_ : Restart
 _B_ : Remove _n_ : Next      _d_ : Dump        _<_ : Up     _e_ : Break Expr     _q_ : Quit
 _l_ : Log    _c_ : Continue  _R_ : REPL        _>_ : Down   _t_ : Select Thread  _D_ : Disconnect
 _h_ : Hits   _o_ : Step Out  ^ ^               ^ ^          ^ ^                  _Q_ : Quit Menu
"
    ("i" dape-info)
    ("b" ess-breakpoint)
    ("B" ess-unset-breakpoint)
    ("l" ess-breakpoint-set-conditional)
    ("h" ess-show-breakpoints)
    ("s" ess-step)
    ("n" ess-next)
    ("c" ess-continue)
    ("o" ess-step-out)
    ("w" ess-watch)
    ("d" ess-dump-object)
    ("R" ess-switch-process)
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

  ;; Bind R-specific hydra to dape-active-mode in ess-r-mode
  (add-hook 'ess-r-mode-hook
            (lambda ()
              (when (bound-and-true-p dape-active-mode)
                (local-set-key (kbd "C-c d") 'r-dape-hydra/body)))))

(provide 'config-r)
;;; config-r.el ends here
