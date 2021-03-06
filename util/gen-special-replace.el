;; This code creates ruby code to replace special symbols with the corresponding utf8/html code

(require 'org-entities)

(defvar gen-use-entities-user t)
(defvar gen-file-name "replace-entities.rb")

(defun generate-replace-inbuffer (what)
  (let ((ll (if gen-use-entities-user
                (append org-entities-user org-entities)
              org-entities))
        (to (if (string= what "html") 3
              6))) ; use utf8 for textile
    (insert "  def Orgmode.special_symbols_to_" what "(str)\n")
    (dolist (entity ll)
      (when (listp entity)
        (let ((symb (nth to entity)))
          (when (or (string= symb "\"") (string= symb "\\"))
            (setq symb (concat "\\" symb)))
          (insert "    str.gsub!(/\\\\" (car entity) "((\\{\\})|(\\s|$))/, \"" symb "\\\\3\")\n"))))
    (insert "  end\n")))

(defun generate-replace (file-name what)
  (when (file-exists-p file-name)
    (let ((buf (find-buffer-visiting file-name)))
      (when buf
        (kill-buffer buf)))
    (delete-file file-name))
  (find-file file-name)
  (insert "# Autogenerated by util/gen-special-replace.el\n\nmodule Orgmode\n")
  (generate-replace-inbuffer what)
  (insert "end # module Orgmode\n")
  (save-buffer)
  (kill-buffer))

(generate-replace "../lib/org-ruby/html_symbol_replace.rb" "html")
(generate-replace "../lib/org-ruby/textile_symbol_replace.rb" "textile")
