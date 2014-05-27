
(defun ensure-minibuffer-visible ()
  (let ((screen (window-frame (minibuffer-window))))
    (when screen (raise-frame screen))))

(defun get-file-list (directory regex)
  (let ((files (directory-files directory nil regex t))
		(subdirs (directory-files-and-attributes directory t "^[^.#~]+$" t))
		(file-alist nil)
		)
	(dolist (elt files)
	  (push (cons (format "%s (%s/%s)" elt directory elt) (format "%s/%s" directory elt)) file-alist))
	(dolist (dir-info subdirs)
	  (when (eq (second dir-info) t) ;; is it a directory?
		(setq file-alist (append (get-file-list (first dir-info) regex) file-alist))))
	file-alist
	)
  )
