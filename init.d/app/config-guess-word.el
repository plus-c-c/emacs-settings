(provide 'config-guess-word)
(use-package guess-word
  :load-path "~/.emacs.d/site-lisp/guess-word"
  :commands (guess-word)
  :custom
  (guess-word-org-file (f-expand "guess-word.org" org-directory))
  (guess-word-dictionarys '("TOEFL.txt" "CET6_edited.txt" "CET4_edited.txt"))
  )
