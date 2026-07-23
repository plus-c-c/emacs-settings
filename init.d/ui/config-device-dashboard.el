;;; config-device-dashboard.el --- Device bar for dashboard. -*- lexical-binding: t -*-
(require 'config-dashboard)
(require 'device-methods)

(defun dashboard-external-device-format (dev-name)
  "Format function for `dashboard-insert-external-devices'."
  (let* ((dev-list (match-device-details-by-path
        (if (eq system-type 'gnu/linux)
      (external-device-path dev-name)
          dev-name)
        (device-detailed-list))))
    (if (eq system-type 'gnu/linux)
  (format "%s : %s / %s - %s used"
    dev-name (nth 2 dev-list) (nth 3 dev-list) (nth 4 dev-list))
      (let ((parts (nthcdr (- (length dev-list) 4) dev-list)))
        (format "%s : %s %s%s / %s%s left"
                dev-name (nth 2 dev-list)
                (car parts) (cadr parts)
                (caddr parts) (cadddr parts))))))

(defun dashboard-insert-external-devices (list-size)
  "Add the list of LIST-SIZE items of external devices."
  (setq dashboard--projects-cache-item-format nil)
  (dashboard-insert-section
   "Devices:"
   (dashboard-subseq (external-device-names) list-size)
   list-size
   'external-devices
   (dashboard-get-shortcut 'external-devices)
   `(lambda (&rest _) (find-file (external-device-path ,el)))
   (dashboard-external-device-format el)))

(defun dashboard-register-devices ()
  "Register external devices section in dashboard if any are present."
  (when (external-device-names)
    (add-to-list 'dashboard-item-generators
                 '(external-devices . dashboard-insert-external-devices))
    (add-to-list 'dashboard-items '(external-devices . 10))
    (add-to-list 'dashboard-item-shortcuts '(external-devices . "d"))))

;; Defer device detection to avoid subprocess calls at load time
(run-with-idle-timer 1.0 nil #'dashboard-register-devices)
(provide 'config-device-dashboard)
