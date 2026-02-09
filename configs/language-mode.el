;;; Programming Language Modes

;; TypeScript
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))
;;; Jump to definition with dumb-jump
(unless (package-installed-p 'dumb-jump)
  (package-refresh-contents)
  (package-install 'dumb-jump))

(require 'dumb-jump)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
(setq dumb-jump-selector 'ivy)
(provide 'language-mode)
