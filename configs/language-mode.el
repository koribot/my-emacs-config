;;; Programming Language Modes
;; TypeScript
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))

;;; Jump to definition with dumb-jump (with guards)
(unless (package-installed-p 'dumb-jump)
  (package-refresh-contents)
  (package-install 'dumb-jump))

;; Only configure if dumb-jump loaded successfully
(when (require 'dumb-jump nil t)
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  (setq dumb-jump-selector 'ivy))

(provide 'language-mode)
