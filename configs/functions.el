;;; Custom Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   VARIABLES               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar my-config-dir "~/.emacs.d"
  "My Emacs configuration directory.")
(defvar my-config-file "~/.emacs.d/init.el")
(defvar my-extensions-file "~/.emacs.d/extensions.txt"
  "List of package names. Human-editable, one name per line.")
(defvar my-extensions-lock-file "~/.emacs.d/extensions.lock"
  "Auto-managed lock file storing pinned versions as name=version.")
(defvar my-package-cache-dir "~/.emacs.d/package-cache"
  "Directory where package tars are cached for reproducible installs.")
(defvar my-readme-file "~/.emacs.d/README.md"
  "Source README in markdown format.")
(defvar my-help-org-file "~/.emacs.d/help.org"
  "Auto-generated org file from README.md, used by my-help.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   FUNCTIONS               ;;
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

(defun my-md-to-org (md-file org-file)
  "Convert MD-FILE from markdown to org format and write to ORG-FILE."
  (with-temp-buffer
    (insert-file-contents md-file)
    (let ((content (buffer-string)))
      (with-temp-file org-file
        (insert content)
        ;; Code blocks
        (goto-char (point-min))
        (while (re-search-forward "^```\\(.*\\)$" nil t)
          (let ((lang (match-string 1)))
            (replace-match (if (string= lang "")
                               "#+BEGIN_SRC"
                             (format "#+BEGIN_SRC %s" lang)))))
        (goto-char (point-min))
        (while (re-search-forward "^```$" nil t)
          (replace-match "#+END_SRC"))
        ;; Headers (order matters, do h4 before h3 before h2 before h1)
        (goto-char (point-min))
        (while (re-search-forward "^#### \\(.*\\)$" nil t)
          (replace-match "**** \\1"))
        (goto-char (point-min))
        (while (re-search-forward "^### \\(.*\\)$" nil t)
          (replace-match "*** \\1"))
        (goto-char (point-min))
        (while (re-search-forward "^## \\(.*\\)$" nil t)
          (replace-match "** \\1"))
        (goto-char (point-min))
        (while (re-search-forward "^# \\(.*\\)$" nil t)
          (replace-match "* \\1"))
        ;; Inline code `foo` -> =foo=
        (goto-char (point-min))
        (while (re-search-forward "`\\([^`]+\\)`" nil t)
          (replace-match "=\\1="))
        ;; Bold **foo** -> *foo*
        (goto-char (point-min))
        (while (re-search-forward "\\*\\*\\([^*]+\\)\\*\\*" nil t)
          (replace-match "*\\1*"))))))

(defun my-help ()
  "Convert README.md to org on the fly and display it."
  (interactive)
  (if (not (file-exists-p my-readme-file))
      (message "README.md not found at %s" my-readme-file)
    (my-md-to-org my-readme-file my-help-org-file)
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
;;             LOCK FILE HELPERS             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-read-lock-file ()
  "Read extensions.lock and return an alist of (name . version)."
  (if (not (file-exists-p my-extensions-lock-file))
      '()
    (with-temp-buffer
      (insert-file-contents my-extensions-lock-file)
      (let ((lines (delete "" (split-string (buffer-string) "\n" t)))
            (result '()))
        (dolist (line lines result)
          (when (string-match "^\\([^=]+\\)=\\(.+\\)$" line)
            (push (cons (match-string 1 line) (match-string 2 line))
                  result)))))))

(defun my-write-lock-file (alist)
  "Write ALIST of (name . version) pairs to extensions.lock."
  (with-temp-file my-extensions-lock-file
    (dolist (entry (sort alist (lambda (a b) (string< (car a) (car b)))))
      (insert (car entry) "=" (cdr entry) "\n"))))

(defun my-get-installed-version (pkg-symbol)
  "Return installed version string of PKG-SYMBOL or nil."
  (let ((desc (cadr (assq pkg-symbol package-alist))))
    (when desc
      (mapconcat #'number-to-string (package-desc-version desc) "."))))

(defun my-get-available-version (pkg-symbol)
  "Return latest available version string of PKG-SYMBOL or nil."
  (let ((available (cadr (assq pkg-symbol package-archive-contents))))
    (when available
      (mapconcat #'number-to-string (package-desc-version available) "."))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             PACKAGE CACHE                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-cache-path (pkg-name version)
  "Return the expected cache tar path for PKG-NAME at VERSION."
  (expand-file-name
   (format "%s-%s.tar" pkg-name version)
   my-package-cache-dir))

(defun my-purge-old-cache (pkg-name new-version)
  "Delete any cached tars for PKG-NAME that are not NEW-VERSION."
  (let ((cache-dir (expand-file-name my-package-cache-dir)))
    (when (file-directory-p cache-dir)
      (dolist (f (directory-files cache-dir t "\\.tar$"))
        (let ((fname (file-name-nondirectory f)))
          (when (and (string-prefix-p (concat pkg-name "-") fname)
                     (not (string= f (expand-file-name
                                      (format "%s-%s.tar" pkg-name new-version)
                                      cache-dir))))
            (delete-file f)
            (message "Cache: purged old %s" fname)))))))

(defun my-purge-all-cache-for-package (pkg-name)
  "Delete all cached tars for PKG-NAME regardless of version."
  (let ((cache-dir (expand-file-name my-package-cache-dir)))
    (when (file-directory-p cache-dir)
      (dolist (f (directory-files cache-dir t "\\.tar$"))
        (let ((fname (file-name-nondirectory f)))
          (when (string-prefix-p (concat pkg-name "-") fname)
            (delete-file f)
            (message "Cache: removed %s" fname)))))))

(defun my-cache-package (pkg-symbol)
  "Cache the installed tar of PKG-SYMBOL to the package cache directory.
Purges any older cached versions of the same package first."
  (make-directory (expand-file-name my-package-cache-dir) t)
  (let* ((desc (cadr (assq pkg-symbol package-alist)))
         (version (when desc
                    (mapconcat #'number-to-string
                               (package-desc-version desc) ".")))
         (pkg-dir (when desc (package-desc-dir desc)))
         (cache-tar (when version
                      (my-cache-path (symbol-name pkg-symbol) version))))
    (if (null desc)
        (message "Cache: package %s not found" pkg-symbol)
      (my-purge-old-cache (symbol-name pkg-symbol) version)
      (if (file-exists-p cache-tar)
          (message "Cache: %s-%s already cached" pkg-symbol version)
        (let* ((parent-dir (file-name-directory (directory-file-name pkg-dir)))
               (dir-name (file-name-nondirectory (directory-file-name pkg-dir)))
               (cmd (format "tar -cf %s -C %s %s"
                            (shell-quote-argument (expand-file-name cache-tar))
                            (shell-quote-argument parent-dir)
                            (shell-quote-argument dir-name))))
          (if (= 0 (shell-command cmd))
              (message "Cache: saved %s-%s" pkg-symbol version)
            (message "Cache: failed to cache %s-%s" pkg-symbol version)))))))

(defun my-cache-all-packages ()
  "Cache ALL installed packages including dependencies to package-cache/.
Loops over package-alist so dependencies are included."
  (interactive)
  (make-directory (expand-file-name my-package-cache-dir) t)
  (let ((cached 0) (skipped 0) (failed 0))
    (dolist (pkg package-alist)
      (let* ((pkg-symbol (car pkg))
             (desc (cadr pkg))
             (version (when desc
                        (mapconcat #'number-to-string
                                   (package-desc-version desc) ".")))
             (cache-tar (when version
                          (my-cache-path (symbol-name pkg-symbol) version))))
        (cond
         ((null desc)
          (setq skipped (1+ skipped)))
         ((file-exists-p cache-tar)
          (setq skipped (1+ skipped)))
         (t
          (my-purge-old-cache (symbol-name pkg-symbol) version)
          (let* ((pkg-dir (package-desc-dir desc))
                 (parent-dir (file-name-directory (directory-file-name pkg-dir)))
                 (dir-name (file-name-nondirectory (directory-file-name pkg-dir)))
                 (cmd (format "tar -cf %s -C %s %s"
                              (shell-quote-argument (expand-file-name cache-tar))
                              (shell-quote-argument parent-dir)
                              (shell-quote-argument dir-name))))
            (if (= 0 (shell-command cmd))
                (progn
                  (message "Cache: saved %s-%s" pkg-symbol version)
                  (setq cached (1+ cached)))
              (setq failed (1+ failed))))))))
    (message "Cache complete: %d saved, %d already cached, %d failed"
             cached skipped failed)))

(defun my-install-from-cache (pkg-name version)
  "Install PKG-NAME at VERSION from the local cache.
Returns t if successful, nil if cache miss."
  (let ((cache-tar (my-cache-path pkg-name version)))
    (if (not (file-exists-p cache-tar))
        (progn
          (message "Cache miss: %s-%s not in cache" pkg-name version)
          nil)
      (condition-case err
          (progn
            (message "Installing %s-%s from cache..." pkg-name version)
            (package-install-file (expand-file-name cache-tar))
            (message "Installed %s-%s from cache" pkg-name version)
            t)
        (error
         (message "Cache install failed for %s: %s"
                  pkg-name (error-message-string err))
         nil)))))

(defun clear-package-cache ()
  "Delete all cached package tars from the cache directory."
  (interactive)
  (if (not (file-directory-p (expand-file-name my-package-cache-dir)))
      (message "Cache directory does not exist")
    (when (yes-or-no-p (format "Delete all cached tars in %s? "
                               my-package-cache-dir))
      (let ((files (directory-files
                    (expand-file-name my-package-cache-dir) t "\\.tar$")))
        (dolist (f files) (delete-file f))
        (message "Cleared %d cached package(s)" (length files))))))

(defun view-package-cache ()
  "Show all cached packages in a buffer."
  (interactive)
  (let ((cache-dir (expand-file-name my-package-cache-dir)))
    (if (not (file-directory-p cache-dir))
        (message "Cache directory does not exist yet. Run my-cache-all-packages first.")
      (let ((files (directory-files cache-dir nil "\\.tar$")))
        (if (null files)
            (message "Cache is empty.")
          (with-current-buffer (get-buffer-create "*Package Cache*")
            (read-only-mode -1)
            (erase-buffer)
            (insert (format "Package Cache: %s\n" cache-dir))
            (insert (make-string 62 ?-) "\n")
            (dolist (f (sort files #'string<))
              (let* ((path (expand-file-name f cache-dir))
                     (size (/ (file-attribute-size (file-attributes path)) 1024)))
                (insert (format "%-45s %6d KB\n" f size))))
            (insert (format "\n%d package(s) cached.\n" (length files)))
            (insert "Keybindings: [c] cache all  [d] clear cache  [q] quit\n")
            (local-set-key (kbd "c") 'my-cache-all-packages)
            (local-set-key (kbd "d") 'clear-package-cache)
            (local-set-key (kbd "q") 'quit-window)
            (read-only-mode 1)
            (goto-char (point-min))
            (pop-to-buffer (current-buffer))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           SYNC / INSTALL                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun sync-installed-packages-to-extensions.txt ()
  "Sync installed packages into extensions.txt (names) and extensions.lock (versions)."
  (interactive)
  (let ((names (mapcar #'symbol-name package-selected-packages))
        (lock-alist '()))
    (with-temp-file my-extensions-file
      (dolist (name (sort names #'string<))
        (insert name "\n")))
    (dolist (pkg package-selected-packages)
      (let ((ver (my-get-installed-version pkg)))
        (when ver
          (push (cons (symbol-name pkg) ver) lock-alist))))
    (my-write-lock-file lock-alist)
    (message "Synced %d packages to extensions.txt and extensions.lock"
             (length names))))

(defun install-my-packages ()
  "Install packages from extensions.txt.
Skips already installed. Checks cache first, falls back to MELPA.
Updates lock and cache after install."
  (interactive)
  (if (not (file-exists-p my-extensions-file))
      (message "extensions.txt not found at %s" my-extensions-file)
    (let ((packages '())
          (lock-alist (my-read-lock-file))
          (from-cache 0)
          (from-melpa 0)
          (skipped 0))
      (with-temp-buffer
        (insert-file-contents my-extensions-file)
        (setq packages
              (delete "" (split-string (buffer-string) "\n" t))))
      (message "Refreshing package archives...")
      (package-refresh-contents)
      (dolist (pkg-name packages)
        (let* ((pkg-symbol (intern pkg-name))
               (pinned (cdr (assoc pkg-name lock-alist)))
               (already-installed (assq pkg-symbol package-alist)))
          (if already-installed
              (progn
                (message "Already installed: %s" pkg-name)
                (setq skipped (1+ skipped)))
            (condition-case err
                (if (and pinned (my-install-from-cache pkg-name pinned))
                    (setq from-cache (1+ from-cache))
                  (if pinned
                      (message "Installing %s @ %s from MELPA (not in cache)..."
                               pkg-name pinned)
                    (message "Installing %s (latest) from MELPA..." pkg-name))
                  (package-install pkg-symbol)
                  (setq from-melpa (1+ from-melpa)))
              (error
               (message "Failed to install %s: %s"
                        pkg-name (error-message-string err)))))))
      (when (> (+ from-cache from-melpa) 0)
        (sync-installed-packages-to-extensions.txt)
        (my-cache-all-packages))
      (message "Done: %d from cache, %d from MELPA, %d already installed"
               from-cache from-melpa skipped))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           VIEW UPGRADABLE PACKAGES        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun view-upgradable-packages ()
  "Show a buffer listing explicitly installed packages that have upgrades available.
Keybindings: [U] upgrade all  [u] upgrade specific  [p] pin specific  [P] pin all  [q] quit."
  (interactive)
  (message "Checking for upgrades...")
  (package-refresh-contents)
  (let ((upgradable '()))
    (dolist (pkg-symbol package-selected-packages)
      (let* ((installed-desc (cadr (assq pkg-symbol package-alist)))
             (installed-ver (when installed-desc (package-desc-version installed-desc)))
             (available (cadr (assq pkg-symbol package-archive-contents)))
             (available-ver (when available (package-desc-version available))))
        (when (and installed-ver available-ver
                   (version-list-< installed-ver available-ver))
          (push (list pkg-symbol
                      (mapconcat #'number-to-string installed-ver ".")
                      (mapconcat #'number-to-string available-ver "."))
                upgradable))))
    (if (null upgradable)
        (message "All packages are up to date!")
      (with-current-buffer (get-buffer-create "*Upgradable Packages*")
        (read-only-mode -1)
        (erase-buffer)
        (insert (format "%-30s %-15s %-15s\n" "Package" "Installed" "Available"))
        (insert (make-string 62 ?-) "\n")
        (dolist (entry (sort upgradable (lambda (a b)
                                          (string< (symbol-name (car a))
                                                   (symbol-name (car b))))))
          (insert (format "%-30s %-15s %-15s\n"
                          (symbol-name (car entry))
                          (cadr entry)
                          (caddr entry))))
        (insert (format "\n%d package(s) can be upgraded.\n" (length upgradable)))
        (insert "Keybindings: [U] upgrade all  [u] upgrade specific  [p] pin specific  [P] pin all  [q] quit\n")
        (local-set-key (kbd "U") 'upgrade-packages)
        (local-set-key (kbd "u") 'upgrade-package-to-version)
        (local-set-key (kbd "p") 'pin-package-version)
        (local-set-key (kbd "P") 'pin-all-packages-versions-to-extensions.lock)
        (local-set-key (kbd "q") 'quit-window)
        (read-only-mode 1)
        (goto-char (point-min))
        (pop-to-buffer (current-buffer))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              UPGRADE ALL PACKAGES         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun upgrade-packages ()
  "Upgrade all explicitly installed packages to latest.
Updates cache and extensions.lock."
  (interactive)
  (message "Refreshing package archives...")
  (package-refresh-contents)
  (let ((upgraded-count 0)
        (upgraded-names '()))
    (dolist (pkg-symbol package-selected-packages)
      (let* ((installed-desc (cadr (assq pkg-symbol package-alist)))
             (installed-ver (when installed-desc (package-desc-version installed-desc)))
             (available (cadr (assq pkg-symbol package-archive-contents)))
             (available-ver (when available (package-desc-version available))))
        (when (and installed-ver available-ver
                   (version-list-< installed-ver available-ver))
          (condition-case err
              (progn
                (message "Upgrading %s %s -> %s..."
                         pkg-symbol
                         (mapconcat #'number-to-string installed-ver ".")
                         (mapconcat #'number-to-string available-ver "."))
                (package-install available)
                (setq upgraded-count (1+ upgraded-count))
                (push (symbol-name pkg-symbol) upgraded-names))
            (error
             (message "Failed to upgrade %s: %s"
                      pkg-symbol (error-message-string err)))))))
    (if (> upgraded-count 0)
        (progn
          (sync-installed-packages-to-extensions.txt)
          (my-cache-all-packages)
          (message "Upgraded %d package(s): %s"
                   upgraded-count (string-join upgraded-names ", ")))
      (message "All packages are already up to date!"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;         UPGRADE SPECIFIC PACKAGE          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun upgrade-package-to-version (pkg-name version)
  "Upgrade PKG-NAME to a specific VERSION.
Updates cache and extensions.lock."
  (interactive
   (let* ((pkg (completing-read "Package to upgrade: "
                                (mapcar #'symbol-name package-selected-packages)
                                nil t))
          (current (my-get-installed-version (intern pkg)))
          (available (my-get-available-version (intern pkg)))
          (ver (read-string
                (format "Version for %s (installed: %s, latest: %s): "
                        pkg
                        (or current "none")
                        (or available "unknown")))))
     (list pkg ver)))
  (condition-case err
      (progn
        (message "Refreshing package archives...")
        (package-refresh-contents)
        (let* ((pkg-symbol (intern pkg-name))
               (pkg-desc (cadr (assq pkg-symbol package-archive-contents))))
          (if (null pkg-desc)
              (message "Package %s not found in archives" pkg-name)
            (message "Installing %s @ %s..." pkg-name version)
            (package-install pkg-desc)
            (my-cache-all-packages)
            (let* ((lock-alist (my-read-lock-file))
                   (new-ver (my-get-installed-version pkg-symbol))
                   (updated (cons (cons pkg-name (or new-ver version))
                                  (assoc-delete-all pkg-name lock-alist))))
              (my-write-lock-file updated))
            (message "Upgraded %s to %s, cached, updated extensions.lock"
                     pkg-name version))))
    (error
     (message "Failed to upgrade %s: %s" pkg-name (error-message-string err)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           PIN PACKAGE TO VERSION          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun pin-package-version (pkg-name version)
  "Pin PKG-NAME to VERSION in extensions.lock without reinstalling."
  (interactive
   (let* ((pkg (completing-read "Package to pin: "
                                (mapcar #'symbol-name package-selected-packages)
                                nil t))
          (current (my-get-installed-version (intern pkg)))
          (ver (read-string
                (format "Pin %s to version (currently %s): "
                        pkg (or current "unknown"))
                current)))
     (list pkg ver)))
  (let* ((lock-alist (my-read-lock-file))
         (updated (cons (cons pkg-name version)
                        (assoc-delete-all pkg-name lock-alist))))
    (my-write-lock-file updated)
    (message "Pinned %s to version %s in extensions.lock" pkg-name version)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              PIN ALL PACKAGES             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun pin-all-packages-versions-to-extensions.lock ()
  "Pin all explicitly installed packages to their current versions in extensions.lock."
  (interactive)
  (let ((lock-alist '())
        (pinned-count 0)
        (skipped-count 0))
    (dolist (pkg package-selected-packages)
      (let ((ver (my-get-installed-version pkg)))
        (if ver
            (progn
              (push (cons (symbol-name pkg) ver) lock-alist)
              (setq pinned-count (1+ pinned-count)))
          (setq skipped-count (1+ skipped-count)))))
    (my-write-lock-file lock-alist)
    (if (> skipped-count 0)
        (message "Pinned %d packages. Skipped %d (not installed)."
                 pinned-count skipped-count)
      (message "Pinned all %d packages to current versions in extensions.lock"
               pinned-count))))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   HOOKS                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(advice-add 'package-install :after
            (lambda (pkg &rest _args)
              (sync-installed-packages-to-extensions.txt)
              (my-cache-all-packages)))
(advice-add 'package-delete :after
            (lambda (pkg &rest _)
              (let ((pkg-name (if (symbolp pkg)
                                  (symbol-name pkg)
                                (symbol-name (package-desc-name pkg)))))
                (my-purge-all-cache-for-package pkg-name)
                (sync-installed-packages-to-extensions.txt))))

(provide 'functions)
