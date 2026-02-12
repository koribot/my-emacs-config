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

(provide 'keybindings)
