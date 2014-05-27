

(defvar dc-name (if (or (equal "i386" (getenv "HOSTTYPE"))
						(equal "i386-cygwin" (getenv "HOSTTYPE"))
						)
					(format "%s/bin/nt/dc" (getenv "GAMEDIR"))
					(format "%s/bin/linux/dc" (getenv "GAMEDIR"))
					)
  )
(defun dc ()
  "Invoke dc without any argument."
  (interactive)
  ;; we skip the regular dc prompt. You may ajust this variable when using specific prompt.
  (setq comint-prompt-regexp "^[0-9]+:=> ")
  (cd (getenv "GAMESRCDIR"))
  (comint-run dc-name))

;;(defvar toggle-to-dc-last-dc-buffer nil)
;;(defvar toggle-to-dc-common-dc-buffer-name "*dc*")
;; (defun toggle-to-dc ()
;;   "On each invocation, switch back and forth between the dc subprocess
;; buffer and the source buffer from which this function was invoked."
;;   (interactive)
;;   (let (target-buffer)
;;     (cond 
;; 	 ((memq major-mode '(inferior-common-dc-mode dc-listener-mode comint-mode))
;; 	  (or (setq target-buffer toggle-to-dc-last-dc-buffer)
;; 		  (error "There is no previous source buffer.")))
;; 	 (t ;; a dc source buffer
;; 	  (let ((proc (get-buffer-process toggle-to-dc-common-dc-buffer-name)))
;; 		(unless (and proc (memq (process-status proc) '(open run stop)))
;; 		  (call-interactively 'dc)))
;; 	  (setq toggle-to-dc-last-dc-buffer (current-buffer))
;; 	  (setq target-buffer toggle-to-dc-common-dc-buffer-name))
;; 	 )
;; 	(switch-to-buffer target-buffer)
;;     ))


(defvar dc-buffer-name "*dc*")

(defun goto-dc-buffer ()
  (interactive)

  (let ((buf (get-buffer dc-buffer-name)))
	(cond
	 (buf
	  (switch-to-buffer buf)
	  (select-window (get-buffer-window buf))
	  (goto-char (point-max)))
	 
	 (t
	  (switch-to-buffer dc-buffer-name)
	  )))

  (unless (get-buffer-process dc-buffer-name)
	(insert (format "Starting...\n"))
	(call-interactively 'dc)))

  ;; (cond
  ;;  ((get-buffer "*dc*")
  ;; 	(cond
  ;; 	 ((equal "*dc*" (buffer-name))
  ;; 	  (toggle-to-dc))
  ;; 	 ((get-buffer-window (get-buffer "*dc*"))
  ;; 	  (setq toggle-to-dc-last-dc-buffer (current-buffer))
  ;; 	  (select-window (get-buffer-window (get-buffer "*dc*"))))
  ;; 	 (t
  ;; 	  (setq toggle-to-dc-last-dc-buffer (current-buffer))
  ;; 	  (switch-to-buffer (get-buffer "*dc*")))
  ;; 	 )
  ;; 	)
  ;;  (t
  ;; 	(call-interactively 'dc)
  ;; 	)
  ;;  )
  ;; (when (equal "*dc*" (buffer-name))
  ;; 	(goto-char (point-max)))
  ;; )

(defun dce ()
  (interactive)
  (switch-to-buffer dc-buffer-name)
  (insert (format "\n\n  * Ctrl-UP/DOWN to scroll through command-line history.\n")
		  (format "  * Ctrl-LEFT/RIGHT skips words like normal.\n")
		  (format "  * Alt-LEFT/RIGHT will skip entire ()'s. It will also skip\n")
		  (format "    full words (including dashes).\n")
		  (format "  * To quit DC type Ctrl-D.\n")
		  (format "  * To (re)start DC hit F10.\n")
		  (format "  * To exit emacs, type Alt-Q (quit DC first).\n")
		  (format "  * You can cut and paste using Ctrl-X/C/V to and from this window.\n")
		  (format "  * To test out code, paste it into the DC window and hit enter.\n")
		  (format "  * Type Ctrl-G to cancel various modes or \"stuck\"-ness.\n\n"))
  ;; Initial frame size.
  ;; (set-frame-height (selected-frame) 60)
  ;; (set-frame-width (selected-frame) 100)
  ;; (raise-frame)

  (dc)
  )

;;
;; Saves the current *dc* buffer and executes a simple command into dc
;; Checks if we have a *dc* buffer
(defun compile-dc ()
  "Save and reload parameters into dc"
  (interactive)
  (save-buffer)
  (let ((dc-string (buffer-name))
	(bin-string (replace-in-string (buffer-name) ".dc" ".bin")))
    (if (string-match "\.dc$" dc-string)
	(progn
	  (princ (format "Compiling and sending to *dc*"))
	  (comint-simple-send "*dc*" (concat "(make \"" dc-string "\") (reload \"" bin-string "\")"))))))

(defun eval-top-sexp-in-dc ()
  (interactive)
  (let (beg end form)
	(save-excursion
	  (end-of-defun)
	  (setq end (point))
	  (beginning-of-defun)
	  (setq beg (point))
	  ;;(setq form (read (current-buffer)))
	  (setq form (buffer-substring beg end))
	  )

	;;(comint-simple-send "*dc*" (format "'%s" form))
	(comint-simple-send "*dc*" (format "(map (compose compile-import-value ps3-eval-inst) (extract-eval '%s))" form))
	))

(defun eval-last-sexp-in-dc ()
  (interactive)
  ;;(comint-simple-send "*dc*" (preceding-sexp))
  ;;(comint-simple-send "*dc*" "(+ 1 2 3 4)")
  (comint-simple-send "*dc*" (format "%S" (preceding-sexp)))
  ;;(comint-send-string "*dc*" (format "%S" (preceding-sexp)))
  ;;(toggle-to-dc)
  )

(put 'struct 'scheme-indent-function 1)
(put 'enum 'scheme-indent-function 1)



