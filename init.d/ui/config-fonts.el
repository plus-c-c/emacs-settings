;;; config-fonts.el --- Font settings for emacs. -*- lexical-binding: t -*-
(use-package font-utils
  :ensure t)
(unless (or (daemonp) (font-utils-exists-p "all-the-icons"))
  (if (memq system-type '(windows-nt cygwin ms-dos))
      (shell-command "./fonts.ps1")
    (all-the-icons-install-fonts t)))
(require 'subr-x) ;; cl-loop来自这里
(defvar cabins--fonts-default '("SauceCodePro Nerd Font Mono" "CaskaydiaCove Nerd Font Mono" "Consolas"))
(defvar cabins--fonts-unicode '("Segoe UI Symbol" "Symbola" "Symbol"))
(defvar cabins--fonts-emoji '("Segoe UI Symbol" "Noto Sans Symbols 2" "Noto Sans Symbols"))
(defvar cabins--fonts-cjk '("WenQuanYi Micro Hei Mono" "WenQuanYi Zen Hei Mono" "Microsoft Yahei"))
;; WenQuanYi Micro Hei Mono's CJK advance width is not exactly 2x
;; SauceCodePro Nerd Font Mono's Latin width at the default size; the
;; 1.18 scale makes CJK glyphs exactly double-width so org tables align.
(push '("WenQuanYi Micro Hei Mono" . 1.18) face-font-rescale-alist)
(push '("WenQuanYi Zen Hei Mono" . 1.18) face-font-rescale-alist)
(defun cabins--set-font-common (character font-list &optional scale-factor frame)
  "Set fonts for multi CHARACTER from FONT-LIST and modify style with SCALE-FACTOR.
When FRAME is non-nil, also set the frame's own fontset so new frames
are not affected by already-cached font entries."

  (cl-loop for font in font-list
     when (find-font (font-spec :name font))
     return (progn
        (if (not character)
      (set-face-attribute 'default nil :family font )
          (let ((spec (font-spec :family font :registry "iso10646-1")))
        (set-fontset-font t character spec nil 'prepend)
        (when frame
          (set-fontset-font nil character spec frame 'prepend))))
        (when scale-factor (add-to-list 'face-font-rescale-alist
                `(,font . ,scale-factor)))
        )))

(defun cabins--font-setup (&optional default-fonts unicode-fonts emoji-fonts cjk-fonts frame)
  "Font setup, with optional DEFAULT-FONTS, UNICODE-FONTS, EMOJI-FONTS, CJK-FONTS.
FRAME is the frame whose fontset should be modified.  When FRAME is
non-nil the frame fontset is modified directly, and the default face
is re-applied afterwards because `set-fontset-font' with a frame
argument can otherwise alter the default face family."

  (interactive)
  (when (display-graphic-p (or frame (selected-frame)))
    (let ((fr (or frame (selected-frame))))
      (cabins--set-font-common nil (if default-fonts default-fonts cabins--fonts-default) nil fr)
      (cabins--set-font-common 'unicode (if unicode-fonts unicode-fonts cabins--fonts-unicode) nil fr)
      (cabins--set-font-common 'emoji (if emoji-fonts emoji-fonts cabins--fonts-emoji) nil fr)
      (dolist (charset '(kana han bopomofo cjk-misc))
        (cabins--set-font-common charset (if cjk-fonts cjk-fonts cabins--fonts-cjk) nil fr))
      (when frame
        (cabins--set-font-common nil (if default-fonts default-fonts cabins--fonts-default) nil fr)))))
;; Set font size (height in 1/10pt: 55 * 2.0 = 110)
(set-face-attribute 'default nil :height (round (* 55 emacs-hidpi-scale)))
;; In daemon mode there is no display at load time, so fonts and
;; fontsets cannot be applied here.  A frame's fontset is created
;; independently of `fontset-default' and only takes effect once the
;; frame exists, so defer to after the frame is fully created.
(when (daemonp)
  (add-hook 'after-make-frame-functions
            #'(lambda (frame)
                (run-with-timer 1 nil
                  (lambda ()
                    (when (and (frame-live-p frame)
                               (display-graphic-p frame))
                      (cabins--font-setup nil nil nil nil frame)))))))
(cabins--font-setup)
(provide 'config-fonts)
