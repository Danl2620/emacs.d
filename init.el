
(if (fboundp 'pc-selection-mode)
	(pc-selection-mode)
  (require 'pc-select))

(setq pc-select-meta-moves-sexps t)

(require 'ido)
(ido-mode t)

(require 'git)

(cond
 ((equal "cygwin" (getenv "OSTYPE"))
  (unless noninteractive
	(require 'gnuserv)
	(gnuserv-start)
	(setq gnuserv-frame (selected-frame))
	)

  ;; setup cygwin
  (require 'cygwin-mount)
  (cygwin-mount-activate)
  )
 )

(cua-mode t)

(unless noninteractive
  (unless (equal "cygwin" (getenv "OSTYPE"))
	(autoload 'gtags-mode "gtags" "" t)
	(autoload 'git-blame-mode "git-blame" "Minor mode for incremental blame for Git." t)
	(autoload 'gitsum "gitsum" "" t))
  ;;(require 'bigloo)
  ;;(require 'quack)
  (load-library "cscope.el")
  (require 'xcscope)
  (require 'pager)
  (load-library "p4")

  (push "~/.emacs.d/color-theme" load-path)
  (require 'color-theme)
  (color-theme-initialize)
  )

;; Set misc. variables
;;
(setq inhibit-startup-message t
      frame-title-format (concat invocation-name "@" system-name)
      window-min-height 2
      visible-bell t
      line-number-mode t
      column-number-mode t
      transient-mark-mode t
      cursor-in-non-selected-windows nil
	  cua-enable-cursor-indications t
	  p4-file-refresh-timer-time 0
	  p4-do-find-file nil
	  scroll-step 1
	  tab-width 4
	  cua-mode-global-mark-cursor-color "cyan"
	  cua-normal-cursor-color "green2"
	  cua-overwrite-cursor-color "yellow"
	  cua-read-only-cursor-color "darkgreen"

	  mouse-wheel-scroll-amount '(1)
	  mouse-wheel-progressive-speed t

      next-line-add-newlines nil
      mouse-yank-at-point t
      auto-save-default nil
      make-backup-files nil)

(tool-bar-mode -1)

(fset 'yes-or-no-p 'y-or-n-p)

;; turn on p4 status check under linux.  under cygwin it'll hang for non p4 files for some reason
(p4-set-vc-mode (equal "linux" (getenv "OSTYPE")))

 ;;  (p4-toggle-vc-mode-on))
 ;; (t
 ;;  (p4-toggle-vc-mode-off)))

;; ;; set the default shell to tcsh  -- doesn't work!!!
;; (add-hook 'comint-output-filter-functions 'shell-strip-ctrl-m nil t)
;; (add-hook 'comint-output-filter-functions 'comint-watch-for-password-prompt nil t)
;; (setq explicit-shell-file-name "z:/tools/cygwin/bin/tcsh.exe")
;; ;; For subprocesses invoked via the shell
;; ;; (e.g., "shell -c command")
;; (setq shell-file-name explicit-shell-file-name)

;
;; (progn
;;   (setq semantic-load-turn-useful-things-on t)
;;   (load-file "C:\\local\\emacs-21.3\\site-lisp\\cedet-1.0pre3\\common\\cedet.el")
;;   (setq semanticdb-project-roots (list "~/big/src/game" "~/big/src/common"))
;;   )

;;(desktop-save-mode 1)

;; c/c++ mode
(autoload 'cscope-bind-keys "cscope" nil t)

;; python mode
(autoload 'python-mode "python-mode" "Python editing mode." t)

;; matlab mode
(autoload 'matlab-mode "matlab" "Enter Matlab mode." t)

;; csharp mode
(autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)

;; charter mode
(autoload 'charter-mode "charter-mode" "Major mode for editing Charter files." t)

;; haskell mode
;;(load "haskell-mode-2.1/haskell-site-file.el")
;;(load "haskell/haskell-site-file")
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)

;; caml mode
(push '("\\.ml$" . tuareg-mode) auto-mode-alist)
(push '("\\.fs$" . tuareg-mode) auto-mode-alist) ;; throw F# files in there too
(autoload 'tuareg-mode "tuareg" "Major mode for editing Caml code" t)
(autoload 'camldebug "camldebug" "Run the Caml debugger" t)

;; mel mode
(add-to-list 'auto-mode-alist '("\\.mel$" . mel-mode))
(autoload 'mel-mode "mel-mode" nil t)

;; php mode
(require 'php-mode)

(if (and (boundp 'window-system) window-system)
    (when (string-match "XEmacs" emacs-version)
       	(if (not (and (boundp 'mule-x-win-initted) mule-x-win-initted))
            (require 'sym-lock))
       	(require 'font-lock)))

;; enable syntax highlighting
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)
(show-paren-mode t)

;; alt opens menus?
(setq w32-pass-alt-to-system t)

;; Initial frame size.
;; (set-frame-height (selected-frame) 50)
;; (set-frame-width (selected-frame) 150)
;; (raise-frame)

;; scroll in single line steps
(setq scroll-step 1)
(setq scroll-conservatively 50)

;; don't create ~ files
(setq make-backup-files nil)

;; set the frame title
(set 'frame-title-format '("Emacs " " - " " [%b (%f)%+]"))

(setq auto-save-default nil)

;; home key toggles between beginning of line and beginning of code
(defun windows-goto-beginning-of-line ()
  (interactive)
  (let ((old (point)))
    (beginning-of-line)
    (forward-to-indentation 0)
    (when (eq old (point))
      (beginning-of-line))))

(defun windows-goto-beginning-of-line-mark ()
  (interactive)
  (ensure-mark)
  (windows-goto-beginning-of-line))


;; customize modes
(push '("\\.py$" . python-mode) auto-mode-alist)
(push '("python" . python-mode) interpreter-mode-alist)
(push '("\\.m$" . matlab-mode) auto-mode-alist)
(push '("\\.h$" . c++-mode) auto-mode-alist)   ;; make sure .h files are loaded in c++ mode
(push '("\\.cl$" . lisp-mode) auto-mode-alist)
(push '("\\.ss$" . scheme-mode) auto-mode-alist)
(push '("\\.dc$" . scheme-mode) auto-mode-alist)
(push '("\\.rkt$" . scheme-mode) auto-mode-alist)
(push '("\\.un$" . scheme-mode) auto-mode-alist)
(push '( "\\.cs$" . csharp-mode) auto-mode-alist)
(push '("\\.sc$" . lisp-mode) auto-mode-alist)
(push '("\\.adb$" . c-mode) auto-mode-alist)
(push '("\\.ent$" . charter-mode) auto-mode-alist)
(push '("\\.asi$" . charter-mode) auto-mode-alist)
(push '("\\.xaml$" . xml-mode) auto-mode-alist)

;;
;; keys
;;

(global-set-key [f1] 'help)
;; f2 load project specific files (see below)
(global-set-key [f3] 'ff-find-other-file)
(global-set-key [f4] 'comment-region)
(global-set-key [S-f4] 'uncomment-region)
(global-set-key [f6] 'tags-search)
;;(global-set-key [(shift f5)] 'tags-query-replace)
;;(global-set-key [(control f5)] 'list-tags)
(global-set-key [(meta f6)] 'tags-apropos)
;;(global-set-key [(control meta f5)] 'visit-tags-table)
(global-set-key [f7] 'compile-big)
(global-set-key [C-f7] 'compile-file)
(global-set-key [f8] 'find-code)
(global-set-key [f9] 'toggle-unscript-buffers)
(global-set-key [f10] 'goto-dc-buffer)
(global-set-key [f11] 'other-window)
(global-set-key [S-f11] 'delete-other-windows)
(global-set-key [f12] 'save-buffer)
;;(global-set-key [home] 'beginning-of-line)
(global-set-key [home] 'windows-goto-beginning-of-line)
(global-set-key [end] 'end-of-line)
(global-set-key [C-home] 'beginning-of-buffer)
(global-set-key [C-end] 'end-of-buffer)
(global-set-key [C-tab] 'ido-switch-buffer)
(global-set-key [S-tab] 'tab-to-tab-stop)
(global-set-key "\M-w" 'ido-switch-buffer)
(global-set-key "\C-a" 'mark-whole-buffer)
(global-set-key "\C-b" 'ibuffer)
(global-set-key "\C-d" 'ido-dired)
(global-set-key "\C-f" 'isearch-forward)
(define-key isearch-mode-map "\C-f" 'isearch-repeat-forward)
(global-set-key "\C-h" 'query-replace)
(global-set-key "\C-j" 'goto-line)
(global-set-key "\C-o" 'ido-find-file)
(global-set-key "\C-p" 'eval-last-sexp-in-dc)
(global-set-key "\C-s" 'save-buffer)
(global-set-key "\C-t" 'eval-top-sexp-in-dc)
(global-set-key "\C-w" 'ido-kill-buffer)
(global-set-key "\M-q" 'save-buffers-kill-emacs)
(global-set-key [M-left] 'backward-sexp)
(global-set-key [M-right] 'forward-sexp)
(global-set-key [delete] 'delete-char)
(global-set-key [M-C-right] 'windmove-right)
(global-set-key [M-C-left] 'windmove-left)
(global-set-key [M-C-up] 'windmove-up)
(global-set-key [M-C-down] 'windmove-down)
(global-set-key [S-home] 'windows-goto-beginning-of-line-mark)
(global-set-key [M-down] 'next-error)
(global-set-key [M-up] 'previous-error)

(global-set-key [C-f12] 'call-last-kbd-macro)
(global-set-key [mouse-2] 'ignore)

;; pager keys
(global-set-key [next] 'pager-page-down)
(global-set-key [prior] 'pager-page-up)
(global-set-key [C-up] 'pager-row-up)
(global-set-key [C-down] 'pager-row-down)
(global-set-key [mouse-4] 'pager-row-up)
(global-set-key [mouse-5] 'pager-row-down)

(add-hook 'before-save-hook (lambda () (delete-trailing-whitespace)))

(add-hook 'c-mode-common-hook (lambda ()
								(set-variable 'tab-width 4)
								(set-variable 'comment-style 'indent)
								(set-variable 'c-basic-offset 4)
								(c-set-offset 'brace-list-open 0)
								(c-set-offset 'substatement-open 0)

								(set-variable 'truncate-lines t)

								;; tab can work on selections
								(define-key c-mode-map [tab] 'c-indent-line-or-region)
								(define-key c++-mode-map [tab] 'c-indent-line-or-region)

								;; enter will newline and indent
								(define-key c-mode-map "\C-m" (lambda ()
																(interactive)
																(newline)
																(c-indent-line)
																))
								(define-key c++-mode-map "\C-m" (lambda ()
																  (interactive)
																  (newline)
																  (c-indent-line)
																  ))
								(define-key c++-mode-map "\M-q" 'save-buffers-kill-emacs)
								))

(add-hook 'scheme-mode-hook (lambda ()
					  		  (setf comment-add 1)
							  (set-variable 'tab-width 4)
							  (set-variable 'comment-style 'indent)

                              ;; indent with spaces
                              ;;(setq indent-tabs-mode nil)
							  (define-key scheme-mode-map "\C-m" (lambda ()
																   (interactive)
																   (newline)
																   (lisp-indent-line)
																   ))

							  (add-hook 'local-write-file-hooks 'check-parens)
							  ))

(add-hook 'python-mode-hook (lambda ()
							  (setq indent-tabs-mode nil)
							  ))

(add-hook 'emacs-lisp-mode-hook (lambda ()
								  (set-variable 'tab-width 4)))

(defun indent-and-save-buffer ()
  "Indent and save the current buffer"
  ;;(c-set-style "stroustrup")
  (indent-region (point-min) (point-max) nil)
  (save-buffer)
  )

;;(add-hook  c-special-indent-hook)
;;(put 'field-set! 'fi:lisp-indent-hook '(like when))

(defun find-code (dir term)
  (interactive
   (progn
   	 (ensure-minibuffer-visible)
   	 (list (ido-read-directory-name "Search directory: ")
   		   (read-from-minibuffer "Search term: ")
   		   ))
   )
  ;;(cd dir)
  (let ((src-file-regex "[^^@]*\.\\(c\\|cxx\\|cpp\\|h\\|hpp\\|cc\\|hh\\|cs\\|inl\\|el\\|asm\\|py\\|d\\|scm\\|ss\\|dc\\)"))
  	(compilation-start
  	 (format "find %s -iregex '%s' -print0 | xargs -0 -r --max-procs=16 egrep -nH %s" dir src-file-regex term)
  	 'grep-mode nil)
  	))

(load-library "files")
(load-library "big")
(load-library "scheme-setup")
(load-library "dc")
(load-library "unscript")

;; final setup
(setq compile-command "mk hybrid")

(unless noninteractive
 (color-theme-danl))

;; (custom-set-variables
;;  '(comint-scroll-to-bottom-on-input t)  ; always insert at the bottom
;; ;; '(comint-scroll-to-bottom-on-output t) ; always add output at the bottom
;;  '(comint-scroll-show-maximum-output t) ; scroll to show max possible output

;;  '(comint-prompt-read-only '())

;; ;; '(comint-prompt-regexp "^\\(ps3>\\|>\\) ")
;; ;; '(comint-use-prompt-regexp t)

;;  ;;'(comint-eol-on-send t)
;;  )



;; (cd (getenv "GAMESRCDIR"))

