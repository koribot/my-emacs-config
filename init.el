;;; init.el --- Init Configuration  -*- lexical-binding: t; -*- 

;; Restore garbage collection and file handlers after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 20 1000 1000)) ; 20mb
            (setq file-name-handler-alist default-file-name-handler-alist)))

;; Auto-create backup and auto-save folders if they don't exist
(make-directory "~/.emacs.d/backups"    t)
(make-directory "~/.emacs.d/auto-saves" t)

;; Send all backup files to one folder
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
;; Send all auto-save files to one folder
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-saves/" t)))
;; Still disable lock files
(setq create-lockfiles nil)
(setq-default tab-width 4)

;; Point custom to its own file -- set early so Emacs knows where to write
(setq custom-file "~/.emacs.d/configs/custom.el")

;; Initialize package system (since we disabled auto-init in early-init.el)
;; This picks up everything already in elpa/, including wget-installed packages.
(package-initialize)

;; Enable fido-mode as the default completion UI.
;; It is built into Emacs -- no packages needed.
;; When ivy loads it takes over completing-read automatically,
;; so this is just the safe baseline for a fresh machine.
(fido-mode 1)

;; Add ~/.emacs.d/configs/ to load path so Emacs can find your config files
(add-to-list 'load-path "~/.emacs.d/configs/")

;; Load configuration modules
(require 'ui)
(require 'completion)
(require 'language-mode)
(require 'functions)
(require 'keybindings)
(require 'dirs)
(require 'theme)

;; Load custom.el for variables only — must come before theme
(load custom-file t)

;; Restore saved theme — last, wins over everything
;; Font is set per-theme in theme.el (default face :family/:height/:weight)
(my-theme-load-saved)

;; Re-enable redisplay and messages after everything is loaded
(setq-default inhibit-redisplay nil)
(setq-default inhibit-message nil)
(redisplay)
