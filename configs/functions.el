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
;; (defun sync-installed-packages-to-extensions.txt ()
;;   "Sync explicitly installed packages into extensions.txt."
;;   (interactive)  ; <-- Add this line
;;   (let ((installed (mapcar #'symbol-name package-selected-packages))
;;         (existing '()))
    
;;     ;; Read existing file if it exists
;;     (when (file-exists-p my-extensions-file)
;;       (with-temp-buffer
;;         (insert-file-contents my-extensions-file)
;;         (setq existing
;;               (split-string (buffer-string) "\n" t))))
    
;;     ;; Write missing packages
;;     (with-temp-buffer
;;       ;; Keep existing entries
;;       (dolist (pkg existing)
;;         (insert pkg "\n"))
      
;;       ;; Append missing installed packages
;;       (dolist (pkg installed)
;;         (unless (member pkg existing)
;;           (insert pkg "\n")))
      
;;       ;; Create or overwrite file
;;       (write-region (point-min) (point-max) my-extensions-file))
;;     (message "Synced %d packages to extensions.txt" (length installed))))

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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   HOOKS                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hook into package-install to automatically log packages
(advice-add 'package-install :after
            (lambda (pkg &rest _args)
              (sync-installed-packages-to-extensions.txt)))

(provide 'functions)
