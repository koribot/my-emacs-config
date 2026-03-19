;;; early-init.el --- Early-init Configuration -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;            PACKAGE SYSTEM SETUP           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Don't auto-initialize packages (we'll do it in init.el)
(setq package-enable-at-startup nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              UI SETTINGS                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq inhibit-startup-screen t)
(setq frame-title-format "koribot24 - %b")

;; Suppress redisplay and messages during startup
(setq-default inhibit-redisplay t)
(setq-default inhibit-message t)

;; Remove UI elements
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; Frame settings
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))
;; Set background early to prevent white flash before theme loads
(add-to-list 'default-frame-alist '(background-color . "#2c2c2c"))
(add-to-list 'default-frame-alist '(foreground-color . "#c8c8c0"))

;; Disable bell
(setq ring-bell-function 'ignore)

;; Font and spacing
(setq-default line-spacing 4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          PERFORMANCE OPTIMIZATION         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Increase garbage collection threshold during startup
(setq gc-cons-threshold most-positive-fixnum)

;; File name handler optimization
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
