;;; functions.el --- Functions Configuration -*- lexical-binding: t; -*- 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   VARIABLES               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar my-config-dir "~/.emacs.d"
  "My Emacs configuration directory.")

(defvar my-config-file "~/.emacs.d/init.el"
  "My Emacs init file.")

(defvar my-package-default-file "~/.emacs.d/package.default"
  "Human-edited list of explicitly wanted packages, one per line.")

(defvar my-package-lock-dir "~/.emacs.d/package.lock"
  "Directory containing package archives and manifest.
  manifest  -- name=commit reference, one per line (do not edit)
  *.tar.gz  -- one archive per installed package + dependency")

(defvar my-package-manifest-file
  (expand-file-name "manifest.el" "~/.emacs.d/package.lock")
  "Manifest file inside package.lock/ listing name=url@commit per line.")

(defvar my-help-org-file "~/.emacs.d/help.org"
  "Org file displayed by my-help.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   HELPERS                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun cfg ()
  "Open my Emacs configuration directory."
  (interactive)
  (dired my-config-dir))

(defun cfg-file ()
  "Open my Emacs configuration file."
  (interactive)
  (find-file my-config-file))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 MY HELP                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-help ()
  "Display help.org in a read-only org buffer."
  (interactive)
  (if (not (file-exists-p my-help-org-file))
      (message "help.org not found at %s" my-help-org-file)
    (with-current-buffer (get-buffer-create "*My Help*")
      (read-only-mode -1)
      (erase-buffer)
      (insert-file-contents my-help-org-file)
      (org-mode)
      (org-show-all)
      (local-set-key (kbd "q") 'quit-window)
      (read-only-mode 1)
      (goto-char (point-min))
      (pop-to-buffer (current-buffer)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;            MANIFEST HELPERS               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; manifest lives inside package.lock/ dir
;; Format: name=commit  (one per line, deps first, do not edit)

(defun my-manifest-read ()
  "Read manifest.el and return a list of (name url commit dep-of) entries.
dep-of is nil for top-level packages, or the parent name for deps."
  (if (not (file-exists-p my-package-manifest-file))
      '()
    (with-temp-buffer
      (insert-file-contents my-package-manifest-file)
      (let ((lines (delete "" (split-string (buffer-string) "\n" t)))
            (result '()))
        (dolist (line lines result)
          (unless (string-prefix-p ";;" line)
            ;; name=url@commit  or  name=url@commit :dep-of parent
            (when (string-match "^\\([^=]+\\)=\\([^@]+\\)@\\([^ \\n]+\\)\\( :dep-of \\([^ \\n]+\\)\\)?$" line)
              (push (list (match-string 1 line)   ; name
                          (match-string 2 line)   ; url
                          (match-string 3 line)   ; commit
                          (match-string 5 line))  ; dep-of (nil if top-level)
                    result))))))))

(defun my-manifest-append (name url commit &optional dep-of)
  "Append NAME=URL@COMMIT to manifest.el if not already present.
If DEP-OF is non-nil, records this as :dep-of that package."
  (make-directory (expand-file-name my-package-lock-dir) t)
  (unless (assoc name (my-manifest-read))
    (let ((f my-package-manifest-file))
      (when (and (file-exists-p f) (not (file-writable-p f)))
        (set-file-modes f #o644))
      (with-temp-buffer
        (when (file-exists-p f) (insert-file-contents f))
        (goto-char (point-max))
        (when (= (point-min) (point-max))
          (insert ";; AUTO-GENERATED -- DO NOT EDIT\n")
          (insert ";; Format: name=url@commit [:dep-of parent], deps-first.\n"))
        (if dep-of
            (insert name "=" url "@" commit " :dep-of " dep-of "\n")
          (insert name "=" url "@" commit "\n"))
        (write-region (point-min) (point-max) f))
      (set-file-modes f #o444))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;         PACKAGE.DEFAULT HELPERS           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-default-read ()
  "Read package.default and return a list of package name strings."
  (if (not (file-exists-p my-package-default-file))
      '()
    (with-temp-buffer
      (insert-file-contents my-package-default-file)
      (delete "" (split-string (buffer-string) "\n" t)))))

(defun my-default-append (name)
  "Append NAME to package.default if not already present."
  (unless (member name (my-default-read))
    (with-temp-buffer
      (when (file-exists-p my-package-default-file)
        (insert-file-contents my-package-default-file))
      (goto-char (point-max))
      (insert name "\n")
      (write-region (point-min) (point-max) my-package-default-file))))

(defun my-default-remove (name)
  "Remove NAME from package.default."
  (when (file-exists-p my-package-default-file)
    (let ((lines (my-default-read)))
      (with-temp-file my-package-default-file
        (dolist (line (delete name lines))
          (insert line "\n"))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;         PACKAGE ARCHIVE HELPERS           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-archive-path (name)
  "Return the tar.gz path inside package.lock/ for package NAME."
  (expand-file-name (concat name ".tar.gz")
                    (expand-file-name my-package-lock-dir)))

(defun my-archive-package (pkg-name)
  "Create a tar.gz of PKG-NAME from elpa/ into package.lock/.
Returns t on success, nil on failure."
  (make-directory (expand-file-name my-package-lock-dir) t)
  (let* ((desc    (cadr (assq (intern pkg-name) package-alist)))
         (pkg-dir (when desc (package-desc-dir desc)))
         (out     (my-archive-path pkg-name)))
    (if (null pkg-dir)
        (progn (message "archive: %s not found in package-alist" pkg-name) nil)
      (let* ((parent  (file-name-directory (directory-file-name pkg-dir)))
             (dirname (file-name-nondirectory (directory-file-name pkg-dir)))
             (cmd     (format "tar -czf %s -C %s %s"
                              (shell-quote-argument (expand-file-name out))
                              (shell-quote-argument parent)
                              (shell-quote-argument dirname))))
        (if (= 0 (shell-command cmd))
            (progn (message "archive: saved %s.tar.gz" pkg-name) t)
          (message "archive: failed to tar %s" pkg-name) nil)))))

(defun my-unarchive-package (name)
  "Extract NAME.tar.gz from package.lock/ into elpa/.
Returns t on success, nil on failure."
  (let* ((archive  (my-archive-path name))
         (elpa-dir (expand-file-name "elpa" my-config-dir)))
    (if (not (file-exists-p archive))
        (progn (message "archive: %s.tar.gz not found" name) nil)
      (make-directory elpa-dir t)
      (let ((cmd (format "tar -xzf %s -C %s"
                         (shell-quote-argument (expand-file-name archive))
                         (shell-quote-argument elpa-dir))))
        (if (= 0 (shell-command cmd))
            (progn (message "archive: extracted %s" name) t)
          (message "archive: failed to extract %s" name) nil)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;        SHARED RECORD-NEW HELPER           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; After any install: walk package-alist, archive and record anything new.
;; Deps are installed first by MELPA so they appear in package-alist first
;; and get archived/recorded first -- giving deps-first order for free.

(defun my-record-new-packages (&optional top-level-name)
  "Archive and record all installed packages not yet in manifest.
Walks package-alist oldest-first so deps come first.
If TOP-LEVEL-NAME is given, newly seen packages that are not the
top-level package itself are recorded as :dep-of TOP-LEVEL-NAME."
  (let ((recorded (mapcar #'car (my-manifest-read))))
    (dolist (entry (reverse package-alist))
      (let* ((sym    (car entry))
             (name   (symbol-name sym))
             (desc   (cadr entry))
             (extras (when desc (package-desc-extras desc)))
             (url    (cdr (assq :url    extras)))
             (commit (cdr (assq :commit extras))))
        (when (and url commit (not (member name recorded)))
          (when (my-archive-package name)
            (let ((dep-of (when (and top-level-name
                                     (not (string= name top-level-name)))
                            top-level-name)))
              (my-manifest-append name url commit dep-of))
            (push name recorded)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   PACKAGE-INSTALL HOOK -> RECORD + ARCHIVE;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my--after-package-install (pkg &rest _)
  "After package-install, append to package.default and archive+record all new packages.
Deps are recorded as :dep-of the top-level package."
  (let* ((sym  (if (package-desc-p pkg) (package-desc-name pkg) pkg))
         (name (symbol-name sym)))
    (my-default-append name)
    (my-record-new-packages name)))

(advice-add 'package-install :after #'my--after-package-install)

(defun my-resync-lock ()
  "Resync package.lock/ to exactly match what is currently in package-alist.
Deletes archives and manifest entries for packages no longer installed,
archives any new packages not yet in package.lock/.
Called after package-delete so orphaned deps are cleaned up automatically."
  ;; Build set of currently installed package names
  (let* ((installed (mapcar (lambda (e) (symbol-name (car e))) package-alist))
         (lock-dir  (expand-file-name my-package-lock-dir)))
    ;; 1. Remove archives for packages no longer installed
    (when (file-directory-p lock-dir)
      (dolist (f (directory-files lock-dir t "\.tar\.gz$"))
        (let ((pkg-name (file-name-base (file-name-base f)))) ; strip .tar.gz
          (unless (member pkg-name installed)
            (delete-file f)
            (message "package.lock: removed %s.tar.gz" pkg-name)))))
    ;; 2. Rewrite manifest.el keeping only installed packages, preserving order
    (when (file-exists-p my-package-manifest-file)
      (when (not (file-writable-p my-package-manifest-file))
        (set-file-modes my-package-manifest-file #o644))
      (let ((entries (my-manifest-read)))
        (with-temp-file my-package-manifest-file
          (insert ";; AUTO-GENERATED -- DO NOT EDIT\n")
          (insert ";; Format: name=url@commit [:dep-of parent], deps-first.\n")
          (dolist (entry (reverse entries))
            (when (member (nth 0 entry) installed)
              (let ((dep-of (nth 3 entry)))
                (if dep-of
                    (insert (nth 0 entry) "=" (nth 1 entry) "@" (nth 2 entry)
                            " :dep-of " dep-of "\n")
                  (insert (nth 0 entry) "=" (nth 1 entry) "@" (nth 2 entry) "\n")))))))
      (set-file-modes my-package-manifest-file #o444))
    ;; 3. Archive anything installed but not yet in package.lock/
    (my-record-new-packages)))

(defun my--delete-deps-of (parent-name)
  "Delete all packages recorded as :dep-of PARENT-NAME, recursively."
  (let ((entries (my-manifest-read)))
    (dolist (entry entries)
      (when (equal (nth 3 entry) parent-name)
        (let* ((dep-name (nth 0 entry))
               (dep-sym  (intern dep-name))
               (dep-desc (cadr (assq dep-sym package-alist))))
          ;; Recurse -- delete this dep's own deps first
          (my--delete-deps-of dep-name)
          ;; Then delete the package itself
          (when dep-desc
            (ignore-errors (package-delete dep-desc))))))))

(defun my--after-package-delete (pkg &rest _)
  "After package-delete, remove PKG from package.default, delete its deps, resync lock."
  (let ((name (symbol-name (if (symbolp pkg) pkg (package-desc-name pkg)))))
    (my-default-remove name)
    ;; Delete all deps recorded as belonging to this package.
    ;; Suppress hook during recursive deletes -- resync once at the end.
    (advice-remove 'package-delete #'my--after-package-delete)
    (unwind-protect
        (my--delete-deps-of name)
      (advice-add 'package-delete :after #'my--after-package-delete))
    ;; Resync package.lock/ once after everything is cleaned up
    (my-resync-lock)
    (message "package.lock/: resynced after deleting %s and its deps" name)))

(advice-add 'package-delete :after #'my--after-package-delete)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;        INSTALL FROM PACKAGE.DEFAULT       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun install-default-packages ()
  "Install packages listed in package.default via package-install.
For each package, snapshots package-alist before install then diffs
after -- anything new that is not the package itself is a dep and
gets recorded as :dep-of that package in manifest.el."
  (interactive)
  (if (not (file-exists-p my-package-default-file))
      (message "package.default not found at %s" my-package-default-file)
    (let ((packages  (my-default-read))
          (installed 0) (skipped 0) (failed 0))
      (message "Refreshing package archives...")
      (package-refresh-contents)
      ;; Suppress hook -- we handle recording per-package below
      (advice-remove 'package-install #'my--after-package-install)
      (unwind-protect
          (dolist (name packages)
            (let ((sym (intern name)))
              (if (assq sym package-alist)
                  (progn (setq skipped (1+ skipped))
                         (message "Already installed: %s" name))
                (condition-case err
                    (progn
                      (message "Installing %s ..." name)
                      ;; Snapshot which packages exist before this install
                      (let ((before (mapcar (lambda (e) (symbol-name (car e)))
                                            package-alist)))
                        (package-install sym)
                        ;; Record pkg + anything new as its deps
                        (my-record-new-packages name))
                      (setq installed (1+ installed)))
                  (error
                   (message "Failed to install %s: %s" name (error-message-string err))
                   (setq failed (1+ failed)))))))
        (advice-add 'package-install :after #'my--after-package-install))
      (message "Done: %d installed, %d skipped, %d failed"
               installed skipped failed))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   INSTALL FROM PACKAGE.LOCK (TAR RESTORE) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reads manifest top-to-bottom (deps first) and extracts each
;; NAME.tar.gz from package.lock/ directly into elpa/.
;; No internet needed. Works on any OS with tar.

(defun install-packages-from-lock ()
  "Restore all packages from tar.gz archives in package.lock/.
Extracts each archive into elpa/ in manifest order (deps first).
No internet required. Works offline on any OS with tar."
  (interactive)
  (if (not (file-exists-p my-package-lock-dir))
      (message "package.lock/ not found at %s" my-package-lock-dir)
    (let ((entries   (reverse (my-manifest-read)))
          (elpa-dir  (expand-file-name "elpa" my-config-dir))
          (installed 0) (skipped 0) (failed 0))
      (dolist (entry entries)
        (let* ((name    (nth 0 entry))
               (_url    (nth 1 entry))  ; available if needed
               (_commit (nth 2 entry))  ; available if needed
               (sym     (intern name))
               (on-disk (and (file-directory-p elpa-dir)
                             (cl-some
                              (lambda (d) (string-prefix-p (concat name "-") d))
                              (directory-files elpa-dir nil "^[^.]")))))
          (if (or (assq sym package-alist) on-disk)
              (progn (setq skipped (1+ skipped))
                     (message "Already installed: %s" name))
            (if (my-unarchive-package name)
                (setq installed (1+ installed))
              (setq failed (1+ failed))))))
      ;; Re-initialize so Emacs picks up the newly extracted packages
      (when (> installed 0)
        (package-initialize))
      (message "Done: %d extracted, %d skipped, %d failed"
               installed skipped failed))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              VIEW PACKAGE LOCK            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun view-package-lock ()
  "Display the contents of package.lock/ in a read-only buffer."
  (interactive)
  (let ((entries (reverse (my-manifest-read)))
        (lock-dir (expand-file-name my-package-lock-dir)))
    (if (null entries)
        (message "package.lock/ is empty or not found.")
      (with-current-buffer (get-buffer-create "*Package Lock*")
        (read-only-mode -1)
        (erase-buffer)
        (insert (format "  Package Lock: %s\n\n" lock-dir))
        (insert (format "  %-28s %-10s %-4s %s\n" "Package" "Commit" "Arc" "URL"))
        (insert "  " (make-string 70 ?─) "\n")
        (dolist (entry entries)
          (let* ((name    (nth 0 entry))
                 (url     (nth 1 entry))
                 (commit  (nth 2 entry))
                 (archive (my-archive-path name))
                 (exists  (if (file-exists-p archive) "✓" "✗")))
            (insert (format "  %-28s %-10s %-4s %s\n"
                            name
                            (substring commit 0 (min 8 (length commit)))
                            exists
                            url))))
        (insert (format "\n  %d package(s) in lock.\n" (length entries)))
        (insert "\n  Keys: [i] install default  [r] restore from lock  [q] quit\n")
        (local-set-key (kbd "i") 'install-default-packages)
        (local-set-key (kbd "r") 'install-packages-from-lock)
        (local-set-key (kbd "q") 'quit-window)
        (read-only-mode 1)
        (goto-char (point-min))
        (pop-to-buffer (current-buffer))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              MY MODE SWITCHER             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-mode ()
  "Switch the current buffer to a major mode chosen via completion.
fido-mode is always on as the baseline so fuzzy search works even
before any packages are installed. ivy takes over automatically
when it loads."
  (interactive)
  (let* ((modes
          (let (result)
            (mapatoms
             (lambda (sym)
               (when (and (commandp sym)
                          (string-suffix-p "-mode" (symbol-name sym))
                          (not (string-match-p
                                "\(minor\|global\|local\|-enable\|-disable\)"
                                (symbol-name sym))))
                 (push (symbol-name sym) result))))
            (sort result #'string<)))
         (choice (completing-read
                  (format "Switch mode (current: %s): " major-mode)
                  modes nil t)))
    (when (and choice (not (string-empty-p choice)))
      (funcall (intern choice)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           DUPLICATE LINE/REGION           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun duplicate-line-or-region ()
  "Duplicate current line or selected region, keeping cursor column."
  (interactive)
  (let ((col (current-column)))
    (if (use-region-p)
        (let ((text (buffer-substring (region-beginning) (region-end))))
          (goto-char (region-end))
          (insert text))
      (let ((text (buffer-substring (line-beginning-position)
                                    (line-end-position))))
        (end-of-line)
        (insert "\n" text)))
    (move-to-column col)))

(global-set-key (kbd "C-,") 'duplicate-line-or-region)

(provide 'functions)
;;; functions.el ends here
