;;; Custom Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   VARIABLES               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar my-config-dir "~/.emacs.d"
  "My Emacs configuration directory.")
(defvar my-config-file "~/.emacs.d/init.el")
(defvar my-extensions-file "~/.emacs.d/extensions.txt")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   FUNCTIONS               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;function to go to my own config directory
(defun cfg ()
  "Open my Emacs configuration directory."
  (interactive)
  (dired my-config-dir))

;;function  to directly open the config init.el file
(defun cfg-file ()
  "Open my Emacs configuration file."
  (interactive)
  (find-file my-config-file))

;;function command to sync installed to extensions.txt
(defun sync-installed-packages-to-extensions.txt ()
  "Sync explicitly installed packages into extensions.txt.
Removes packages that are no longer in package-selected-packages."
  (interactive)
  (let ((installed (mapcar #'symbol-name package-selected-packages)))
    
    ;; Simply overwrite the file with current installed packages
    (with-temp-buffer
      (dolist (pkg installed)
        (insert pkg "\n"))
      
      ;; Create or overwrite file
      (write-region (point-min) (point-max) my-extensions-file))
    (message "Synced %d packages to extensions.txt" (length installed))))

;; function to be called by a hook to save newly installed extension to extensions.txt
(defun my-log-installed-package (pkg)
  "Log explicitly installed PKG into extensions.txt."
  (let ((pkg-name (if (symbolp pkg) (symbol-name pkg) pkg)))
    (with-temp-buffer
      (when (file-exists-p my-extensions-file)
        (insert-file-contents my-extensions-file))
      (unless (string-match-p (concat "^" (regexp-quote pkg-name) "$") (buffer-string))
        (goto-char (point-max))
        (insert pkg-name "\n")
        (write-region (point-min) (point-max) my-extensions-file)
        (message "Added %s to extensions.txt" pkg-name)))))

;;; NEW FUNCTION: Install all packages from extensions.txt
(defun install-packages ()
  "Install all packages listed in extensions.txt."
  (interactive)
  (if (not (file-exists-p my-extensions-file))
      (message "extensions.txt not found at %s" my-extensions-file)
    (let ((packages '())
          (installed-count 0)
          (skipped-count 0))
      
      ;; Read package names from file
      (with-temp-buffer
        (insert-file-contents my-extensions-file)
        (setq packages
              (delete "" (split-string (buffer-string) "\n" t))))
      
      ;; Refresh package list once before installing
      (message "Refreshing package archives...")
      (package-refresh-contents)
      
      ;; Install each package
      (dolist (pkg-name packages)
        (let ((pkg-symbol (intern pkg-name)))
          (if (package-installed-p pkg-symbol)
              (progn
                (message "Already installed: %s" pkg-name)
                (setq skipped-count (1+ skipped-count)))
            (condition-case err
                (progn
                  (message "Installing: %s" pkg-name)
                  (package-install pkg-symbol)
                  (setq installed-count (1+ installed-count)))
              (error
               (message "Failed to install %s: %s" pkg-name (error-message-string err)))))))
      
      ;; Summary message
      (message "Installation complete: %d installed, %d already present"
               installed-count skipped-count))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   HOOKS                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hook into package-install to automatically log packages
(advice-add 'package-install :after
            (lambda (pkg &rest _args)
              (sync-installed-packages-to-extensions.txt)))
(advice-add 'package-delete :after
            (lambda (pkg &rest _)
              (sync-installed-packages-to-extensions.txt)))

(provide 'functions)


