

(defvar unscript-name (if (or (equal "i386" (getenv "HOSTTYPE"))
							  (equal "i386-cygwin" (getenv "HOSTTYPE"))
							  )
						  (format "%s/bin/nt/unscript" (getenv "GAMEDIR"))
						(format "%s/bin/linux/unscript" (getenv "GAMEDIR"))
						))

(defun unscript ()
  "Invoke unscript without any argument."
  (interactive)
  ;; we skip the regular unscript prompt. You may ajust this variable when using specific prompt.
  (setq comint-prompt-regexp "^[0-9]+:=> ")
  (comint-run unscript-name))

(defvar toggle-to-unscript-last-unscript-buffer nil)
(defvar toggle-to-unscript-common-unscript-buffer-name "*unscript*")
(defun toggle-to-unscript ()
  "On each invocation, switch back and forth between the unscript subprocess
buffer and the source buffer from which this function was invoked."
  (interactive)
  (let (target-buffer)
    (cond 
	 ((memq major-mode '(inferior-common-unscript-mode unscript-listener-mode comint-mode))
	  (or (setq target-buffer toggle-to-unscript-last-unscript-buffer)
		  (error "There is no previous source buffer.")))
	 (t ;; a unscript source buffer
	  (let ((proc (get-buffer-process toggle-to-unscript-common-unscript-buffer-name)))
		(unless (and proc (memq (process-status proc) '(open run stop)))
		  (call-interactively 'unscript)))
	  (setq toggle-to-unscript-last-unscript-buffer (current-buffer))
	  (setq target-buffer toggle-to-unscript-common-unscript-buffer-name))
	 )
	(switch-to-buffer target-buffer)
    ))
(defun toggle-unscript-buffers ()
  (interactive)
  (cond
   ((get-buffer "*unscript*")
	(cond
	 ((equal "*unscript*" (buffer-name))
	  (toggle-to-unscript))
	 ((get-buffer-window (get-buffer "*unscript*"))
	  (setq toggle-to-unscript-last-unscript-buffer (current-buffer))
	  (select-window (get-buffer-window (get-buffer "*unscript*"))))
	 (t
	  (setq toggle-to-unscript-last-unscript-buffer (current-buffer))
	  (switch-to-buffer (get-buffer "*unscript*")))
	 )
	)
   (t
	(call-interactively 'unscript)
	)
   )
  (when (equal "*unscript*" (buffer-name))
	(goto-char (point-max)))
  )


;;
;; Saves the current *unscript* buffer and executes a simple command into unscript
;; Checks if we have a *unscript* buffer
(defun compile-unscript ()
  "Save and reload parameters into unscript"
  (interactive)
  (save-buffer)
  (let ((unscript-string (buffer-name))
	(bin-string (replace-in-string (buffer-name) ".un" ".bin")))
    (if (string-match "\.un$" unscript-string)
	(progn
	  (princ (format "Compiling and sending to *unscript*"))
	  (comint-simple-send "*unscript*" (concat "(make \"" unscript-string "\") (reload \"" bin-string "\")"))))))

(defun eval-last-sexp-in-unscript ()
  (interactive)
  ;;(comint-simple-send "*dc*" (preceding-sexp))
  ;;(comint-simple-send "*dc*" "(+ 1 2 3 4)")

  (comint-simple-send "*unscript*" (format "%S" (preceding-sexp)))
  ;;(comint-send-string "*dc*" (format "%S" (preceding-sexp)))
  ;;(toggle-to-dc)
  )

(put 'struct 'scheme-indent-function 1)



