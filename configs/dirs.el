;;; recent-dirs.el --- Track recent directories with Ivy

(defvar recent-dirs-list '()
  "List of recently accessed directories.")

(defvar recent-dirs-max 20
  "Maximum number of recent directories to track.")

(defvar recent-dirs-access-counts (make-hash-table :test 'equal)
  "Hash table tracking directory access counts.")

(defun recent-dirs-add (dir)
  "Add DIR to recent directories and increment count."
  (setq dir (expand-file-name dir))
  ;; Update access count
  (puthash dir (1+ (gethash dir recent-dirs-access-counts 0))
           recent-dirs-access-counts)
  ;; Update recent list
  (setq recent-dirs-list (delete dir recent-dirs-list))
  (push dir recent-dirs-list)
  (when (> (length recent-dirs-list) recent-dirs-max)
    (setq recent-dirs-list (butlast recent-dirs-list))))

;; Track directory access
(add-hook 'dired-mode-hook
          (lambda ()
            (recent-dirs-add default-directory)))

(defun recent-dirs-ivy ()
  "Select from recent directories using Ivy."
  (interactive)
  (if recent-dirs-list
      (ivy-read "Recent directories: "
                recent-dirs-list
                :action (lambda (dir) (dired dir)))
    (message "No recent directories yet")))

(defun recent-dirs-popular ()
  "Show most popular directories using Ivy."
  (interactive)
  (let ((sorted (sort (hash-table-keys recent-dirs-access-counts)
                      (lambda (a b)
                        (> (gethash a recent-dirs-access-counts 0)
                           (gethash b recent-dirs-access-counts 0))))))
    (if sorted
        (ivy-read "Popular directories: "
                  (mapcar (lambda (dir)
                            (format "%3d  %s"
                                    (gethash dir recent-dirs-access-counts)
                                    dir))
                          sorted)
                  :action (lambda (entry)
                            (dired (substring entry 5))))
      (message "No directory history yet"))))

;; Save/load history
(defun recent-dirs-save ()
  "Save recent directories to file."
  (let ((file "~/.emacs.d/recent-dirs-data"))
    (with-temp-file file
      (prin1 (list recent-dirs-list recent-dirs-access-counts) (current-buffer)))))

(defun recent-dirs-load ()
  "Load recent directories from file."
  (let ((file "~/.emacs.d/recent-dirs-data"))
    (when (file-exists-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (let ((data (read (current-buffer))))
          (setq recent-dirs-list (car data))
          (setq recent-dirs-access-counts (cadr data)))))))

;; Load on startup, save on exit
(recent-dirs-load)
(add-hook 'kill-emacs-hook 'recent-dirs-save)

;; Keybindings
(global-set-key (kbd "C-c r") 'recent-dirs-ivy)
(global-set-key (kbd "C-c p") 'recent-dirs-popular)

(provide 'dirs)
