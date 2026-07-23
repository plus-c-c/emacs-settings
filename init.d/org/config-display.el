;;; config-display.el --- Org display utilities -*- lexical-binding: t -*-

(use-package org-inline-anim

  :ensure t
  :hook (org-mode .org-inline-anim-mode))
(provide 'config-display)
