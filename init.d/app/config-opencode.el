;;; config-opencode.el --- OpenCode AI integration -*- lexical-binding: t -*-

;; :vc is built-in in Emacs 30.2 — installs from Codeberg automatically.
;; Dependencies (magit, markdown-mode, plz, etc.) must be in package archives.
(use-package opencode
  :vc (:url "https://codeberg.org/sczi/opencode.el.git" :rev :newest)
  :bind ("C-c o" . hydra-opencode/body)
  :custom
  (opencode-terminal-type 'vterm)
  (opencode-auto-start-server t)
  (opencode-split-direction 'vertical)
  :config
  ;; plz uses curl directly — bypass proxy for localhost
  (let ((proxy (or (getenv "http_proxy") (getenv "https_proxy")
                   (getenv "HTTP_PROXY") (getenv "HTTPS_PROXY"))))
    (when proxy
      (setq plz-curl-default-args
            (append '("--noproxy" "localhost") plz-curl-default-args)))))

(defhydra hydra-opencode (:color blue :hint nil)
  "
 ^OpenCode^
^^^^^^^^^^^^^^^^^^^^──────────────────────────────────────
 _o_ Start          _c_ Connect       _d_ Disconnect
 _n_ New Session    _s_ Sessions      _p_ Projects
 _w_ Worktree       _i_ Idle          _l_ Visit Idle
 _q_ Quit
"
  ("o" opencode)
  ("n" opencode-new-session)
  ("c" opencode-connect)
  ("d" opencode-disconnect)
  ("p" opencode-select-project)
  ("s" opencode-select-open-session)
  ("w" opencode-new-worktree)
  ("i" opencode-select-idle)
  ("l" opencode-visit-last-idle)
  ("q" nil "quit" :color blue))

(defhydra hydra-opencode-session (:color blue :hint nil)
  "
 ^Session^           ^Add^              ^Model^
^^^^^^^────────────────────────── ^^^^^^^──────────────────────────
 _n_ New             _f_ File           _m_ Select Model
 _x_ Kill            _b_ Buffer         _v_ Select Variant
 _r_ Rename          _R_ Region         _a_ Cycle Agent
 _F_ Fork            _A_ Subagent       _M_ Toggle MCP
 _C_ Compact         _/_ Slash Cmd
 _X_ Abort
^^^^^^^────────────────────────── ^^^^^^^──────────────────────────
 ^Navigate^          ^Share^            ^Misc^
^^^^^^^────────────────────────── ^^^^^^^──────────────────────────
 _s_ Select          _h_ Share          _y_ Yank Code
 _c_ Child           _u_ Unshare        _Y_ Copy Chat
 _p_ Parent          _U_ Unshare All    _t_ Scroll Top
 _i_ Idle            _L_ Consult
 _l_ Last Idle
"
  ;; Session
  ("n" opencode-new-session)
  ("x" opencode-kill-session)
  ("r" opencode-rename-session)
  ("F" opencode-fork-session)
  ("C" opencode-compact-session)
  ("X" opencode-abort-session)
  ;; Add
  ("f" opencode-add-file-dwim)
  ("b" opencode-add-buffer-dwim)
  ("R" opencode-add-region)
  ("A" opencode-add-subagent)
  ("/" opencode-insert-slash-command)
  ;; Model
  ("m" opencode-select-model)
  ("v" opencode-select-variant)
  ("a" opencode-cycle-session-agent)
  ("M" opencode-toggle-mcp)
  ;; Navigate
  ("s" opencode-select-session :color blue)
  ("c" opencode-select-child-session :color blue)
  ("p" opencode-open-parent :color blue)
  ("i" opencode-select-idle :color blue)
  ("l" opencode-visit-last-idle :color blue)
  ;; Share
  ("h" opencode-share-session :color blue)
  ("u" opencode-unshare-session)
  ("U" opencode-unshare-all-sessions)
  ("L" opencode-consult-sessions :color blue)
  ;; Misc
  ("y" opencode-yank-code-block)
  ("Y" opencode-copy-conversation)
  ("t" opencode-scroll-to-last-response-start))

(with-eval-after-load 'opencode-sessions
  (define-key opencode-session-mode-map (kbd "C-c h") #'hydra-opencode-session/body))

(provide 'config-opencode)
;;; config-opencode.el ends here
