(require 'linux-interleave)
(defun eaf-org-open-file (file &optional link) "An wrapper function on eaf=open."
		  (eaf-open file))
       (add-to-list 'org-file-apps '("\\.pdf\\'" . eaf-org-open-file))
	   (add-to-list 'org-file-apps '("\\.x?html?\\'" . eaf-org-open-file))
(provide 'linux-notes)
