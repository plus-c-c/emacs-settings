;;; internet-methods.el --- Internet interface for emacs. -*- lexical-binding: t -*-
(provide 'internet-methods)
(defun auto-download-from-web (url file)
  (if (memq system-type '(windows-nt cygwin ms-dos))
      (shell-command (concat "powershell Invoke-WebRequest -Uri " url " -OutFile " file))
    (shell-command (concat "curl " url " -o " file))
      ))
(defun network-connected-p ()
  "Check whether network is connected."
  (string-equal (shell-command-to-string "nmcli -t -f STATE general") "connected\n"))
