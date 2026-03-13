;;; init.el --- Main initialization file -*- lexical-binding: t -*-
;; Restore garbage collection and file handlers after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 20 1000 1000)) ; 20mb
            (setq file-name-handler-alist default-file-name-handler-alist)))
;; Stop creating backup files (files ending with ~)
;;(setq make-backup-files nil)
;; Stop creating auto-save files (files starting and ending with #)
;;(setq auto-save-default nil)
;; Auto-create backup and auto-save folders if they don't exist
(make-directory "~/.emacs.d/backups" t)
(make-directory "~/.emacs.d/auto-saves" t)
;; Send all backup files to one folder
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
;; Send all auto-save files to one folder
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-saves/" t)))
;; Still disable lock files
(setq create-lockfiles nil)
(setq-default tab-width 4)
;; Initialize package system (since we disabled auto-init in early-init.el)
(package-initialize)
;; Install critical dependencies first
(defun ensure-package-installed (package)
  "Install PACKAGE if not already installed."
  (unless (package-installed-p package)
    (unless package-archive-contents
      (package-refresh-contents))
    (package-install package)))
;; Install core dependencies
(ensure-package-installed 'dash)
(ensure-package-installed 's)
(ensure-package-installed 'popup)
;; Add ~/.emacs.d/ to load path so Emacs can find your files
(add-to-list 'load-path "~/.emacs.d/configs/")
;; Load configuration modules
(require 'ui)
(require 'completion)
(require 'language-mode)
(require 'functions)
(require 'keybindings)
(require 'dirs)

;; Set font based on OS
(cond
  ((eq system-type 'windows-nt)
   (when (find-font (font-spec :family "Lucida Console"))
     (set-face-attribute 'default nil :family "Lucida Console" :height 110)))
  ((eq system-type 'gnu/linux)
   (when (find-font (font-spec :family "DejaVu Sans Mono"))
     (set-face-attribute 'default nil :family "DejaVu Sans Mono" :height 110))))

;; Custom faces and variables
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:foreground "#c8c8c0"))))
 '(cursor ((t (:background "#e8c080"))))
 '(dired-directory ((t (:foreground "#e0b070" :weight normal))))
 '(font-lock-builtin-face ((t (:foreground "#c8c8c0"))))
 '(font-lock-comment-face ((t (:foreground "#c09060" :slant italic))))
 '(font-lock-constant-face ((t (:foreground "#d8a868"))))
 '(font-lock-function-call-face ((t (:foreground "#c8c8c0"))))
 '(font-lock-function-name-face ((t (:foreground "#e0b070" :weight bold))))
 '(font-lock-keyword-face ((t (:foreground "#d4a060" :weight bold))))
 '(font-lock-string-face ((t (:foreground "#d4a060"))))
 '(font-lock-type-face ((t (:foreground "#d0d0c8"))))
 '(font-lock-variable-name-face ((t (:foreground "#c8c8c0"))))
 '(lsp-face-highlight-read ((t (:background "#2a2420"))))
 '(lsp-face-highlight-textual ((t (:background "#2a2420"))))
 '(lsp-face-highlight-write ((t (:background "#342d26")))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(tango-dark))
 '(global-whitespace-mode nil)
 '(package-selected-packages
   '(## counsel dumb-jump go-mode hideshowvis ivy marginalia orderless
	swiper-helm typescript-mode vertico))
 '(tool-bar-mode nil))
