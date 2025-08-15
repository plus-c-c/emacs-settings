(defun dashboard-external-device-format (dev-name)
  "Format function for 'dashboard-insert-external-devices'."
  (let* ((dev-list (match-device-space (external-device-path el) (device-space-list))))
    (format "%s : %s / %s - %s used"
	    el
	    (nth 2 dev-list)
	    (nth 3 dev-list)
	    (nth 4 dev-list))
    )
  )
(defun dashboard-insert-external-devices (list-size)
  "Add the list of LIST-SIZE items of external devices."
  (setq dashboard--projects-cache-item-format nil)
  (dashboard-insert-section
   "External Devices:"
   (dashboard-subseq (external-device-names) list-size)
   list-size
   'external-devices
   (dashboard-get-shortcut 'external-devices)
   `(lambda (&rest _)
     (find-file (external-device-path ,el)))
   (dashboard-external-device-format el)
   )
  )
(add-to-list 'dashboard-item-generators
	     '(external-devices . dashboard-insert-external-devices))



(provide 'dashboard-config)
