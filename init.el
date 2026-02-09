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


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cursor ((t (:background "gainsboro"))))
 '(dired-directory ((t (:foreground "gold3"))))
 '(font-lock-function-name-face ((t (:foreground "#fce94f" :strike-through nil)))))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(tango-dark))
 '(global-whitespace-mode nil)
 '(package-selected-packages
   '(counsel dired-sidebar ivy marginalia orderless swiper-helm
	     typescript-mode vertico))
 '(tool-bar-mode nil))
