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
;; Ignore frameset errors
(setq desktop-restore-frames nil)  ; Don't restore frame configuration
(desktop-save-mode 1)


;; Customize what to save
(setq desktop-restore-eager 10)  ; Load first 10 buffers immediately, rest lazy
(setq desktop-auto-save-timeout 300)  ; Auto-save every 5 minutes


(provide 'ui)
