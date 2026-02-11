;;; -*- lexical-binding: t -*-

;;; Package setup
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;;Add ~/.emacs.d/ to load path so Emacs can find your files
(add-to-list 'load-path "~/.emacs.d/configs/")
;; Load configuration modules
(require 'ui)
(require 'completion)
(require 'language-mode)
(require 'functions)
(require 'keybindings)
(require 'dirs)

;; Add this line at the top of your init file for line spacing
(setq-default line-spacing 4)
(set-face-attribute 'default nil :font "Lucida Console-11")



;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(cursor ((t (:background "gainsboro"))))
;;  '(dired-directory ((t (:foreground "gold3"))))
;;  '(font-lock-function-name-face ((t (:foreground "#fce94f" :strike-through nil)))))


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
   '(counsel dired-sidebar hideshowvis ivy marginalia orderless
	     swiper-helm typescript-mode vertico))
 '(tool-bar-mode nil))
