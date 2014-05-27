
;;; big specific stuff
(setq *game-local-data-dir* (getenv "GAMELOCALDATADIR"))
(setq *big-file-list* nil)
(setq *source-file-suffixes* '("c" "cxx" "cpp" "cs" "h" "cc" "hh" "inl" "el" "asm" "py" "d" "scm" "ss" "dc" "un" "mk" "xaml" "xml"))
;;(setq *source-file-regex* (format "\\`[^^@]*\\.\\(%s\\)\\'" (mapconcat 'identity *source-file-suffixes* "\\|")))
(setq *source-file-regex* (format "^[^.#~]+\\.\\(%s\\)$" (mapconcat 'identity *source-file-suffixes* "\\|")))

(defun get-big-file-list ()
  (let* ((game-src-dir (getenv "GAMESRCDIR"))
		 (shared-dir (format "%s/%s/shared" (getenv "HOME") (getenv "GAMEBRANCH")))
		 (shared-src-dir (format "%s/src" shared-dir))
		 (tools-src-dir (getenv "TOOLSSRCDIR")))
	(nconc (get-file-list (format "%s/game" game-src-dir) *source-file-regex*)
		   (get-file-list (format "%s/ndlib" shared-src-dir) *source-file-regex*)
		   (get-file-list (format "%s/plt/collects/dc" shared-src-dir) *source-file-regex*)
		   (get-file-list (format "%s/sharedmath" shared-src-dir) *source-file-regex*)
		   (get-file-list (format "%s/emacs" shared-dir) *source-file-regex*)
		   (get-file-list (format "%s/dc" shared-dir) *source-file-regex*)
		   ;;(get-file-list (format "%s/common" game-src-dir) *source-file-regex*)
		   ;;(get-file-list (format "%s/game-external" game-src-dir) *source-file-regex*)
		   (get-file-list (format "%s/src/tools" tools-src-dir) *source-file-regex*)
		   (get-file-list (format "%s/src/common" tools-src-dir) *source-file-regex*)
		   (get-file-list (format "%s/ice" shared-src-dir) *source-file-regex*)
	       )))

(defun get-big-file-name (prompt)
  (unless *big-file-list*
    ;;(error "searching directories for big files...")
    (setq *big-file-list* (get-big-file-list))
    )
  (ensure-minibuffer-visible)
  (completing-read (format "%s: " prompt) *big-file-list* nil t)
  )

(defun find-big-file (file)
  (interactive
   (list (get-big-file-name "Big File"))
   )

  (let ((path (cdr (assoc file *big-file-list*)))
	)
    (cond
     ((file-exists-p path)
      (find-file path)
      )
     (t
      (beep)
      (error (format "Unknown big file '%s'" file))
      )
     )
    )
  )

(defun refresh-find-big-file (file)
  (interactive
   (progn
     (setq *big-file-list* nil)
     (list (get-big-file-name "Big File"))
	 )
   )
  (find-big-file file)
  )

(setq *big-level-list* (let ((search-dir (format "%s/db/entdb/levels" *game-local-data-dir*)))
						 (cond
						  ((file-readable-p search-dir)
						   (mapcar (function (lambda (name) 
											   (cons name (format "%s/%s" search-dir name))))
								   (directory-files search-dir nil "^[^.#~]+$" nil)
								   ))
						  (t ()))))

(defun get-level-name (prompt)
  (ensure-minibuffer-visible)
  (completing-read (format "%s: " prompt) *big-level-list* nil t)
  )
(defun find-big-level-dir (level)
  (interactive
   (list (get-level-name "Level Name"))
   )

  (dired (cdr (assoc level *big-level-list*)))
  )

(if (string-match "XEmacs\\|Lucid" emacs-version)
	(progn
	 (global-set-key 'f2 'find-big-file)
	 (global-set-key '(control f2) 'refresh-find-big-file)
	 (global-set-key 'f5 'find-big-level-dir)
	 )
  (progn
   (global-set-key [f2] 'find-big-file)
   (global-set-key [C-f2] 'refresh-find-big-file)
   (global-set-key [f5] 'find-big-level-dir)
   )
  )

;; (defvar toggle-to-compilation-last-compilation-buffer nil)
;; (defvar toggle-to-compilation-common-compilation-buffer-name "*compilation*")
;; (defun toggle-to-compilation ()
;;   "On each invocation, switch back and forth between the compilation subprocess
;; buffer and the source buffer from which this function was invoked."
;;   (interactive)
;;   (let (target-buffer)
;;     (cond 
;; 	 ((memq major-mode '(inferior-common-compilation-mode compilation-listener-mode comint-mode))
;; 	  (or (setq target-buffer toggle-to-compilation-last-compilation-buffer)
;; 		  (error "There is no previous source buffer.")))
;; 	 (t ;; a compilation source buffer
;; 	  (let ((proc (get-buffer-process toggle-to-compilation-common-compilation-buffer-name)))
;; 		(unless (and proc (memq (process-status proc) '(open run stop)))
;; 		  (call-interactively 'compilation)))
;; 	  (setq toggle-to-compilation-last-compilation-buffer (current-buffer))
;; 	  (setq target-buffer toggle-to-compilation-common-compilation-buffer-name))
;; 	 )
;; 	(switch-to-buffer target-buffer)
;;     ))


(defun compile-big ()
  (interactive)
  (let ((buf (get-buffer "*compilation*")))
	(when buf
	  (when (get-buffer-window buf)
		(select-window (get-buffer-window buf)))
	 
	  (switch-to-buffer buf)))

  (save-some-buffers t)
  (when (equal "*compilation*" (buffer-name))
	(goto-char (point-max)))
  (call-interactively 'compile))
  

(defun compile-file ()
  (interactive)
  (save-some-buffers t)
  (let ((file (substring (buffer-file-name) 8)))
	(compilation-start (format "dynlink debug %s" file))))


(let ((game-src-dir (getenv "GAMESRCDIR"))
	  (shared-src-dir (format "%s/%s/shared/src" (getenv "HOME") (getenv "GAMEBRANCH")))
	  (tools-src-dir (getenv "TOOLSSRCDIR")))
  (push (format "%s/game" game-src-dir) tags-table-list)
  (push (format "%s/ndlib" shared-src-dir) tags-table-list)
  (push (format "%s/src/tools" tools-src-dir) tags-table-list)
  (push (format "%s/src/common" tools-src-dir) tags-table-list)
  ;;(push (format "%s/game-external" game-src) tags-table-list)
  )