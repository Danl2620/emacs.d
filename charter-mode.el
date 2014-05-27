;;; charter-mode.el --- Charter mode derived from C++


(add-hook 'charter-mode-hook
		  (lambda ()
			(font-lock-add-keywords 
			 nil
			 '("\\<Name\\>"
			   "\\<DisplayName\\>"
			   "\\<GroupName\\>"
			   "\\<ActorSpawner\\>"
			   "\\<Schema\\>"
			   "\\<LayerIndex\\>"
			   "\\<SpawnMethod\\>"
			   "\\<ArtGroup\\>"
			   "\\<Position\\>"
			   "\\<Rotation\\>"
			   "\\<Scale\\>"
			   "\\<Properties\\>"
			   "\\<Entity\\>"
			   "\\<Height\\>"
			   "\\<Script\\>"
			   "\\<Point\\>"
			   "\\<Tag\\>"
			   "\\<Tags\\>"
			   "\\<PointIds\\>"
			   "\\<Linkage\\>"
			   "\\<Transform\\>"
			   "\\<StateScript\\>"
			   "\\<Closed\\>"
			   "\\<Linear\\>"
			   "\\<PatrolMotion\\>"
			   "\\<PatrolRepeat\\>"
			   "\\<PatrolWaitTime\\>"
			   "\\<PatrolArrivalEvent\\>"
			   "\\<PatrolEventTarget\\>"
			   ))
			))


;;;###autoload
(defun charter-mode ()
  "Major mode for editing Charter files.
Key bindings:
\\{c++-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (c-initialize-cc-mode t)
  (set-syntax-table c++-mode-syntax-table)
  (setq major-mode 'charter-mode
		mode-name "Charter"
		local-abbrev-table c++-mode-abbrev-table
		abbrev-mode t)
  (use-local-map c++-mode-map)
  (c-init-language-vars-for 'c++-mode)
  (c-common-init 'c++-mode)
  (easy-menu-add c-c++-menu)
  (cc-imenu-init cc-imenu-c++-generic-expression)
  (c-run-mode-hooks 'c-mode-common-hook 'c++-mode-hook 'charter-mode-hook)
  (c-update-modeline))


(provide 'charter-mode)
