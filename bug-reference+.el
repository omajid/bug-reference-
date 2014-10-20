;; bug-reference+ --- extend bug-reference to provide multiple references

;; Copyright (C) 2008-2013 Free Software Foundation, Inc.
;; Copyright (C) 2014 Omair Majid

;; Author: Omair Majid <omair.majid@gmail.com>
;; Version: 0.1.20141019
;; Package-Requires: ((emacs "24"))
;; Keywords: tools
;; URL: http://github.com/omajid/bug-reference-

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see
;; <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package extends the bug-reference package to provide multiple
;; references in one buffer.  To use it set `bug-reference-alist' and
;; activate `bug-reference-mode'.

;;; Code:

(require 'bug-reference)

(defvar-local bug-references-alist '()
  "A list of (PATTERN . FORMAT).
See `bug-reference-bug-regexp' and  `bug-reference-url-format'.")

; overwrite with custom def
(defun bug-reference-fontify (start end)
  "Apply bug reference overlays to region defined by START and END."
  (save-excursion
    (let ((beg-line (progn (goto-char start) (line-beginning-position)))
          (end-line (progn (goto-char end) (line-end-position))))
      ;; Remove old overlays.
      (bug-reference-unfontify beg-line end-line)
      (let ((formats (cons
                      (cons bug-reference-bug-regexp bug-reference-url-format)
                      bug-references-alist)))
        (dolist (item formats)
          (let ((bug-regexp (car item))
                (bug-format (cdr item)))
            (goto-char beg-line)
            (progn
              (while (and (< (point) end-line)
                          (re-search-forward bug-regexp end-line 'move))
                (when (or (not bug-reference-prog-mode)
                          ;; This tests for both comment and string syntax.
                          (nth 8 (syntax-ppss)))
                  (let ((overlay (make-overlay (match-beginning 0) (match-end 0)
                                               nil t nil)))
                    (overlay-put overlay 'category 'bug-reference)
                    ;; Don't put a link if format is undefined
                    (when bug-format
                      (overlay-put overlay 'bug-reference-url
                                   (if (stringp bug-format)
                                       (format bug-format
                                               (match-string-no-properties 2))
                                     (funcall bug-format))))))))))))))

(provide 'bug-reference+)
;;; bug-reference+.el ends here
