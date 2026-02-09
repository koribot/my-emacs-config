;;; UI Appearance Settings

(setq inhibit-startup-screen t)
(setq frame-title-format "koribot24 - %b")
;; Don't show DOS line endings as ^M or $
(setq inhibit-eol-conversion nil)
(setq-default buffer-file-coding-system 'utf-8-unix)
(menu-bar-mode -1)
(tool-bar-mode -1)
(global-display-line-numbers-mode 1)

;; Frame settings
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))


;; Disable bell
(setq ring-bell-function 'ignore)

;; Dired settings
(add-hook 'dired-mode-hook
          (lambda ()
            (local-set-key [mouse-1] 'dired-find-file)))


;; Save and restore sessions automatically
(desktop-save-mode 1)
(setq desktop-restore-frames nil)  ; Don't restore frame configuration
(setq desktop-lazy-verbose nil)  ; Less messages during lazy loading
(setq desktop-lazy-idle-delay 1)   ; Wait 1 second before lazy loading
(setq desktop-restore-eager 1)  ; Load first 3 buffers immediately, rest lazy

; Auto-save every 5 minutes
(setq desktop-auto-save-timeout 300) 


(provide 'ui)
