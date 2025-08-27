(defun webdev-pull-remote ()
  (shell-command "rclone sync nutstore: ~/Documents/emacs/org-notes/mobile &"))
(defun webdev-push-remote ()
  (shell-command "rclone sync ~/Documents/emacs/org-notes/mobile nutstore: &"))

(provide 'webdev-methods)
