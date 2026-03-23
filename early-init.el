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
;; Set background early to prevent white flash before theme loads.
;; Read ~/.emacs.d/.active-theme so the color matches the saved theme.
(let* ((theme-file (expand-file-name "~/.emacs.d/.active-theme"))
       (theme-name (when (file-exists-p theme-file)
                     (string-trim
                      (with-temp-buffer
                        (insert-file-contents theme-file)
                        (buffer-string)))))
       ;; Map theme names to their background colors
       (bg (cond ((equal theme-name "Nature")        "#2b3830")
                 ((equal theme-name "Nord")           "#2e3440")
                 ((equal theme-name "Rosé Pine")      "#191724")
                 ((equal theme-name "Solarized Dark") "#002b36")
                 ((equal theme-name "Monochrome")     "#111111")
                 (t                                   "#2d2d2d"))) ; Default
       (fg (cond ((equal theme-name "Nature")        "#c8cfc0")
                 ((equal theme-name "Nord")           "#d8dee9")
                 ((equal theme-name "Rosé Pine")      "#e0def4")
                 ((equal theme-name "Solarized Dark") "#839496")
                 ((equal theme-name "Monochrome")     "#c8c8c8")
                 (t                                   "#c8c8c0")))) ; Default
  (add-to-list 'default-frame-alist (cons 'background-color bg))
  (add-to-list 'default-frame-alist (cons 'foreground-color fg)))

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

