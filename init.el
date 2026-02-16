;;; init.el --- Main initialization file -*- lexical-binding: t -*-

;; Restore garbage collection and file handlers after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 20 1000 1000)) ; 20mb
            (setq file-name-handler-alist default-file-name-handler-alist)))

;; Stop creating backup files (files ending with ~)
(setq make-backup-files nil)

;; Stop creating auto-save files (files starting and ending with #)
(setq auto-save-default nil)


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

;; Custom faces and variables
(custom-set-faces
 '(default ((t (:foreground "#c8c8c0" :font "Lucida Console-11"))))  ;; <-- ADD :font HERE
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
 '(custom-enabled-themes '(tango-dark))
 '(global-whitespace-mode nil)
 '(package-selected-packages
   '(counsel hideshowvis ivy marginalia orderless
     swiper-helm typescript-mode vertico dumb-jump))
 '(tool-bar-mode nil))

