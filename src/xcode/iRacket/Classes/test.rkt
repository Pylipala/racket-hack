#lang racket/base
(require ffi/unsafe
         ffi/unsafe/objc)

(define (iloveracket)
  (display "I love iRacket"))
(iloveracket)
(printf "~n")

; test path/directory
(getenv "PATH")
(current-directory)
(file-exists? (path->complete-path (find-system-path 'exec-file)))
(find-system-path 'exec-file)
(simplify-path (cleanse-path (find-system-path 'orig-dir)) #f)
(find-executable-path (find-system-path 'exec-file))

; test ffi
(ffi-lib #f)
(define uikit-lib (ffi-lib (format "/System/Library/Frameworks/UIKit.framework/UIKit")))
(import-class NSString)
(tell #:type _id NSString alloc)