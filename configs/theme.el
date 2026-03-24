;;; theme.el --- Theme Switcher -*- lexical-binding: t; -*-

;; Persistence: ~/.active-theme stores the active theme name.
;; Call (my-theme-load-saved) in init.el to restore it on startup.

(defvar my-active-theme-file (expand-file-name "~/.emacs.d/.active-theme")
  "File that persists the active theme name across Emacs restarts.")

;; Font resolver: picks font based on OS, falls back to "monospace".
(defvar my--coding-font
  (cond
   ((eq system-type 'windows-nt)
    (if (find-font (font-spec :family "Lucida Console"))
        "Lucida Console" "monospace"))
   ((eq system-type 'darwin)
    (if (find-font (font-spec :family "Menlo"))
        "Menlo" "monospace"))
   ((eq system-type 'gnu/linux)
    (if (find-font (font-spec :family "DejaVu Sans Mono"))
        "DejaVu Sans Mono" "monospace"))
   (t "monospace"))
  "Best available monospace font for the current OS.")

;; Each entry is a plist:
;;   :name    - display name used in the switcher and in ~/.active-theme
;;   :base    - built-in Emacs theme symbol to load as the base
;;   :faces   - alist of (FACE . ATTRS) — any valid Emacs face is accepted
;;   :lsp     - alist of (FACE . ATTRS) for lsp-mode faces (applied after lsp loads)

(defvar my-themes
  (list
   (list :name "Default"
         :base 'tango-dark
         :faces
         `((default                      . (:foreground "#c8c8c0" :family ,my--coding-font :height 110 :weight normal))
           (cursor                        . (:background "#e8c080"))
           (dired-directory               . (:foreground "#e0b070" :weight normal))
           (font-lock-builtin-face        . (:foreground "#c8c8c0"))
           (font-lock-comment-face        . (:foreground "#c09060" :slant italic))
           (font-lock-constant-face       . (:foreground "#d8a868"))
           (font-lock-function-call-face  . (:foreground "#c8c8c0"))
           (font-lock-function-name-face  . (:foreground "#e0b070" :weight bold))
           (font-lock-keyword-face        . (:foreground "#d4a060" :weight bold))
           (font-lock-string-face         . (:foreground "#d4a060"))
           (font-lock-type-face           . (:foreground "#d0d0c8"))
           (font-lock-variable-name-face  . (:foreground "#c8c8c0")))
         :lsp
         '((lsp-face-highlight-read      . (:background "#2a2420"))
           (lsp-face-highlight-textual   . (:background "#2a2420"))
           (lsp-face-highlight-write     . (:background "#342d26"))))

   (list :name "Rosé Pine"
         :base 'modus-vivendi
         :faces
         `((default                      . (:foreground "#c8c8c8" :background "#191724" :family ,my--coding-font :height 110 :weight normal))
           ;;(cursor                        . (:background "#eb6f92"))
           (cursor                        . (:background "#f6c177"))
           (fringe                        . (:background "#191724"))
           (region                        . (:background "#264733" :foreground unspecified))
           (highlight                     . (:background "#2a2742"))
           (mode-line                     . (:background "#12101e" :foreground "#9893a5"))
           (mode-line-inactive            . (:background "#161320" :foreground "#6e6a86"))
		   ;; (line-number                   . (:foreground "#6e6a86" :background "#191724"))
		   ;; (line-number-current-line      . (:foreground "#6e6a86" :background "#191724"))
           (minibuffer-prompt             . (:foreground "#eb6f92" :weight bold))
           (dired-directory               . (:foreground "#7ab8a0" :weight normal :inherit nil))
           (font-lock-builtin-face        . (:foreground "#9ccfd8"))
           (font-lock-comment-face        . (:foreground "#0f9552" :slant italic))
           (font-lock-constant-face       . (:foreground "#ebbcba"))
           (font-lock-function-call-face  . (:foreground "#e0def4"))
           (font-lock-function-name-face  . (:foreground "#eb6f92" :weight bold))
           (font-lock-keyword-face        . (:foreground "#c4a7e7" :weight bold))
           (font-lock-string-face         . (:foreground "#f6c177"))
           (font-lock-type-face           . (:foreground "#9ccfd8"))
           (font-lock-variable-name-face  . (:foreground "#e0def4")))
         :lsp
         '((lsp-face-highlight-read      . (:background "#26233a"))
           (lsp-face-highlight-textual   . (:background "#26233a"))
           (lsp-face-highlight-write     . (:background "#2a2742"))))))

(defvar my-current-theme nil
  "Name of the currently active theme (set by `my-theme-switch').")

;;; ── Persistence ──────────────────────────────────────────────────────────────

(defun my--save-active-theme (name)
  "Write NAME to `my-active-theme-file'."
  (with-temp-file my-active-theme-file
    (insert name)))

(defun my--read-active-theme ()
  "Return the theme name stored in `my-active-theme-file', or nil."
  (when (file-exists-p my-active-theme-file)
    (string-trim
     (with-temp-buffer
       (insert-file-contents my-active-theme-file)
       (buffer-string)))))

;;; ── Core apply ───────────────────────────────────────────────────────────────

;; (defun my--apply-face-list (face-list)
;;   "Apply a list of (FACE . ATTRS) pairs, warning on unknown faces."
;;   (dolist (entry face-list)
;;     (condition-case err
;;         (apply #'set-face-attribute (car entry) nil (cdr entry))
;;       (error (message "Theme warning: skipping face `%s' — %s"
;;                       (car entry) (error-message-string err))))))
(defun my--apply-face-list (face-list)
  "Apply faces at `user' theme priority, surviving any load-theme calls."
  (dolist (entry face-list)
    (condition-case err
        (progn
          (apply #'set-face-attribute (car entry) nil (cdr entry))
          (face-spec-set (car entry)
                         `((t ,(cdr entry)))
                         'face-override-spec))
      (error
       (when after-init-time
         (message "Theme warning: skipping face `%s' — %s"
                  (car entry) (error-message-string err)))))))


(defvar my--startup-faces nil
  "Faces to re-apply on `emacs-startup-hook'. Set by `my--apply-theme'.")

(defun my--startup-reapply ()
  "Re-apply theme faces after Emacs is fully started."
  (when my--startup-faces
    (my--apply-face-list my--startup-faces)))

;; Registered once — fires after all packages and desktop have loaded
(add-hook 'emacs-startup-hook #'my--startup-reapply)
;; Re-apply theme faces whenever dired opens (fixes color on reopen)
(add-hook 'dired-mode-hook
          (lambda ()
            (when my-current-theme
              (let* ((found (cl-find my-current-theme my-themes
                                     :key (lambda (p) (plist-get p :name))
                                     :test #'string=))
                     (faces (plist-get found :faces))
                     (dired-face (assq 'dired-directory faces)))
                (when dired-face
                  (apply #'set-face-attribute
                         'dired-directory nil (cdr dired-face)))))))

(defun my--apply-theme (theme-plist)
  "Disable all themes, load :base, apply :faces, schedule reapply at startup."
  (let ((base      (plist-get theme-plist :base))
        (faces     (plist-get theme-plist :faces))
        (lsp-faces (plist-get theme-plist :lsp))
        (name      (plist-get theme-plist :name)))
    ;; 1. Disable all active themes
    (mapc #'disable-theme custom-enabled-themes)
    ;; 2. Load the base theme
    (load-theme base t)
    ;; 3. Apply faces immediately (best effort — some may not exist yet)
    (my--apply-face-list (append faces lsp-faces))
    ;; 4. Store faces for emacs-startup-hook to re-apply dead last
    (setq my--startup-faces (append faces lsp-faces))
    ;; 5. Persist + track
    (my--save-active-theme name)
    (setq my-current-theme name)
    (message "Theme: %s" name)))

;;; ── Public commands ──────────────────────────────────────────────────────────

;;;###autoload
(defun my-theme-switch ()
  "Pick a theme interactively.  The active theme is marked with \" (active)\"."
  (interactive)
  (let* ((candidates
          (mapcar (lambda (p)
                    (let ((n (plist-get p :name)))
                      (if (equal n my-current-theme)
                          (concat n " (active)")
                        n)))
                  my-themes))
         (choice (completing-read "Switch theme: " candidates nil t))
         (bare   (replace-regexp-in-string " (active)$" "" choice))
         (found  (cl-find bare my-themes
                          :key  (lambda (p) (plist-get p :name))
                          :test #'string=)))
    (if found
        (my--apply-theme found)
      (user-error "Unknown theme: %s" bare))))

;;;###autoload
(defun my-theme-load-saved ()
  "Restore the theme from `my-active-theme-file'.  Call this from init.el."
  (let* ((saved (my--read-active-theme))
         (found (when saved
                  (cl-find saved my-themes
                           :key  (lambda (p) (plist-get p :name))
                           :test #'string=))))
    (my--apply-theme (or found (car my-themes)))))

(provide 'theme)
;;; theme.el ends here
