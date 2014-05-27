

;; keywords
(font-lock-add-keywords
 'scheme-mode
 '("\\<\\(defenum\\)" "\\<\\(defbitlist\\)" "\\<\\(deftype\\)" "\\<\\(defun-extern\\)" "\\<\\(defun\\)"
   "\\<\\(define/public\\)"
   "\\<usr0\\>" "\\<usr1\\>" "\\<usr2\\>" "\\<usr3\\>"
   "\\<\\(def-particle\\)\\>"
   "\\<\\(def-particle-group\\)\\>"
   "\\<\\(def-curve\\)\\>"
   "\\<\\(declare-type\\)"
   "\\<\\(declare-c-type\\)"
   "\\<\\(declare-c-function\\)"
   "\\<\\(declare-bitlist\\)"
   )
 )

(global-set-key (kbd "M-\\")
                (lambda () (interactive nil) (insert "λ")))

;; scheme indentation
(put 'when 'scheme-indent-function 1)
(put 'unless 'scheme-indent-function 1)
(put 'while 'scheme-indent-function 1)
(put 'until 'scheme-indent-function 1)
(put 'dotimes 'scheme-indent-function 1)
(put 'module 'scheme-indent-function 2)
(put 'match 'scheme-indent-function 1)

(defun scheme-indent-two-parms (state indent-point normal-indent)
  (let ((containing-form-start (nth 1 state))
        (i 0)
        containing-form-column)
    ;; <snip documentation>
    (goto-char containing-form-start)
    (setq containing-form-column (current-column))
    (forward-char 1)
    (forward-sexp 1)
    ;; Now find the start of the last form.
    (parse-partial-sexp (point) indent-point 1 t)
    (while (and (< (point) indent-point)
                (condition-case ()
                    (progn
                      (setq i (1+ i))
                      (forward-sexp 1)
                      (parse-partial-sexp (point) indent-point 1 t))
                  (error nil))))
    ;; Point is sitting on first character of last (or count) sexp.
    (cond ((= i 0)
           (+ containing-form-column (* 2 lisp-body-indent)))
          ((= i 1) normal-indent)
          (t (+ containing-form-column lisp-body-indent)))))

(put 'awhen 'scheme-indent-function 'scheme-indent-two-parms)
(put 'aif 'scheme-indent-function 'scheme-indent-two-parms)
(put 'receive 'scheme-indent-function 'scheme-indent-two-parms)
(put 'syntax-case 'scheme-indent-function 'scheme-indent-two-parms)
(put 'syntax-case* 'scheme-indent-function 'scheme-indent-two-parms)

;;; This is a *slightly* modified version of what is in scheme.el,
;;; which is itself a slight modification of `lisp-indent-function'
;;; from lisp-mode.el.  Gee, you'd think that someone would think of
;;; the notion of 'abstraction' here...

(defun scheme-indent-function (indent-point state)
  (let ((normal-indent (current-column)))
    (goto-char (1+ (elt state 1)))
    (parse-partial-sexp (point) calculate-lisp-indent-last-sexp 0 t)
    (if (and (elt state 2)
             (not (looking-at "\\sw\\|\\s_")))
        ;; car of form doesn't seem to be a symbol
        (progn
          (if (not (> (save-excursion (forward-line 1) (point))
                      calculate-lisp-indent-last-sexp))
              (progn (goto-char calculate-lisp-indent-last-sexp)
                     (beginning-of-line)
                     (parse-partial-sexp (point)
                                         calculate-lisp-indent-last-sexp 0 t)))
          ;; Indent under the list or under the first sexp on the same
          ;; line as calculate-lisp-indent-last-sexp.  Note that first
          ;; thing on that line has to be complete sexp since we are
          ;; inside the innermost containing sexp.
          (backward-prefix-chars)
          (current-column))
      (let ((function (downcase         ;** downcasage added by TRC
                       (buffer-substring (point)
                                         (progn (forward-sexp 1) (point)))))
            method)
        (setq method (or (get (intern-soft function) 'scheme-indent-function)
                         (get (intern-soft function) 'scheme-indent-hook)))
        (cond ((or (eq method 'defun)
                   (and (null method)
                        (> (length function) 3)
                        (or (string-match "\\`def" function)
							(string-match "\\`dec" function))))
               (lisp-indent-defform state indent-point))
              ;** WITH-... & CALL-WITH-... forms added by TRC
              ((or (eq method 'with-...)
                   (eq method 'call-with-...)
                   (and (null method)
                        (or (and (> (length function) 5)
                                 (string-match "\\`with-" function))
                            (and (> (length function) 9)
                                 (string-match "\\`call-with-" function)))))
               (lisp-indent-withform state indent-point))
              ((integerp method)
               (lisp-indent-specform method state
                                     indent-point normal-indent))
              (method
               (funcall method state indent-point normal-indent)))))))

;++ This is an approximation.  It fails for something like:
;++   (with-foo bar
;++     baz (quux))
;++ It could be generalized to negative special form indent methods; e.g.,
;++   (put 'with-frobbotzim 'scheme-indent-function -2)
;++ and then
;++   (with-frobbotzim frob grovel
;++       full lexical
;++       mumble chumble
;++       spuzz
;++    (lambda (foo) ...)
;++    (lambda (bar) ...))
;++ That is, the last two subforms would be indented two spaces, whereas all
;++ preceding subforms would get four spaces.

(defun lisp-indent-withform (state indent-point)
  (if (not (and (boundp 'paredit-mode)
                paredit-mode))
      ;; If we're not in paredit mode, it's not really safe to go backwards
      ;; from the end and to try to indent based on that, since there may not
      ;; be an end to work backwards from (i.e. the structure not be valid).
      (lisp-indent-defform state indent-point)
    (goto-char (nth 1 state))
    (let ((body-column (+ (current-column)
                          lisp-body-indent)))
      (forward-sexp 1)
      (backward-char 1)
      (backward-sexp 1)
      (skip-chars-backward " \t" (point-at-bol))
      (if (= (point) indent-point)
          body-column
          ;; If it's not the last argument, then we must specify not only the
          ;; column to indent to but also the start of the containing sexp,
          ;; which implies (don't ask me how) that any *following* subforms
          ;; must be indented separately, and not just on this column.  This
          ;; allows C-M-q to know to indent the penultimate arguments with four
          ;; spaces, but to keep recomputing the indentation so that it doesn't
          ;; assume the last one will go to the same column, which is a wrong
          ;; assumption.
          (list (+ body-column lisp-body-indent)
                (nth 1 state))))))