(use-package holo-layer
  :load-path "~/.emacs.d/site-lisp/holo-layer"
  :custom
  (holo-layer-enable-place-info t)
  (holo-layer-place-info-font-size 24)
  (holo-layer-enable-cursor-animation t)
  :config
  (holo-layer-enable))
(require 'subr-x) ;; cl-loop来自这里
(defvar cabins--fonts-default '("SauceCodePro Nerd Font" "Cascadia Code PL" "Menlo" "Consolas"))
(defvar cabins--fonts-unicode '("Segoe UI Symbol" "Symbola" "Symbol"))
(defvar cabins--fonts-emoji '("Noto Color Emoji" "Apple Color Emoji"))
(defvar cabins--fonts-cjk '("WenQuanYi Micro Hei" "Microsoft Yahei"))
(defun cabins--set-font-common (character font-list &optional scale-factor)
  "Set fonts for multi CHARACTER from FONT-LIST and modify style with SCALE-FACTOR."

  (cl-loop for font in font-list
	   when (find-font (font-spec :name font))
	   return (if (not character)
		      (set-face-attribute 'default nil :family font)
		    (when scale-factor (setq face-font-rescale-alist `((,font . ,scale-factor))))
		    (set-fontset-font t character (font-spec :family font) nil 'prepend))))

(defun cabins--font-setup (&optional default-fonts unicode-fonts emoji-fonts cjk-fonts)
  "Font setup, with optional DEFAULT-FONTS, UNICODE-FONTS, EMOJI-FONTS, CJK-FONTS."

  (interactive)
  (when (display-graphic-p)
    (cabins--set-font-common nil (if default-fonts default-fonts cabins--fonts-default))
    (cabins--set-font-common 'unicode (if unicode-fonts unicode-fonts cabins--fonts-unicode))
    (cabins--set-font-common 'emoji (if emoji-fonts emoji-fonts cabins--fonts-emoji))
    (dolist (charset '(kana han bopomofo cjk-misc))
      (cabins--set-font-common charset (if cjk-fonts cjk-fonts cabins--fonts-cjk) 1.2))))
(add-hook 'emacs-startup-hook #'cabins--font-setup)
(provide 'UI-linux)
