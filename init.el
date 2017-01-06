;; load-path
(dolist (dir '("~/Documents/Script/Emacs" "~/.emacs.d/elpa" "~/.emacs.d/el-get"))
  (when (file-exists-p dir)
    (progn
      (add-to-list 'load-path dir)
      (let ((default-directory dir))
        (normal-top-level-add-subdirs-to-load-path)))))

;; why not make these default?
(setq mouse-avoidance-mode 'banish)
(setq default-fill-column 80)
(setq visible-bell nil)
(setq inhibit-startup-message t)
(setq column-number-mode t)
(setq x-select-enable-clipboard t)
(set-clipboard-coding-system 'nil) ; allow text copy from X: 'C-V'
(setq enable-local-variables :safe)
(global-auto-revert-mode t)
(fset 'yes-or-no-p 'y-or-n-p)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(windmove-default-keybindings) ; Shift+direction
(transient-mark-mode t)
(delete-selection-mode t) ; replace highlighted text with typed text
(show-paren-mode t)
(setq show-paren-style 'expression)
(setq default-major-mode 'text-mode)
(setq-default indent-tabs-mode nil) ; use space instead of tab; 'M-x untabify'
(setq-default tab-width 2)
(setq-default ediff-ignore-similar-regions t) ; make ediff igore whitespace
(global-font-lock-mode t)
(setq backup-directory-alist (quote (("."  . "~/.emacs.d/"))))
(setq help-window-select t) ; select *Help* buffer after C-h f

;; "emacsclient -nw" if the ssh host has an emacs server running
;; "emacs --daemon" + "emacsclient -t" to start and use emacs server, C-x C-c to quit emacsclient
;;(server-start)

;; M-3 M-x Buffer-menu-sort Sort by buffer name.
;; M-4 M-x Buffer-menu-sort Sort by buffer size (desc).
;; M-5 M-x Buffer-menu-sort Sort by buffer mode name.
;; M-6 M-x Buffer-menu-sort Sort by buffer file name.
;; # is column number; run twice to change to toggle asce, desc
(global-set-key (kbd "C-x C-b") 'buffer-menu)

;; revert the buffer using encoding gb2312:
;; C-x <RET> r gb2312 <RET>
;; M-x revert-buffer-with-coding-system
(set-file-name-coding-system 'utf-8) ; Chinese in dired-mode
(set-terminal-coding-system 'utf-8)

;; for small C program (default is 'make').
;; next error: 'C-x ` or 'M-n C-c C-c''
(setq compile-command '"gcc -Wall -g ")

;; c indent customization
(defun my-c-mode-hook ()
  (setq c-basic-offset 2)
  (setq c-set-offset 2)
  (setq c-indent-defun nil))
(add-hook 'c-mode-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c-mode-hook)

;; display time
(setq display-time-day-and-date t)
(setq display-time-24hr-format t)
(display-time)

;; use ido-mode: C-s, C-r, Tab.
(require 'ido)
(setq ido-enable-flex-matching t) ; so that "bd" will list "abc"
(ido-mode t)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)

;; save the desktop and cursor place when quit emacs
(require 'saveplace)
(setq-default save-place t)
(desktop-save-mode t)

;; make default: copy (M-w) or cut (C-w) the current line
(defadvice kill-ring-save (before slickcopy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))
(defadvice kill-region (before slickcut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

;; toggle line spacing between two modes
(defun toggle-line-spacing ()
  "Toggle line spacing between 1 and 5 pixels."
  (interactive)
  (if (eq line-spacing 1)
      (setq-default line-spacing 5)
    (setq-default line-spacing 1)))

;; C-c C-c: python-shell-send-buffer; C-c C-r: python-shell-send-region
(require 'python)
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))
(add-to-list 'interpreter-mode-alist '("python" . python-mode))
(add-hook 'python-mode-hook
          (lambda ()
            (set (make-variable-buffer-local 'beginning-of-defun-function)
                 'py-beginning-of-def-or-class)
            (setq outline-regexp "def\\|class ")))

;; open file (Enter) and go parent (^) in same buffer in dired
(add-hook 'dired-mode-hook
          (lambda ()
            (define-key dired-mode-map (kbd "<return>")
              'dired-find-alternate-file)
            (define-key dired-mode-map (kbd "^")
              (lambda () (interactive) (find-alternate-file "..")))))
(put 'dired-find-alternate-file 'disabled nil)
(setq dired-dwim-target t)
(setq dired-recursive-copies (quote always))
(setq dired-recursive-deletes (quote top))
(global-set-key "\C-x\C-j" 'dired-jump)

;; Find and replace in a directory:
;; 1. M-x find-name-dired: you will be prompted for a root directory and a filename pattern.
;; 2. Press "t" to "toggle mark" for all files found. "% m RET" to mark all.
;; 3. Press "Q" for "Query-Replace in Files...": you will be prompted for query/substitution regexps.
;; 4. Proceed as with query-replace-regexp:
;;      SPACE/y to replace and next, n to skip a match;
;;      ! to replace all for the current file, N to skip all for the current file;
;;      Y to replace all without asking.
;; 5. "C-x s !" to save all the files; "M-," to continue after "revert file" prompt, etc.

;; M-x rename to invoke file rename, in dired mode.
;; C-c C-c: commit. C-c Esc: quit
(defalias 'rename 'wdired-change-to-wdired-mode)

;; newsticker: se/he to show/hide item, RET to browse in w3m
(setq newsticker-frontend 'newsticker-plainview)
(setq newsticker-html-renderer 'w3m-region)
(setq newsticker-keep-obsolete-items nil)
(setq newsticker-automatically-mark-items-as-old nil)
(setq newsticker-automatically-mark-visited-items-as-old t)
(setq newsticker-hide-old-items-in-newsticker-buffer t)
(setq newsticker-show-descriptions-of-new-items nil)
(setq newsticker-url-list-defaults nil) ; clear the default list
(setq newsticker-retrieval-interval 0) ; second
(setq newsticker-obsolete-item-max-age 259200)  ; 3 days
(setq newsticker-use-full-width t)
(setq newsticker-url-list
      '(
        ;; ("WSJ"
        ;;  "http://cn.wsj.com/gb/rssall.xml")
        ;; ("Vox"
        ;;  "http://www.vox.com/rss/index.xml")
        ;; ("TheOnion"
        ;;  "http://www.theonion.com/feeds/rss")
        ;; ("CoolShell"
        ;;  "http://coolshell.cn/feed")
        ("Google"
         "https://googleblog.blogspot.com/atom.xml")
        ("Guardian"
         "https://www.theguardian.com/world/china/rss")
        ("HackerNews"
         "https://news.ycombinator.com/rss")
        ("SlashDot"
         "http://rss.slashdot.org/Slashdot/slashdotMain")
        ("FTChinese"
         "http://www.ftchinese.com/rss/feed")
        ("Songshuhui"
         "http://songshuhui.net/feed")
        ;; ("Pansci"
        ;;  "http://pansci.asia/feed")
        ("NewsmthTop10"
         "http://www.newsmth.net/nForum/rss/topten")
        ("Matrix67"
         "http://www.matrix67.com/blog/feed")
        ("Ruan"
         "http://feeds.feedburner.com/ruanyifeng")
        ("MaBoYong"
         "http://blog.sina.com.cn/rss/maboyong.xml")))
(defalias 'news 'newsticker-show-news)

(defun unfill-region (start end)
  "Replace newline chars in region by single spaces.
This command does the reverse of `fill-region'."
  (interactive "r")
  (let ((fill-column 90002000))
    (fill-region start end)))
(defun unfill-paragraph ()
  "Replace newline chars in current paragraph by single spaces.
This command does the reverse of `fill-paragraph'."
  (interactive)
  (let ((fill-column 90002000))
    (fill-paragraph nil)))
(global-set-key (kbd "M-p") 'unfill-paragraph)

;; dictionary: dict-xdict, dict-wn, dictd, dictionary-el needed
(setq dictionary-server "localhost")
(global-set-key "\C-h\C-s" 'dictionary-search)

(require 'bing-dict)
(global-set-key (kbd "C-h C-b") 'bing-dict-brief)

;; grep the word under cursor
(defun default-file-pattern ()
  (and
   (buffer-file-name)
   (concat "*." (file-name-extension (buffer-file-name)))))
(defun grep-at-point (directory word extname)
  "Grep the current word."
  (interactive
   (let ((origin-word (thing-at-point 'symbol))
         (word-hist ())
         (ext-hist ()))
     (list
      (read-file-name "grep directory: " default-directory default-directory)
      (read-from-minibuffer "grep word: " origin-word nil nil 'word-hist)
      (read-from-minibuffer
       "file ext: " (default-file-pattern) nil nil 'ext-hist))))
  (grep (format "cd %s && grep -nH -r '%s' . --include=\"%s\""
                directory
                word
                extname)))
(global-set-key [f6] 'grep-at-point)

;; org-mode
;; M-RET to insert, TAB and SHIFT-TAB
;; M-Shift-RET to add a TODO, C-c C-t to done a TODO
(require 'org)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)  ; C-c C-l to insert link
(define-key global-map "\C-ca" 'org-agenda)
(add-hook 'org-mode-hook 'turn-on-font-lock)
(add-hook 'org-mode-hook
          (lambda () (setq truncate-lines nil)))
(setq org-log-done t)
(setq org-src-fontify-natively t)

(defun show-file-name ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name)))
(global-set-key [f12] 'show-file-name)

(defun revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive) (revert-buffer t t))
(global-set-key [f5] 'revert-buffer-no-confirm)

(defun transpose-windows (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg)))))
  (other-window 1))
(global-set-key (kbd "C-x t") 'transpose-windows)

(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis, otherwise insert the character typed."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1))) ))
(global-set-key [f11] 'goto-match-paren)

(defun goto-random-line ()
  "Go to a random line in this buffer."
  (interactive)
  (goto-line (1+ (random (count-lines (point-min) (point-max))))))
(global-set-key (kbd "M-g M-r") 'goto-random-line)

;; different from M-g TAB in that it can jump past end-of-line
(defun goto-column (column)
  (interactive "nColumn: ")
  (move-to-column column t))
(global-set-key (kbd "M-g M-c") 'goto-column)

;; Emacs can run arbitrary commands with M-|. If you have xmllint installed:
;; "M-| xmllint --format -" will format the selected region
;; "C-u M-| xmllint --format -" will do the same, replacing the region with the output
;;
;; beautifying xml
(defun nxml-format ()
  (interactive)
  (save-excursion
    (shell-command-on-region
     (mark) (point) "xmllint --format -" (buffer-name) t)))

;; beautifying json
(defun json-format ()
  (interactive)
  (save-excursion
    (shell-command-on-region
     (mark) (point) "python -m json.tool" (buffer-name) t)))

;; To compare two regions, select the first region and run `diff-region`.  The
;; region is now copied to a seperate diff-ing buffer.  Next, navigate to the
;; next region in question (even in another file).  Mark the region and run
;; `diff-region-now`, the diff of the two regions will be displayed by ediff.
(defun diff-region ()
  "Select a region to compare"
  (interactive)
  (when (use-region-p)  ; there is a region
    (let (buf)
      (setq buf (get-buffer-create "*Diff-regionA*"))
      (save-current-buffer
        (set-buffer buf)
        (erase-buffer))
      (append-to-buffer buf (region-beginning) (region-end))))
  (message "Now select other region to compare and run `diff-region-now`"))
(defun diff-region-now ()
  "Compare current region with region already selected by `diff-region`"
  (interactive)
  (when (use-region-p)
    (let (bufa bufb)
      (setq bufa (get-buffer-create "*Diff-regionA*"))
      (setq bufb (get-buffer-create "*Diff-regionB*"))
      (save-current-buffer
        (set-buffer bufb)
        (erase-buffer))
      (append-to-buffer bufb (region-beginning) (region-end))
      (ediff-buffers bufa bufb))))

;; eval-defun works for defvar and defcustom, but eval-last-sexp doesn't.
;; This function applies eval-defun for the whole buffer.
;; http://emacs.stackexchange.com/questions/2298/how-do-i-force-re-evaluation-of-a-defvar
(defun my-eval-buffer ()
  "Execute the current buffer as Lisp code.
Top-level forms are evaluated with `eval-defun' so that `defvar'
and `defcustom' forms reset their default values."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (forward-sexp)
      (eval-defun nil))))

;; M-x toggle-debug-on-quit to trigger debug using C-g
;; M-x debug-on-entry or put (debug nil args-you-want-to-check) to set breakpoints
;; d to step through
;; c to skip/returns from debugger
;; e to eval some expression value
(setq debug-on-error nil)
;;(setq debug-on-quit t)

(if (version< emacs-version "24.4")
    (progn
      (message "old emacs: version before 24.4")
      (menu-bar-mode -1))
  (tool-bar-mode 0)
  (flyspell-mode t) ; M-$ to check, M-Tab to complete
  (electric-indent-mode -1)
  (toggle-frame-fullscreen)
  (set-coding-system-priority 'utf-8 'chinese-gb18030 'gb2312)
  (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
  ;; font: xfonts-wqy, ttf-wqy-* needed. font list: fc-list | grep WenQuanYi
  (when (and (window-system) (eq system-type 'gnu/linux))
    (set-default-font "DejaVu Sans Mono 12")
    (set-fontset-font "fontset-default"
                      'unicode (font-spec :family "WenQuanYi Micro Hei Mono" :size 17)))
  ;; w3m settings: w3m-el / emacs-w3m needed
  (require 'w3m)
  (setq w3m-home-page "http://www.google.com/ncr")
  (setq w3m-fill-column 80)
  (setq w3m-use-cookies t)
  (setq w3m-display-inline-image t)
  (setq browse-url-browser-function 'w3m-browse-url)
  (w3m-lnum-mode)                       ; (w3m-lnum-follow ARG) is bound to 'f'
  (defun my-w3m-mode-hook ()
    (local-set-key "c" (lambda () (interactive)
                         (browse-url-chrome (w3m-print-current-url))))
    (local-set-key "y" (lambda () (interactive)
                         (kill-new (w3m-print-this-url)))))
  (add-hook 'w3m-mode-hook 'my-w3m-mode-hook)
  (defalias 'chrome 'browse-url-chrome)
  ;; package manager: M-x list-packages, i to mark install, d to mark delete, x to exec
  (require 'package)
  (package-initialize))


;; M-x re-builder for regexp test
