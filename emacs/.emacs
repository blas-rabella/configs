;; global variables
(setq
 inhibit-startup-screen t
 create-lockfiles nil
 make-backup-files nil
 column-number-mode t
 scroll-error-top-bottom t
 show-paren-delay 0.5
 use-package-always-ensure t
 sentence-end-double-space nil
 custom-safe-themes t
)

;; buffer local variables
(setq-default
 indent-tabs-mode nil
 tab-width 4
 c-basic-offset 4
)

;; modes
(electric-indent-mode 1)
(electric-pair-mode 1)

;; global keybindings
(global-unset-key (kbd "C-z"))
(global-set-key [C-wheel-up] 'text-scale-increase)
(global-set-key [C-wheel-down] 'text-scale-decrease)
;; the package manager
(require 'package)
(setq
 package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                    ("org" . "http://orgmode.org/elpa/")
                    ("melpa" . "http://melpa.org/packages/")
                    ("melpa-stable" . "http://stable.melpa.org/packages/"))
 package-archive-priorities '(("melpa" . 1)))

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;; TOOLS

(use-package magit
  :commands magit-status magit-blame
  :init (setq
         magit-revert-buffers nil
         ediff-window-setup-function 'ediff-setup-windows-plain)
)

(use-package flycheck
  :ensure t
  :defer t
  :init (global-flycheck-mode))

(use-package company
  :ensure t
  :defer t
  :hook (scala-mode . company-mode)
  :init (global-company-mode)
  :config
  (progn
    ;; Use Company for completion
    (bind-key [remap completion-at-point] #'company-complete company-mode-map)

    (setq company-tooltip-align-annotations t
          ;; Easy navigation to candidates with M-<n>
          company-show-numbers t)
    (setq company-dabbrev-downcase nil))
  (setq lsp-completion-provider :capf)
  :diminish company-mode)

(use-package company-quickhelp          ; Documentation popups for Company
  :ensure t
  :defer t
  :init (add-hook 'global-company-mode-hook #'company-quickhelp-mode))

(use-package yasnippet
  :ensure t
  :defer 2
  :diminish (yas-minor-mode yas-global-mode)
  :if (display-graphic-p)
  :init (setq yas-indent-line t)
  :config (yas-global-mode))

(use-package yasnippet-snippets
  :ensure t)

(use-package counsel :ensure t)

(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode))

(use-package ivy :ensure t
  :init
  (setq ivy-use-virtual-buffers t
        ivy-count-format "%d/%d "
        ivy-re-builders-alist
        '((read-file-name-internal . ivy--regex-fuzzy)
          (t . ivy--regex-plus)))
  :config
  (ivy-mode 1)
  (global-set-key "\C-s" 'swiper)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "<f6>") 'ivy-resume)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
  (global-set-key (kbd "<f1> l") 'counsel-find-library)
  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
  (global-set-key (kbd "C-c g") 'counsel-git)
  (global-set-key (kbd "C-c j") 'counsel-git-grep)
  (global-set-key (kbd "C-c k") 'counsel-rg)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
  )

(use-package swiper
  :ensure t
)

(use-package projectile
  :ensure t
  :config
  (projectile-global-mode)
  (setq projectile-enable-caching t)
  (projectile-register-project-type 'haskell '("Setup.hs" "app")
                                    :project-file "Setup.hs"
                                    :compile "cabal build"
                                    )
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map))
  :custom
  (projectile-completion-system 'ivy)
  )

(use-package evil
  :init
  (progn
    (setq evil-default-cursor t)
    (use-package evil-leader
      :init (global-evil-leader-mode)
      :config
      (progn
        (setq evil-leader/in-all-states t)
        (evil-leader/set-leader "<SPC>")
        ;; keyboard shortcuts
        (evil-leader/set-key
          "g" 'magit-status
          )))

    ;; boot evil by default
    (evil-mode 1))
  :config
  (progn
    ;; use ido to open files
    (define-key evil-ex-map "e " 'ido-find-file)
    (define-key evil-ex-map "b " 'ido-switch-buffer)
    (define-key evil-insert-state-map (kbd "C-e") 'move-end-of-line)
    (define-key evil-insert-state-map (kbd "C-k") 'kill-line)
    (define-key evil-insert-state-map (kbd "C-w") 'kill-region)
    (define-key evil-visual-state-map (kbd "C-e") 'move-end-of-line)
    (define-key evil-normal-state-map (kbd "C-e") 'move-end-of-line)
    (define-key evil-normal-state-map (kbd "C-k") 'kill-line)
    (define-key evil-normal-state-map (kbd "C-y") 'yank)
    (define-key evil-insert-state-map (kbd "C-y") 'yank)
    (define-key evil-normal-state-map (kbd "C-w") 'kill-region)
    (define-key evil-visual-state-map (kbd "C-w") 'kill-region)

    ;; modes to map to different default states
    (dolist (mode-map '((comint-mode . emacs)
                        (term-mode . emacs)
                        (eshell-mode . emacs)
                        (help-mode . emacs)))
      (evil-set-initial-state `,(car mode-map) `,(cdr mode-map)))))

;; UI
;; Hydras
(use-package hydra
  :ensure t)
(use-package use-package-hydra
  :ensure t)
;; Focus package https://github.com/larstvei/Focus

(use-package focus
  :ensure t
  :after hydra
  :bind ("C-c f" . hydra-focus/body)
  :hydra (hydra-focus (:hint nil)
  "
  _a_: activate _p_: pin _u_: unpin _c_: change _n_: next _m_: previous  "
  ("a" focus-mode)
  ("c" focus-change-thing)
  ("p" focus-pin)
  ("u" focus-unpin)
  ("n" focus-next-thing)
  ("m"vfocus-prev-thing)))

(defhydra hydra-zoom (global-map "<f2>")
    "zoom"
    ("g" text-scale-increase "in")
    ("l" text-scale-decrease "out"))


(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-nord))

(use-package doom-modeline
      :ensure t
      :init (setq doom-modeline-checker-simple-format nil
                  doom-modeline-lsp t
                  doom-modeline-buffer-file-name-style 'relative-from-project
                  evil-normal-state-tag   (propertize "<N>" 'face '((:background "green" :foreground "black")))
                  evil-emacs-state-tag    (propertize "<E>" 'face '((:background "orange" :foreground "black")))
                  evil-insert-state-tag   (propertize "<I>" 'face '((:background "red") :foreground "white"))
                  evil-motion-state-tag   (propertize "<M>" 'face '((:background "blue") :foreground "white"))
                  evil-visual-state-tag   (propertize "<V>" 'face '((:background "grey80" :foreground "black")))
                  evil-operator-state-tag (propertize "<O>" 'face '((:background "purple"))))
      :hook (after-init . doom-modeline-mode))
(use-package highlight-indent-guides
  :ensure t
  :init (setq highlight-indent-guides-method 'column)
  :hook ((prog-mode docker-compose-mode) . highlight-indent-guides-mode)
  )

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-move-forward-on-expand        nil
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-user-mode-line-format         nil
          treemacs-user-header-line-format       nil
          treemacs-width                         35
          treemacs-workspace-switch-cleanup      nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))
(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package treemacs-icons-dired
  :after treemacs dired
  :ensure t
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)
;; (use-package lsp-treemacs)

;; SCALA
(use-package scala-mode
  :mode "\\.s\\(cala\\|bt\\)$"
  :interpreter ("scala" . scala-mode))

(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
   (setq sbt:program-options '("-Dsbt.supershell=false"))
)

;; HASKELL
(use-package haskell-mode
  :ensure t)

;; PURESCRIPT
(use-package purescript-mode
  :ensure t)

;; RUST
;; (use-package rust-mode
;;   :ensure t
;; )
(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t)
  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

(defun rk/rustic-mode-hook ()
  ;; so that run C-c C-c C-r works without having to confirm
  (setq-local buffer-save-without-query t))

;; Add keybindings for interacting with Cargo
;; (use-package cargo
;;   :hook (rust-mode . cargo-minor-mode))

;; (use-package flycheck-rust
;;   :config (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

;; ;; Add keybindings for interacting with Cargo
;; (use-package cargo
;;   :hook (rust-mode . cargo-minor-mode))

;; TOML
(use-package toml-mode)

;; DAHLl
(use-package dhall-mode
  :ensure t)

;; NIX
(use-package nix-mode
  :ensure t)



;; PYTHON
;; (use-package lsp-python-ms
;;   :ensure t
;;   :hook (python-mode . (lambda ()
;;                           (require 'lsp-python-ms)
;;                           (lsp))))
;; (use-package lsp-python-ms
;;   :ensure t
;;   :init (setq lsp-python-ms-auto-install-server t)
;;   :hook (python-mode . (lambda ()
;;                           (require 'lsp-python-ms)
;;                           (lsp))))  ; or lsp-deferred
;; JAVA
;; (use-package lsp-java :config (add-hook 'java-mode-hook 'lsp))

;; ELM

(use-package elm-mode
  :ensure t)

;; Other niceties
(use-package dockerfile-mode :ensure t)
(use-package docker-compose-mode :ensure t)
(use-package groovy-mode
  :ensure t
  :mode "Jenkinsfile")
;; 

;; LANGUAGES
(use-package lsp-mode
  :hook (scala-mode . lsp)
  :hook (rust-mode . lsp)
  :hook (haskell-mode . lsp)
  :hook (elm-mode . lsp)
  :hook (purescript-mode . lsp)
  :hook (lsp-mode . lsp-lens-mode)
  :init (setq lsp-prefer-flymake nil
              lsp-keep-workspace-alive nil)
  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  )

(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil))

(use-package posframe
  :ensure t
  ;; Posframe is a pop-up tool that must be manually installed for dap-mode
  )

(use-package dap-mode
  :ensure t
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode)
  )

 ;; SCALA LSP
(use-package lsp-metals
  :ensure t
  )
;; HASKELL LSP
(use-package lsp-haskell
 :ensure t
 ;; :config (setq lsp-haskell-server-path "/home/b.rabella/.ghcup/bin/haskell-language-server-wrapper")
 ;; Comment/uncomment this line to see interactions between lsp client/server.
 ;;(setq lsp-log-io t)
)

;; EGLOT

;; (use-package eglot
;;   :ensure t
;;   ;; (optional) Automatically start metals for Scala files.
;;   :hook (scala-mode . eglot-ensure)
;;   :hook (haskell-mode . eglot-ensure)
;;   :custom
;; (add-to-list 'eglot-server-programs
;;              `(haskell-mode . ("/home/b.rabella/.ghcup/bin/haskell-language-server-wrapper")))
;;   )

;; (use-package flymake
;;   :ensure t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-safe-themes
   '("549ccbd11c125a4e671a1e8d3609063a91228e918ffb269e57bd2cd2c0a6f1c6" "37768a79b479684b0756dec7c0fc7652082910c37d8863c35b702db3f16000f8" "fce3524887a0994f8b9b047aef9cc4cc017c5a93a5fb1f84d300391fba313743" "b8929cff63ffc759e436b0f0575d15a8ad7658932f4b2c99415f3dde09b32e97" "2dff5f0b44a9e6c8644b2159414af72261e38686072e063aa66ee98a2faecf0e" "e6ff132edb1bfa0645e2ba032c44ce94a3bd3c15e3929cdf6c049802cf059a2a" "7c0495f3973b9f79251205995ccccca41262b41a86553f81efe71c0dc3a50f43" "bb7303ab60750380957d8205794d031ab222390673ff6dd6369d0277b966c1d4" "a70b47c87e9b0940f6fece46656200acbfbc55e129f03178de8f50934ac89f58" "2f945b8cbfdd750aeb82c8afb3753ebf76a1c30c2b368d9d1f13ca3cc674c7bc" "53993d7dc1db7619da530eb121aaae11c57eaf2a2d6476df4652e6f0bd1df740" "f0a76ae259b7be77e59f98501957eb45a10af0839dd9eb29fdd5691ed74771d4" "f47f2c6b2052c81ecf8f2da64f481a92b53a3fd17680b054ea9b81c916dee4b9" "b69323309e5839676409607f91c69da2bf913914321c995f63960c3887224848" "1f36ca86913068b7d8377a327394eecfff71be34119619f779cb229875ceec0c" "4ea1959cfaa526b795b45e55f77724df4be982b9cd33da8d701df8cdce5b2955" "0eb3c0868ff890b0c4ee138069ce2a8936a8a69ba150efa6bfb9fb7c05af5ec3" "c5ad91387427abc66af38b8d6ea74cade4e3734129cbcb0c34cc90985d06dcb3" "2296db63b1de14e65390d0ded8e2b5df4b9e4186f3251af56807026542a58201" "11986184025c9e658eeff90e95ab8e9592f40b3564a5854f9ce1eab1804abd79" "b46ee2c193e350d07529fcd50948ca54ad3b38446dcbd9b28d0378792db5c088" "f0dc4ddca147f3c7b1c7397141b888562a48d9888f1595d69572db73be99a024" "d7441a80851d30a369268e50bbad6777a82ff37405f70328f21a8f30a7c6e31d" "a22f40b63f9bc0a69ebc8ba4fbc6b452a4e3f84b80590ba0a92b4ff599e53ad0" "fe666e5ac37c2dfcf80074e88b9252c71a22b6f5d2f566df9a7aa4f9bea55ef8" "b35a14c7d94c1f411890d45edfb9dc1bd61c5becd5c326790b51df6ebf60f402" default))
 '(package-selected-packages
   '(purescript-mode thrift minizinc-mode jenkinsfile-mode py-isort dhall-mode nix-mode transpose-frame ace-window kaolin-themes darkokai-theme cyberpunk-theme cyberpunk-2019-theme seoul256-theme base16-theme metalheart-theme yapfify virtualenv auto-virtualenv feature-mode ecukes rainbow-mode lua-mode dracula-theme gotham-theme nord-theme gruvbox-theme haskell-mode company-lsp lsp-ui lsp-mode doom-modeline yasnippet-snippets use-package magit flycheck evil-leader doom-themes counsel-projectile company-quickhelp))
 '(projectile-completion-system 'ivy)
 '(purescript-mode-hook
   '(capitalized-words-mode turn-on-eldoc-mode turn-on-purescript-indent lsp))
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil)
 '(tooltip-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Iosevka Term" :foundry "CYEL" :slant normal :weight normal :height 113 :width normal)))))
