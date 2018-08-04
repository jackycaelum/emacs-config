(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives 
             '("melpa-stable" . "http://stable.melpa.org/packages/") t)
;disable backup
(setq backup-inhibited t)
;disable auto save
(setq auto-save-default 0)

(setq c-default-style "linux"
      c-basic-offset 4)

;; no tabs by default. modes that really need tabs should enable
;; indent-tabs-mode explicitly. makefile-mode already does that, for
;; example.
(setq-default indent-tabs-mode nil)
(add-hook 'write-file-hooks 
          (lambda () (if (not indent-tabs-mode)
                         (untabify (point-min) (point-max)))
            nil))

(setq-default tab-width 4)
(setq dired-recursive-deletes 'always)
(setq dired-recursive-copies 'always)
(setq package-list '(auto-complete multiple-cursors go-mode magit golden-ratio color-theme go-autocomplete yaml-mode toml toml-mode))


(global-set-key (kbd "C-x C-b") 'ibuffer)
    (autoload 'ibuffer "ibuffer" "List buffers." t)

(dolist (key '("\C-b" "\C-f" "\C-n" "\C-p" "\C-q"))
  (global-unset-key key))

(global-set-key (kbd "C-p") 'undo)

(defun custom-c++-mode-hook ()
  (c-set-offset 'substatement-open 0)
  (setq truncate-lines 0))

(defun execute-c++-program ()
  (interactive)
  (defvar foo)
  (setq foo (concat "clang++ -std=c++14 " (buffer-name) " && ./a.out; rm a.out" ))
  (shell-command foo))


(add-hook 'c++-mode-hook 'custom-c++-mode-hook)

(electric-pair-mode 1)
(electric-indent-mode 1)
(column-number-mode 1)

;; el-get
;(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
;
;(unless (require 'el-get nil 'noerror)
;  (with-current-buffer
;      (url-retrieve-synchronously
;       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
;    (goto-char (point-max))
;    (eval-print-last-sexp)))
;
;(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")
;(el-get 'sync)


(global-set-key (kbd "C-x C-a") 'magit-status)

(add-hook 'go-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'gofmt-before-save)
            (setq tab-width 4)
            (setq indent-tabs-mode 1)
            (electric-pair-mode 1)))
 
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (toml toml-mode yaml-mode rust-mode golden-ratio org-tree-slide epresent tide org ox-gfm multiple-cursors ac-clang bison-mode undo-tree rainbow-mode rainbow-delimiters rjsx-mode magit go-autocomplete exec-path-from-shell go-mode auto-complete)))
 '(python-shell-interpreter "python")
 '(truncate-lines nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(unless package-archive-contents
  (package-refresh-contents))
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(ac-config-default)

(require 'multiple-cursors)

(global-set-key (kbd "ESC <down>") 'mc/mark-next-like-this)
(global-set-key (kbd "ESC <up>") 'mc/mark-previous-like-this)

;; Go IDE www
(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (replace-regexp-in-string
                          "[ \t\n]*$"
                          ""
                          (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq eshell-path-env path-from-shell) ; for eshell users
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))

(setenv "GOPATH" "/Users/hare1039/Documents/gopath")

(defun go-mode-hook-x0 ()                               
      (add-hook 'before-save-hook 'gofmt-before-save)
      ; Godef jump key binding                                                      
      (local-set-key (kbd "M-o") 'godef-jump)
      (local-set-key (kbd "M-p") 'pop-tag-mark)
      (auto-complete-mode 1))
(add-hook 'go-mode-hook 'go-mode-hook-x0)

(with-eval-after-load 'go-mode
  (require 'go-autocomplete))

;; go IDE finish

(eval-after-load "org"
  '(require 'ox-gfm nil t))


(require 'golden-ratio)
(golden-ratio-mode 1)

(visual-line-mode 1)

(eval-after-load "gud"
  '(progn
    (local-unset-key (kbd "C-x C-a"))
    (local-set-key (kbd "C-c C-a") 'magit-status)))

(setq dired-listing-switches "-alh")

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (add-hook 'before-save-hook 'tide-format-before-save)
  (tide-hl-identifier-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving

(add-hook 'typescript-mode-hook #'setup-tide-mode)

(when (require 'org-tree-slide nil t)
  (global-set-key (kbd "<f8>") 'org-tree-slide-mode)
  (global-set-key (kbd "S-<f8>") 'org-tree-slide-skip-done-toggle)
  (define-key org-tree-slide-mode-map (kbd "<f7>")
    'org-tree-slide-move-previous-tree)
  (define-key org-tree-slide-mode-map (kbd "<f9>")
    'org-tree-slide-move-next-tree)
  (define-key org-tree-slide-mode-map (kbd "<f10>")
    'org-tree-slide-content)
  (setq org-tree-slide-skip-outline-level 4)
  (org-tree-slide-narrowing-control-profile)
  (setq org-tree-slide-skip-done nil))

(add-to-list 'load-path "~/.emacs.d/lisp/")
;(require 'color-theme)
;(setq color-theme-is-global t)
;(color-theme-initialize)
;(load "color-theme-manoj")
(set-default 'truncate-lines t)
