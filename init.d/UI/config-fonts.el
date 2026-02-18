;;; config-fonts.el --- Font settings for emacs. -*- lexical-binding: t -*-
(require 'all-the-icons)
(use-package font-utils
  :ensure t)
(if (not (font-utils-exists-p "all-the-icons"))
    (if (memq system-type '(windows-nt cyg-win ms-dos))
	(shell-command "./fonts.ps1")
      (all-the-icons-install-fonts t)))
(require 'subr-x) ;; cl-loop来自这里
(defvar cabins--fonts-default '("SauceCodePro Nerd Font" "Cascadia Code PL"  "Menlo" "Consolas"))
(defvar cabins--fonts-unicode '("Segoe UI Symbol" "Symbola" "Symbol"))
(defvar cabins--fonts-emoji '("Noto Color Emoji" "Apple Color Emoji"))
(defvar cabins--fonts-cjk '("WenQuanYi Micro Hei" "Microsoft Yahei"))
(defun cabins--set-font-common (character font-list &optional scale-factor)
  "Set fonts for multi CHARACTER from FONT-LIST and modify style with SCALE-FACTOR."

  (cl-loop for font in font-list
	   when (find-font (font-spec :name font))
	   return (progn
		    (if (not character)
			(set-face-attribute 'default nil :family font )
		      (set-fontset-font t character (font-spec :family font) nil 'prepend))
		    (when scale-factor (add-to-list 'face-font-rescale-alist
						    `(,font . ,scale-factor)))
		    )))

(defun cabins--font-setup (&optional default-fonts unicode-fonts emoji-fonts cjk-fonts)
  "Font setup, with optional DEFAULT-FONTS, UNICODE-FONTS, EMOJI-FONTS, CJK-FONTS."

  (interactive)
  (when (display-graphic-p)
    (cabins--set-font-common nil (if default-fonts default-fonts cabins--fonts-default) )
    (cabins--set-font-common 'unicode (if unicode-fonts unicode-fonts cabins--fonts-unicode) )
    (cabins--set-font-common 'emoji (if emoji-fonts emoji-fonts cabins--fonts-emoji) )
    (dolist (charset '(kana han bopomofo cjk-misc))
      (cabins--set-font-common charset (if cjk-fonts cjk-fonts cabins--fonts-cjk) ))))
(cabins--font-setup)
(provide 'config-fonts)
