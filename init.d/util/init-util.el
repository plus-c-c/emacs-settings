;;; init-util.el --- Utility functions loader -*- lexical-binding: t -*-

(require 'device-methods)

(require 'internet-methods)

(defvar emacs-hidpi-scale 2.0
  "Display scale factor for HiDPI settings.
Controls font sizes and UI scaling. Default 2.0 for 2x displays.
Set to 1.0 for standard displays.")

(provide 'init-util)
