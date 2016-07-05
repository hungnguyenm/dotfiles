; Add cmake listfile names to the mode list.
(setq auto-mode-alist
	  (append
	   '(("CMakeLists\\.txt\\'" . cmake-mode))
	   '(("\\.cmake\\'" . cmake-mode))
	   auto-mode-alist))

(autoload 'cmake-mode "~/dotfiles/emacs.d/modes/cmake-mode.el" t)

; Add solarized theme
(setq package-archive (("melpa" . "http://melpa.milkbox.net/packages/")))
(load-theme 'solarized-dark t)
