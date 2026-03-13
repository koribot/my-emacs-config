;;; Custom Keybindings

;; Ctrl+Tab: cycle windows/buffers
(global-set-key (kbd "<C-tab>")
                (lambda ()
                  (interactive)
                  (if (one-window-p)
                      (next-buffer)
                    (other-window 1))))

;; Ctrl+Shift+Tab: reverse
(global-set-key (kbd "<C-S-iso-lefttab>")
                (lambda ()
                  (interactive)
                  (if (one-window-p)
                      (previous-buffer)
                    (other-window -1))))

;; F3, F4 in record and stopping macro
(global-set-key (kbd "<f3>") #'kmacro-start-macro-or-insert-counter)
(global-set-key (kbd "<f4>") #'kmacro-end-or-call-macro)
(global-set-key (kbd "<f5>") #'call-last-kbd-macro)

;; multiple-cursor
(global-set-key (kbd "C-c m n") 'mc/mark-next-like-this)
(global-set-key (kbd "C-c m p") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c m a") 'mc/mark-all-like-this)
(global-set-key (kbd "C-c m e") 'mc/edit-lines)

(provide 'keybindings)
