;;; config-loading.el --- Loading indicator in dashboard -*- lexical-binding: t; -*-
;; During startup, the init-info line is replaced with a centered spinner + progress bar.
;; After deferred modules finish, the original init-info is restored.

(defvar config-loading--active t
  "Non-nil while deferred modules are still loading.")

(defvar config-loading--frames '("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")
  "Spinner frames.")

(defvar config-loading--index 0
  "Current spinner frame.")

(defvar config-loading--timer nil
  "Timer driving the spinner animation.")

(defvar config-loading--start-time nil
  "Time when loading started.")

(defvar config-loading--duration 3
  "Total expected loading duration in seconds.")

(defvar config-loading--bar-width 20
  "Width of the progress bar in characters.")

(defun config-loading--progress ()
  "Return current progress as a float between 0.0 and 1.0."
  (if config-loading--start-time
      (min 1.0 (/ (float (- (time-to-seconds) config-loading--start-time))
                   config-loading--duration))
    0.0))

(defun config-loading--bar ()
  "Return progress bar string like [████████░░░░░░░░░░░░]."
  (let* ((pct (config-loading--progress))
         (filled (round (* pct config-loading--bar-width)))
          (empty (- config-loading--bar-width filled)))
    (format "[%s%s]" (make-string filled ?=) (make-string empty ?-))))

(defun config-loading--spinner-text ()
  "Return centered spinner + progress bar string."
  (let* ((spinner (nth config-loading--index config-loading--frames))
         (pct (round (* (config-loading--progress) 100)))
         (msg (format " %s Loading modules... %s %3d%%"
                      spinner (config-loading--bar) pct))
         (w (frame-width))
         (pad (max 1 (/ (- w (string-width msg)) 2))))
    (concat (make-string pad ?\s) msg)))

(defun config-loading--replace-init-info (orig-fn &rest _)
  "Replace init-info with centered spinner while loading."
  (if config-loading--active
      (insert (propertize (config-loading--spinner-text)
                          'face '(:foreground "#bd93f9")))
    (funcall orig-fn)))

(defun config-loading--refresh ()
  "Advance spinner frame and re-render dashboard."
  (when config-loading--active
    (setq config-loading--index
          (mod (1+ config-loading--index) (length config-loading--frames)))
    (dashboard-open)))

(defun config-loading--finish ()
  "Stop spinner and restore init-info."
  (setq config-loading--active nil)
  (when (timerp config-loading--timer)
    (cancel-timer config-loading--timer)
    (setq config-loading--timer nil))
  (dashboard-open))

(with-eval-after-load 'dashboard
  ;; Record start time
  (setq config-loading--start-time (time-to-seconds))
  ;; Replace init-info with spinner during loading
  (advice-add 'dashboard-insert-init-info :around #'config-loading--replace-init-info)
  ;; Animate spinner every 0.5s
  (setq config-loading--timer
        (run-with-timer 0 0.5 #'config-loading--refresh))
  ;; Finish after 3s
  (run-with-timer 3 nil #'config-loading--finish))

(provide 'config-loading)
;;; config-loading.el ends here
