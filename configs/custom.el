;;; custom.el --- Custom Configuration -*- lexical-binding: t; -*- 
;; Auto-managed by Emacs. Avoid editing manually.

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:foreground "#c8c8c0"))))
 '(cursor ((t (:background "#e8c080"))))
 '(dired-directory ((t (:foreground "#e0b070" :weight normal))))
 '(font-lock-builtin-face ((t (:foreground "#c8c8c0"))))
 '(font-lock-comment-face ((t (:foreground "#c09060" :slant italic))))
 '(font-lock-constant-face ((t (:foreground "#d8a868"))))
 '(font-lock-function-call-face ((t (:foreground "#c8c8c0"))))
 '(font-lock-function-name-face ((t (:foreground "#e0b070" :weight bold))))
 '(font-lock-keyword-face ((t (:foreground "#d4a060" :weight bold))))
 '(font-lock-string-face ((t (:foreground "#d4a060"))))
 '(font-lock-type-face ((t (:foreground "#d0d0c8"))))
 '(font-lock-variable-name-face ((t (:foreground "#c8c8c0"))))
 '(lsp-face-highlight-read ((t (:background "#2a2420"))))
 '(lsp-face-highlight-textual ((t (:background "#2a2420"))))
 '(lsp-face-highlight-write ((t (:background "#342d26")))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(tango-dark))
 '(global-whitespace-mode nil)
 '(package-selected-packages
   '(async counsel dash dumb-jump go-mode hideshowvis ivy lsp-ivy magit
		   marginalia multiple-cursors orderless popup s swiper
		   swiper-helm ts typescript-mode vertico wfnames))
 '(package-vc-selected-packages
   '((magit-section :url "https://github.com/magit/magit" :rev
					"c800f79c2061621fde847f6a53129eca0e8da728")
	 (llama :url "https://github.com/tarsius/llama" :rev
			"d430d48e0b5afd2a34b5531f103dcb110c3539c4")
	 (transient :url "https://github.com/magit/transient" :rev
				"c8e4251fd165acd32e014e6310f2219991bea357")
	 (cond-let
	   :url "https://github.com/tarsius/cond-let" :rev
	   "8bf87d45e169ebc091103b2aae325aece3aa804d")
	 (with-editor :url "https://github.com/magit/with-editor"
	   :rev "64211dcb815f2533ac3d2a7e56ff36ae804d8338")
	 (vertico :url "https://github.com/minad/vertico" :rev
			  "0b96e8f169653cba6530da1ab0a1c28ffa44b180")
	 (typescript-mode :url
					  "https://github.com/ananthakumaran/typescript.el"
					  :rev "481df3ad2cdf569d8e6697679669ff6206fbd2f9")
	 (swiper-helm :url "https://github.com/abo-abo/swiper-helm" :rev
				  "93fb6db87bc6a5967898b5fd3286954cc72a0008")
	 (async :url "https://github.com/jwiegley/emacs-async" :rev
			"5faab28916603bb324d9faba057021ce028ca847")
	 (wfnames :url "https://github.com/thierryvolpiatto/wfnames" :rev
			  "6ea49841ab76f44c0164b9f4722da2f9d46228da")
	 (s :url "https://github.com/magnars/s.el" :rev
		"b4b8c03fcef316a27f75633fe4bb990aeff6e705")
	 (popup :url "https://github.com/auto-complete/popup-el" :rev
			"45a0b759076ce4139aba36dde0a2904136282e73")
	 (orderless :url "https://github.com/oantolin/orderless" :rev
				"6e3a09d6026fe7d7d5a3caf9a3d777cc9841fe80")
	 (multiple-cursors :url
					   "https://github.com/magnars/multiple-cursors.el"
					   :rev "ddd677091afc7d65ce56d11866e18aeded110ada")
	 (marginalia :url "https://github.com/minad/marginalia" :rev
				 "d28a5e5c1a2e5f3e6669b0197f38da84e08f94a0")
	 (hideshowvis :url "https://github.com/sheijk/hideshowvis" :rev
				  "cfae9e1f57804a557b81bb1ad778ef355877bc72")
	 (go-mode :url "https://github.com/dominikh/go-mode.el" :rev
			  "58b0c3dfc87f5ae4137ea498dc0e03adc9eeb751")
	 (dumb-jump :url "https://github.com/jacktasia/dumb-jump" :rev
				"a2285fc46c41b98c1eaf6904d58a0448cfdc920d")
	 (dash :url "https://github.com/magnars/dash.el" :rev
		   "d3a84021dbe48dba63b52ef7665651e0cf02e915")
	 (counsel :url "https://github.com/abo-abo/swiper" :rev
			  "ee79f68215ae7e2b8a38ba6bf7f82b3fe57dc16c")
	 (ivy :url "https://github.com/abo-abo/swiper" :rev
		  "1005bff8a700b92dc464f770aff8a0db5b4a1c0b")))
 '(tool-bar-mode nil))
