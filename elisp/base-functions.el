;;; base-functions --- Custom functions
;;; Commentary:
;;; Add your custom functions here
;;; (defun something
;;;    (do-something))
;;; Code:

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

(provide 'base-functions)
;;; base-functions ends here
