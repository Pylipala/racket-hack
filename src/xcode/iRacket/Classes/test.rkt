#lang racket/base
(require ffi/unsafe)

(define (iloveracket)
  (display "I love iRacket"))
(iloveracket)
(printf "~n")

; test ffi
(define uikit-lib (ffi-lib (format "/System/Library/Frameworks/UIKit.framework/UIKit")))
;(import-class NSString)