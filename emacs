(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

; Add cmake listfile names to the mode list.
(setq auto-mode-alist
	  (append
	   '(("CMakeLists\\.txt\\'" . cmake-mode))
	   '(("\\.cmake\\'" . cmake-mode))
	   auto-mode-alist))

(autoload 'cmake-mode "~/dotfiles/emacs.d/modes/cmake-mode.el" t)

; Add solarized theme
(add-to-list 'custom-theme-load-path "~/dotfiles/emacs.d/themes/emacs-color-theme-solarized")
(custom-set-variables '(solarized-termcolors 256))
(load-theme 'solarized t)
(set-frame-parameter nil 'background-mode 'dark)
(set-terminal-parameter nil 'background-mode 'dark)
(enable-theme 'solarized)

;; Load emacs packages and activate them
;; This must come before configurations of installed packages.
;; Don't delete this line.
(package-initialize)
