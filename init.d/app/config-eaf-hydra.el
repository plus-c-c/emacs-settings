;;; config-eaf-hydra.el --- Per-app EAF hydra menus -*- lexical-binding: t -*-

(defhydra eaf-browser-hydra (:color blue :hint nil)
  "
 ^EAF Browser^
^^^^^^^──────────────────────────────────────
 ^Navigation^           ^Tabs^             ^View^
_j_ Scroll Up           _J_ Left Tab       _=_ Zoom In
_k_ Scroll Down         _K_ Right Tab      _-_ Zoom Out
_h_ Scroll Left         _t_ New Tab        _0_ Zoom Reset
_l_ Scroll Right        _x_ Close Tab      _T_ Reader Mode
SPC Page Down          _P_ Duplicate       _d_ Dark Mode
_b_ Page Up             ^ ^                _p_ Toggle Device
_g_ Top                 ^ ^                _1_ Save PDF
_G_ Bottom              ^ ^                _2_ Save Single File
^ ^                    ^ ^                 _3_ Screenshot

 ^Links^                ^Edit^             ^Paper^
 _f_ Open Link           _e_ Edit URL       _i_ Import Page
 _F_ Open New Tab        _M-w_ Copy Text    _I_ Import + PDF
 _B_ Open Background     _C-M-c_ Copy Code  _r_ Raw Import
 _O_ Open Other Window   _C-M-l_ Copy Link  _d_ Import DOI
 _s_ Open Link           _u_ Get URL        _a_ Import arXiv
 ^ ^                    _n_ Export Text    _p_ Import PubMed
 ^ ^                    _v_ View Source     _o_ Open Browser
 ^ ^                    ^ ^                _q_ Quit
"
  ;; Navigation
  ("j" (eaf-call-async "send_key" eaf--buffer-id "j"))
  ("k" (eaf-call-async "send_key" eaf--buffer-id "k"))
  ("h" (eaf-call-async "send_key" eaf--buffer-id "h"))
  ("l" (eaf-call-async "send_key" eaf--buffer-id "l"))
  ("SPC" (eaf-call-async "send_key" eaf--buffer-id "SPC"))
  ("b" (eaf-call-async "send_key" eaf--buffer-id "u"))
  ("g" (eaf-call-async "send_key" eaf--buffer-id "g"))
  ("G" (eaf-call-async "send_key" eaf--buffer-id "G"))
  ;; Tabs
  ("J" (eaf-call-async "send_key" eaf--buffer-id "J"))
  ("K" (eaf-call-async "send_key" eaf--buffer-id "K"))
  ("t" (eaf-call-async "send_key" eaf--buffer-id "t"))
  ("x" (eaf-call-async "send_key" eaf--buffer-id "x"))
  ("P" (eaf-call-async "send_key" eaf--buffer-id "P"))
  ;; View
  ("=" (eaf-call-async "send_key" eaf--buffer-id "="))
  ("-" (eaf-call-async "send_key" eaf--buffer-id "-"))
  ("0" (eaf-call-async "send_key" eaf--buffer-id "0"))
  ("T" (eaf-call-async "send_key" eaf--buffer-id ","))
  ("d" (eaf-call-async "send_key" eaf--buffer-id "M-d"))
  ("p" (eaf-call-async "send_key" eaf--buffer-id "p"))
  ("1" (eaf-call-async "send_key" eaf--buffer-id "1"))
  ("2" (eaf-call-async "send_key" eaf--buffer-id "2"))
  ("3" (eaf-call-async "send_key" eaf--buffer-id "3"))
  ;; Links
  ("f" (eaf-call-async "send_key" eaf--buffer-id "f"))
  ("F" (eaf-call-async "send_key" eaf--buffer-id "F"))
  ("B" (eaf-call-async "send_key" eaf--buffer-id "B"))
  ("O" (eaf-call-async "send_key" eaf--buffer-id "O"))
  ("s" (eaf-call-async "send_key" eaf--buffer-id "M-s"))
  ;; Edit
  ("e" (eaf-call-async "send_key" eaf--buffer-id "e"))
  ("M-w" (eaf-call-async "send_key" eaf--buffer-id "M-w"))
  ("C-M-c" (eaf-call-async "send_key" eaf--buffer-id "C-M-c"))
  ("C-M-l" (eaf-call-async "send_key" eaf--buffer-id "C-M-l"))
  ("u" (call-interactively 'eaf-get-path-or-url))
  ("n" (eaf-call-async "send_key" eaf--buffer-id "n"))
  ("v" (eaf-call-async "send_key" eaf--buffer-id "v"))
  ;; Paper Import
  ("i" paper-import-from-browser)
  ("I" (lambda () (interactive) (paper-import-from-browser '(4))))
  ("r" paper-import-raw)
  ("d" paper-import-doi)
  ("a" paper-import-arxiv)
  ("p" paper-import-pubmed)
  ;; Other
  ("o" browse-web)
  ("q" nil "Quit" :color blue))

(defhydra eaf-pdf-hydra (:color blue :hint nil)
  "
 ^EAF PDF Viewer^
^^^^^^^──────────────────────────────────────
 ^Navigation^           ^Zoom^             ^Annotate^
_j_ Scroll Up           _=_ Zoom In        _M-h_ Highlight
_k_ Scroll Down         _-_ Zoom Out       _M-u_ Underline
_h_ Scroll Left         _0_ Zoom Reset     _M-s_ Squiggly
_l_ Scroll Right        _w_ Fit Width      _M-d_ Strikeout
SPC Page Down          _W_ Close Width     _M-t_ Popup Text
_b_ Page Up             ^ ^                _M-T_ Inline Text
_g_ Top                 ^ ^                _M-e_ Edit Annot
_G_ Bottom              ^ ^                _M-r_ Move Annot
_p_ Jump to Page        ^ ^                _C-/_ Undo
_P_ Jump to Percent     ^ ^                _C-?_ Redo

 ^View^                 ^Interleave^       ^Other^
_t_ Read Mode           _a_ Add Note       _i_ Invert Mode
_c_ Center Horizontal   _O_ Open Notes     _C-i_ Invert Image
_r_ Reload              _s_ Sync Note      _z_ OCR
_n_ Next Note           _p_ Prev Note      _o_ Outline
_C-<right>_ Rotate R                   _O_ Outline Edit
_C-<left>_ Rotate L     ^ ^                _T_ Trim Margin
_x_ Close               ^ ^                _C-t_ Last Position
"
  ;; Navigation
  ("j" (eaf-call-async "send_key" eaf--buffer-id "j"))
  ("k" (eaf-call-async "send_key" eaf--buffer-id "k"))
  ("h" (eaf-call-async "send_key" eaf--buffer-id "h"))
  ("l" (eaf-call-async "send_key" eaf--buffer-id "l"))
  ("SPC" (eaf-call-async "send_key" eaf--buffer-id "SPC"))
  ("b" (eaf-call-async "send_key" eaf--buffer-id "b"))
  ("g" (eaf-call-async "send_key" eaf--buffer-id "g"))
  ("G" (eaf-call-async "send_key" eaf--buffer-id "G"))
  ("p" (eaf-call-async "send_key" eaf--buffer-id "p"))
  ("P" (eaf-call-async "send_key" eaf--buffer-id "P"))
  ;; Zoom
  ("=" (eaf-call-async "send_key" eaf--buffer-id "="))
  ("-" (eaf-call-async "send_key" eaf--buffer-id "-"))
  ("0" (eaf-call-async "send_key" eaf--buffer-id "0"))
  ("w" (eaf-call-async "send_key" eaf--buffer-id "w"))
  ("W" (eaf-call-async "send_key" eaf--buffer-id "W"))
  ;; View
  ("t" (eaf-call-async "send_key" eaf--buffer-id "t"))
  ("c" (eaf-call-async "send_key" eaf--buffer-id "c"))
  ("r" (eaf-call-async "send_key" eaf--buffer-id "r"))
  ("C-<right>" (eaf-call-async "send_key" eaf--buffer-id "C-<right>"))
  ("C-<left>" (eaf-call-async "send_key" eaf--buffer-id "C-<left>"))
  ("x" (eaf-call-async "send_key" eaf--buffer-id "x"))
  ;; Annotate
  ("M-h" (eaf-call-async "send_key" eaf--buffer-id "M-h"))
  ("M-u" (eaf-call-async "send_key" eaf--buffer-id "M-u"))
  ("M-s" (eaf-call-async "send_key" eaf--buffer-id "M-s"))
  ("M-d" (eaf-call-async "send_key" eaf--buffer-id "M-d"))
  ("M-t" (eaf-call-async "send_key" eaf--buffer-id "M-t"))
  ("M-T" (eaf-call-async "send_key" eaf--buffer-id "M-T"))
  ("M-e" (eaf-call-async "send_key" eaf--buffer-id "M-e"))
  ("M-r" (eaf-call-async "send_key" eaf--buffer-id "M-r"))
  ("C-/" (eaf-call-async "send_key" eaf--buffer-id "C-/"))
  ("C-?" (eaf-call-async "send_key" eaf--buffer-id "C-?"))
  ;; Interleave
  ("a" eaf-interleave-add-note-auto-create)
  ("O" eaf-interleave-open-notes-file-auto-create)
  ("s" eaf-interleave-sync-current-note)
  ("n" eaf-interleave-sync-next-note)
  ("p" eaf-interleave-sync-previous-note)
  ;; Other
  ("i" (eaf-call-async "send_key" eaf--buffer-id "i"))
  ("C-i" (eaf-call-async "send_key" eaf--buffer-id "C-i"))
  ("z" (eaf-call-async "send_key" eaf--buffer-id "z"))
  ("o" (eaf-call-async "send_key" eaf--buffer-id "o"))
  ("T" (eaf-call-async "send_key" eaf--buffer-id "T"))
  ("C-t" (eaf-call-async "send_key" eaf--buffer-id "C-t"))
  ("q" nil "Quit" :color blue))

(defhydra eaf-image-hydra (:color blue :hint nil)
  "
 ^EAF Image Viewer^
^^^^^^^──────────────────────────────────────
 ^Navigate^             ^Zoom^             ^Transform^
_n_ Next Image          _,_ Zoom Out       _u_ Rotate Left
_p_ Prev Image          _._ Zoom In        _i_ Rotate Right
SPC Prev Image          _/_ Zoom Reset     _y_ Flip Horizontal
_r_ Reload              _0_ Toggle Zoom    _o_ Flip Vertical

 ^Move^                 ^File Transform^   ^Other^
_j_ Move Up             _U_ Rotate File L  _d_ Delete Image
_k_ Move Down           _I_ Rotate File R  _x_ Close
_h_ Move Left           _O_ Flip File Hor
_l_ Move Right          ^ ^
"
  ("n" (eaf-call-async "send_key" eaf--buffer-id "n"))
  ("p" (eaf-call-async "send_key" eaf--buffer-id "p"))
  ("SPC" (eaf-call-async "send_key" eaf--buffer-id "SPC"))
  ("r" (eaf-call-async "send_key" eaf--buffer-id "r"))
  ("," (eaf-call-async "send_key" eaf--buffer-id ","))
  ("." (eaf-call-async "send_key" eaf--buffer-id "."))
  ("/" (eaf-call-async "send_key" eaf--buffer-id "/"))
  ("0" (eaf-call-async "send_key" eaf--buffer-id "0"))
  ("u" (eaf-call-async "send_key" eaf--buffer-id "u"))
  ("i" (eaf-call-async "send_key" eaf--buffer-id "i"))
  ("y" (eaf-call-async "send_key" eaf--buffer-id "y"))
  ("o" (eaf-call-async "send_key" eaf--buffer-id "o"))
  ("j" (eaf-call-async "send_key" eaf--buffer-id "j"))
  ("k" (eaf-call-async "send_key" eaf--buffer-id "k"))
  ("h" (eaf-call-async "send_key" eaf--buffer-id "h"))
  ("l" (eaf-call-async "send_key" eaf--buffer-id "l"))
  ("U" (eaf-call-async "send_key" eaf--buffer-id "U"))
  ("I" (eaf-call-async "send_key" eaf--buffer-id "I"))
  ("O" (eaf-call-async "send_key" eaf--buffer-id "O"))
  ("d" (eaf-call-async "send_key" eaf--buffer-id "d"))
  ("x" (eaf-call-async "send_key" eaf--buffer-id "x"))
  ("q" nil "Quit" :color blue))

(defhydra eaf-video-hydra (:color blue :hint nil)
  "
 ^EAF Video Player^
^^^^^^^──────────────────────────────────────
 ^Control^               ^Volume^           ^Other^
SPC Toggle Play         _j_ Volume Down    _f_ Fullscreen
_h_ Backward             _k_ Volume Up      _r_ Restart
_l_ Forward              ^ ^                _x_ Close
"
  ("SPC" (eaf-call-async "send_key" eaf--buffer-id "SPC"))
  ("h" (eaf-call-async "send_key" eaf--buffer-id "h"))
  ("l" (eaf-call-async "send_key" eaf--buffer-id "l"))
  ("j" (eaf-call-async "send_key" eaf--buffer-id "j"))
  ("k" (eaf-call-async "send_key" eaf--buffer-id "k"))
  ("f" (eaf-call-async "send_key" eaf--buffer-id "f"))
  ("r" (eaf-call-async "send_key" eaf--buffer-id "r"))
  ("x" (eaf-call-async "send_key" eaf--buffer-id "x"))
  ("q" nil "Quit" :color blue))

(defhydra eaf-video-editor-hydra (:color blue :hint nil)
  "
 ^EAF Video Editor^
^^^^^^^──────────────────────────────────────
 ^Control^               ^Edit^             ^Other^
SPC Toggle Play         _c_ Clip Point     _f_ Fullscreen
_h_ Backward             _n_ Mute Point     _r_ Restart
_l_ Forward              _p_ Toggle Clips   _e_ Export
_j_ Volume Down          ^ ^                _x_ Close
_k_ Volume Up            ^ ^
"
  ("SPC" (eaf-call-async "send_key" eaf--buffer-id "SPC"))
  ("h" (eaf-call-async "send_key" eaf--buffer-id "h"))
  ("l" (eaf-call-async "send_key" eaf--buffer-id "l"))
  ("j" (eaf-call-async "send_key" eaf--buffer-id "j"))
  ("k" (eaf-call-async "send_key" eaf--buffer-id "k"))
  ("c" (eaf-call-async "send_key" eaf--buffer-id "c"))
  ("n" (eaf-call-async "send_key" eaf--buffer-id "n"))
  ("p" (eaf-call-async "send_key" eaf--buffer-id "p"))
  ("f" (eaf-call-async "send_key" eaf--buffer-id "f"))
  ("r" (eaf-call-async "send_key" eaf--buffer-id "r"))
  ("e" (eaf-call-async "send_key" eaf--buffer-id "e"))
  ("x" (eaf-call-async "send_key" eaf--buffer-id "x"))
  ("q" nil "Quit" :color blue))

(defhydra eaf-music-hydra (:color blue :hint nil)
  "
 ^EAF Music Player^
^^^^^^^──────────────────────────────────────
 ^Playback^              ^Navigate^         ^Sort^
SPC Toggle Play         _j_ Next Track     _C-e_ Sort Title
_h_ Random               _k_ Prev Track     _C-t_ Sort Artist
_,_ Backward             _p_ Playlist Prev   _C-m_ Sort Album
_._ Forward              _n_ Playlist Next   ^ ^
_t_ Toggle Order         ^ ^                ^ ^
_g_ Jump to File         ^ ^                ^ ^
"
  ("SPC" (eaf-call-async "send_key" eaf--buffer-id "SPC"))
  ("h" (eaf-call-async "send_key" eaf--buffer-id "h"))
  ("," (eaf-call-async "send_key" eaf--buffer-id ","))
  ("." (eaf-call-async "send_key" eaf--buffer-id "."))
  ("t" (eaf-call-async "send_key" eaf--buffer-id "t"))
  ("g" (eaf-call-async "send_key" eaf--buffer-id "g"))
  ("j" (eaf-call-async "send_key" eaf--buffer-id "j"))
  ("k" (eaf-call-async "send_key" eaf--buffer-id "k"))
  ("p" (eaf-call-async "send_key" eaf--buffer-id "p"))
  ("n" (eaf-call-async "send_key" eaf--buffer-id "n"))
  ("C-e" (eaf-call-async "send_key" eaf--buffer-id "C-e"))
  ("C-t" (eaf-call-async "send_key" eaf--buffer-id "C-t"))
  ("C-m" (eaf-call-async "send_key" eaf--buffer-id "C-m"))
  ("q" nil "Quit" :color blue))

(defun eaf-show-app-hydra ()
  "Show hydra for current EAF app."
  (interactive)
  (pcase eaf--buffer-app-name
    ("browser"     (eaf-browser-hydra/body))
    ("pdf-viewer"  (eaf-pdf-hydra/body))
    ("image-viewer"(eaf-image-hydra/body))
    ("video-player"(eaf-video-hydra/body))
    ("video-editor"(eaf-video-editor-hydra/body))
    ("music-player"(eaf-music-hydra/body))
    (_ (message "[EAF] No hydra for: %s" eaf--buffer-app-name))))

(defun eaf-hydra-setup ()
  "Bind C-c e in eaf-mode-map."
  (define-key eaf-mode-map (kbd "C-c e") 'eaf-show-app-hydra))

(add-hook 'eaf-mode-hook 'eaf-hydra-setup)

(provide 'config-eaf-hydra)
;;; config-eaf-hydra.el ends here
