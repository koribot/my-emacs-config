;;; Completion Framework (Ivy/Counsel/Swiper)

(require 'ivy)
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)

(require 'counsel)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)

(require 'swiper)
(global-set-key (kbd "C-s") 'swiper)

(provide 'completion)
