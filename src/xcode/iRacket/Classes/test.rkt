#lang racket/base
(require ffi/unsafe
         ffi/unsafe/define
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
(define main-lib (ffi-lib #f))
(define uikit-lib (ffi-lib (format "/System/Library/Frameworks/UIKit.framework/UIKit")))
(import-class NSString)
(tell #:type _id NSString alloc)

;; libpng
(define-ffi-definer define-png main-lib
  #:provide provide)
(define _png_structp (_cpointer 'png_structp))
(define _png_infop (_cpointer 'png_infop))
(define _png_end_infop (_cpointer 'png_end_infop))
(define _png_size_t _long)
(define-png png_access_version_number (_fun -> _uint32))