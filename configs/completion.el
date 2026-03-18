;;; completion.el --- Completion Framework Configuration -*- lexical-binding: t -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              IVY COMPLETION               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Install and configure Ivy
(unless (package-installed-p 'ivy)
  (package-refresh-contents)
  (package-install 'ivy))

(when (require 'ivy nil t)
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-height 15))  ; Taller minibuffer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               COUNSEL                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Install and configure Counsel
(unless (package-installed-p 'counsel)
  (package-refresh-contents)
  (package-install 'counsel))

(when (require 'counsel nil t)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-x b") 'counsel-switch-buffer)
  (define-key ivy-minibuffer-map (kbd "C-l") 'counsel-up-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                SWIPER                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Install and configure Swiper
(unless (package-installed-p 'swiper)
  (package-refresh-contents)
  (package-install 'swiper))

(when (require 'swiper nil t)
  (global-set-key (kbd "C-s") 'swiper))


(provide 'completion)
;;; completion.el ends here

