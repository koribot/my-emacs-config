;;; UI Appearance Settings

;; Don't show DOS line endings as ^M or $
(setq inhibit-eol-conversion nil)
(setq-default buffer-file-coding-system 'utf-8-unix)

;; Line numbers
(global-display-line-numbers-mode 1)

;; Safe hideshowvis hook - only runs if package is available
(add-hook 'prog-mode-hook
          (lambda ()
            (when (fboundp 'hideshowvis-enable)
              (hideshowvis-enable))))

;; Dired settings
(add-hook 'dired-mode-hook
          (lambda ()
            (local-set-key [mouse-1] 'dired-find-file)
            ;; s = show size of file/dir under cursor via du -sh
            (local-set-key (kbd "s")
                           (lambda ()
                             (interactive)
                             (let ((file (dired-get-file-for-visit)))
                               (message "%s  →  %s"
                                        (file-name-nondirectory file)
                                        (string-trim
                                         (shell-command-to-string
                                          (format "du -sh %s 2>/dev/null | cut -f1"
                                                  (shell-quote-argument file))))))))))

;; Save and restore sessions automatically
(desktop-save-mode 1)
(setq desktop-restore-frames nil)  ; Don't restore frame configuration
(setq desktop-lazy-verbose nil)    ; Less messages during lazy loading
(setq desktop-lazy-idle-delay 1)   ; Wait 1 second before lazy loading
(setq desktop-restore-eager 1)     ; Load first buffer immediately, rest lazy
(setq desktop-auto-save-timeout 300) ; Auto-save every 5 minutes

;; Indentation
(electric-indent-mode -1)
(global-set-key (kbd "RET") 'newline-and-indent)

(provide 'ui)
