;;; package --- Summary
(require 'package)

;;; Code:
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("elpy" . "http://jorgenschaefer.github.io/packages/")
                         ("org" . "https://orgmode.org/elpa/")))

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))


(require 'use-package)
(require 'use-package-ensure)
(setq use-package-always-ensure t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ivy-mode t)
 '(package-selected-packages
   (quote
    (hlinum dashboard which-key smartparens expand-region editorconfig lsp-ivy lsp-ui company-lsp all-the-icons-dired all-the-icons ivy-rich counsel ivy yasnippet-snippets undo-tree projectile-ripgrep projectile magit flycheck rjsx-mode emmet-mode company-web web-mode json-mode js2-refactor dracula-theme js2-mode use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;My theme
(use-package dracula-theme
  :config (load-theme 'dracula t))

;; Disable toolbar & menubar
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (  fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;match set of parens
(show-paren-mode 1)

;dashboard
(use-package dashboard
  :init
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)
                          (bookmarks . 5)
                          (agenda . 5))
        dashboard-set-file-icons t
        dashboard-set-heading-icons t
        dashboard-startup-banner 'logo
        dashboard-center-content t
        initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
  :config
  (dashboard-setup-startup-hook))

;which-key
(use-package which-key
  :config
  (which-key-mode))

;UTF-8
(set-charset-priority 'unicode)
(set-terminal-coding-system  'utf-8)   ; pretty
(set-keyboard-coding-system  'utf-8)   ; pretty
(set-selection-coding-system 'utf-8)   ; please
(prefer-coding-system        'utf-8)   ; with sugar on top
(setq default-process-coding-system '(utf-8-unix . utf-8-unix)
      locale-coding-system          'utf-8)

;editorconfig
(use-package editorconfig
  :config
  (editorconfig-mode 1))

;expand-region
(use-package expand-region
  :bind
  ("C-=" . er/expand-region))

;smartparens
(use-package smartparens
  :config (smartparens-global-mode))

;Private temporary directories
(defconst private-dir (expand-file-name "private" user-emacs-directory))
(defconst temp-dir (format "%s/cache" private-dir))

(unless (file-exists-p private-dir)
  (make-directory private-dir :parents))

(unless (file-exists-p temp-dir)
  (make-directory temp-dir :parents))


;Hooks
(defun vs/line-numbers ()
  "Display line numbers."
  (display-line-numbers-mode 1)
  (hl-line-mode 1))

(defun vs/font-lock ()
  "Font lock keywords."
  (font-lock-add-keywords
   nil '(("\\<\\(FIXME\\|TODO\\|NOCOMMIT\\)"
          1 font-lock-warning-face t))))

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'prog-mode-hook 'vs/line-numbers)
(add-hook 'text-mode-hook 'vs/line-numbers)
(add-hook 'prog-mode-hook 'vs/font-lock)
(add-hook 'text-mode-hook 'auto-fill-mode)

;company is an auto complete
(use-package company
  :init
  (setq company-dabbrev-downcase 0
        company-idle-delay 0)
  :bind (("C-." . company-complete))
  :config (global-company-mode 1))

(use-package undo-tree
  :init
  ;; Remember undo history
  (setq
   undo-tree-auto-save-history nil
   undo-tree-history-directory-alist `(("." . ,(concat temp-dir "/undo/"))))
  :config
  (global-undo-tree-mode 1))

;ivy
(use-package ivy
  :defer 0.1
  :bind ("C-s" . swiper)
  :init (setq ivy-use-virtual-buffers t)
  :config (ivy-mode 1))

(use-package counsel
  :after ivy
  :config (counsel-mode 1)
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-x c k" . counsel-yank-pop)
         ("C-x c r" . counsel-rg)
         ("<f1> f" . counsel-describe-function)
         ("<f1> v" . counsel-describe-variable)
         ("<f1> l" . counsel-load-library)
         ("<f2> i" . counsel-info-lookup-symbol)
         ("<f2> u" . counsel-unicode-char)
         ("C-x C-r" . counsel-recentf)))

(use-package ivy-rich
  :after ivy
  :config (ivy-rich-mode 1))

;editorconfig
(use-package editorconfig
  :config
  (editorconfig-mode 1))

;js2-mode
(use-package js2-mode
  :delight "EcmaScript"
  :hook ((js-mode . js2-minor-mode)
         (js2-mode . prettify-symbols-mode)
         (js2-mode . js2-imenu-extras-mode)
         (js2-mode . rjsx-minor-mode))
  :interpreter (("node" . js2-mode)
                ("node" . js2-jsx-mode))
  :mode ("\\.js$" . js2-mode)
  :init (setq js2-include-node-externs t
              js2-highlight-level 3
              js2-strict-missing-semi-warning nil
              indent-tabs-mode nil
              js-indent-level 2
              js2-basic-offset 2)
  :custom ((js2-mode-show-parse-errors nil)
           (js2-mode-show-strict-warnings nil)
           (js2-bounce-indent-p t))
  :config (define-key js2-mode-map (kbd "C-c f") 'eslint-fix-file)
  )


;js2-refactor
(use-package js2-refactor
  :after (js2-mode)
  :hook ((js2-mode . js2-refactor-mode))
  :config
  (js2r-add-keybindings-with-prefix "C-c j r")
  (define-key js2-mode-map (kbd "C-k") #'js2r-kill))

;rjsx-mode
(use-package rjsx-mode
  :init (setq indent-tabs-mode nil)
  :mode ("\\.jsx$" . rjsx-mode)
  :config (define-key rjsx-mode-map (kbd "C-c f") 'eslint-fix-file ))

;json-mode
(use-package json-mode
  :mode
  ("\\.json$" . json-mode))

;web-mode
(defun my-web-mode-hook ()
    "Hook for `web-mode' config for company-backends."
    (set (make-local-variable 'company-backends)
         '((company-css company-web-html company-files))))

(use-package web-mode
  :bind (("C-c ]" . emmet-next-edit-point)
         ("C-c [" . emmet-prev-edit-point)
         ("C-c o b" . browse-url-of-file))
  :hook ((web-mode . my-web-mode-hook))
  :mode
  (("\\.html?\\'" . web-mode)
   ("\\.njk?\\'" . web-mode)
   ("\\.phtml?\\'" . web-mode)
   ("\\.tpl\\.php\\'" . web-mode)
   ("\\.[agj]sp\\'" . web-mode)
   ("\\.as[cp]x\\'" . web-mode)
   ("\\.erb\\'" . web-mode)
   ("\\.mustache\\'" . web-mode)
   ("\\.djhtml\\'" . web-mode)
   ("\\.mjml\\'" . web-mode)
   ("\\.eex\\'" . web-mode))
  :init   (setq web-mode-markup-indent-offset 2
                 web-mode-css-indent-offset 2
                 web-mode-code-indent-offset 2
                 web-mode-enable-current-element-highlight t))

;css-mode
(defun my-css-mode-hook ()
  (set (make-local-variable 'company-backends)
       '((company-css company-dabbrev-code company-files))))

(use-package css-mode
  :hook ((css-mode . my-css-mode-hook)))

(use-package company-web
  :after web-mode)

;emmet-mode
(use-package emmet-mode
  :init (setq emmet-move-cursor-between-quotes t) ;; default nil
  :hook ((web-mode . emmet-mode)
         (vue-mode . emmet-mode)
         (rjsx-mode . emmet-mode)
         (rjsx-minor-mode . emmet-mode)))

;flycheck
(use-package flycheck
  :config
  (global-flycheck-mode 1))

;magit
(use-package magit
  :if (executable-find "git")
  :init
  (setq magit-completing-read-function 'ivy-completing-read)
  :bind ("C-x g" . magit-status))

;projectile
(use-package projectile
  :custom
  ((projectile-known-projects-file
    (expand-file-name "projectile-bookmarks.eld" temp-dir))
   (projectile-completion-system 'ivy)
   (projectile-globally-ignored-directories
    '("node_modules" ".git" ".svn" "deps" "_build")))
  :bind-keymap ("C-c p" . projectile-command-map)
  :bind (("C-," . projectile-find-file))
  :config (projectile-mode +1))

(use-package projectile-ripgrep
  :after projectile)

;undo-tree
(use-package undo-tree
  :init
  ;; Remember undo history
  (setq
   undo-tree-auto-save-history nil
   undo-tree-history-directory-alist `(("." . ,(concat temp-dir "/undo/"))))
  :config
  (global-undo-tree-mode 1))

;icons
(use-package all-the-icons)

(use-package all-the-icons-dired
  :hook ((dired-mode . all-the-icons-dired-mode)))

;lsp
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :custom ((lsp-auto-guess-root t)
           (lsp-prefer-flymake nil)
           (lsp-file-watch-threshold 8000)
           (lsp-rust-server 'rust-analyzer)
           (lsp-idle-delay 0.500)
           (lsp-prefer-capf nil)
           (lsp-keep-workspace-alive nil))
  :hook (lsp-mode . lsp-enable-which-key-integration)
         (prog-mode . lsp-deferred))

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom ((lsp-ui-doc-include-signature t)
           (lsp-ui-doc-enable nil)
           (lsp-ui-peek-enable nil)
           (lsp-ui-sideline-enable nil)))

(use-package company-lsp
  :commands company-lsp
  :custom ((company-lsp-cache-candidates 'auto)
           (company-lsp-enable-snippet t)
           (company-lsp-enable-recompletion t)))

(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)

(setq lsp-eslint-server-command
   '("node"
     "/home/lucas/vscode-eslint/server/out/eslintServer.js"
     "--stdio"))

;variables
(setq confirm-kill-emacs                  'y-or-n-p
      confirm-nonexistent-file-or-buffer  t
      save-interprogram-paste-before-kill t
      mouse-yank-at-point                 t
      require-final-newline               t
      visible-bell                        nil
      ring-bell-function                  'ignore

      ;; http://ergoemacs.org/emacs/emacs_stop_cursor_enter_prompt.html
      minibuffer-prompt-properties
      '(read-only t point-entered minibuffer-avoid-prompt face minibuffer-prompt)

      ;; Disable non selected window highlight
      cursor-in-non-selected-windows     nil
      highlight-nonselected-windows      nil

      ;; PATH
      exec-path                          (append exec-path '("/usr/local/bin/"))

      inhibit-startup-message            t
      fringes-outside-margins            t
      select-enable-clipboard            t

      ;; Backups enabled, use nil to disable
      history-length                     1000
      backup-inhibited                   nil
      make-backup-files                  t
      auto-save-default                  t
      auto-save-list-file-name           (concat temp-dir "/autosave")
      make-backup-files                  t
      create-lockfiles                   nil
      backup-directory-alist            `((".*" . ,(concat temp-dir "/backup/")))
      auto-save-file-name-transforms    `((".*" ,(concat temp-dir "/backup/") t))

      ;; smooth scroling
      mouse-wheel-follow-mouse           t
      scroll-margin                      1
      scroll-step                        1
      scroll-conservatively              10000
      scroll-preserve-screen-position    nil

      bookmark-save-flag                 t
      bookmark-default-file              (concat temp-dir "/bookmarks")

      ;; increase gc size
      gc-cons-threshold                  100000000

      ;; increase the amount of data which Emacs reads from the process
      read-process-output-max            (* 1024 1024))

(setq-default fill-column                80
              indent-tabs-mode           nil
              sh-basic-offset            2
              save-place                 t)


(defun eslint-find-binary ()
  "Get eslint binary into node_modules."
  (or
   (let ((root (locate-dominating-file buffer-file-name "node_modules")))
     (if root
	 (let ((eslint (concat root "node_modules/.bin/eslint")))
	   (if (file-executable-p eslint) eslint))))
   (error "Couldn't find a eslint executable.  Please run command: \"sudo npm i eslint --save-dev\"")))

(defun eslint-fix-file ()
  "Format the current file with ESLint."
  (interactive)
  (progn (call-process
	  (eslint-find-binary)
	  nil nil nil
	  buffer-file-name "--fix")
	 (revert-buffer t t t)))

;;; commentary:
(provide 'init)
;;; init.el ends here
