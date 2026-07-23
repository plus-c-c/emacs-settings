;;; internet-methods.el --- Internet interface for emacs. -*- lexical-binding: t -*-
(provide 'internet-methods)

(defvar network-connected--cache nil
  "Cached network status: (RESULT . TIMESTAMP).")
(defvar network-connected--cache-ttl 30
  "Cache TTL in seconds. Avoids repeated subprocess calls.")

(defun network-connected--check ()
  "Actual network connectivity check (subprocess)."
  (cond
   ((memq system-type '(windows-nt cygwin ms-dos))
    (string-equal (shell-command-to-string "powershell Test-Connection 8.8.8.8 -Count 1 -Quiet") "True\n"))
   ((eq system-type 'darwin)
    (zerop (call-process "ping" nil nil nil "-c" "1" "-W" "1" "8.8.8.8")))
   (t
    (string-equal (shell-command-to-string "nmcli -t -f STATE general") "connected\n"))))

(defun network-connected-p ()
  "Check whether network is connected. Uses cached result within TTL."
  (let ((now (float-time)))
    (if (and network-connected--cache
             (< (- now (cdr network-connected--cache)) network-connected--cache-ttl))
        (car network-connected--cache)
      (let ((result (network-connected--check)))
        (setq network-connected--cache (cons result now))
        result))))

(defun auto-download-from-web (url file)
  "Download URL to FILE using platform-appropriate tool."
  (if (memq system-type '(windows-nt cygwin ms-dos))
      (shell-command (concat "powershell Invoke-WebRequest -Uri " url " -OutFile " file))
    (shell-command (concat "curl " url " -o " file))))
