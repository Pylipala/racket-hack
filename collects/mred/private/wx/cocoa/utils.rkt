#lang racket/base
(require ffi/unsafe/objc
         ffi/unsafe
         ffi/unsafe/alloc
         ffi/unsafe/define
         "../common/utils.rkt"
         "../../lock.rkt")

(provide 
 (protect-out cocoa-lib
              cf-lib
              define-cocoa
              define-cf
              define-appserv
              define-appkit
              as-objc-allocation
              as-objc-allocation-with-retain
              clean-up-deleted
              retain release
              with-autorelease
              clean-menu-label
              ->wxb
              ->wx
              old-cocoa?
              version-10.6-or-later?)
 define-mz)

(define cocoa-lib (ffi-lib (format "/System/Library/Frameworks/Cocoa.framework/Cocoa")))
(define cf-lib (ffi-lib (format "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")))
(define appserv-lib (ffi-lib (format "/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices")))
(define appkit-lib (ffi-lib (format "/System/Library/Frameworks/AppKit.framework/AppKit")))

(define-ffi-definer define-cocoa cocoa-lib)
(define-ffi-definer define-cf cf-lib)
(define-ffi-definer define-appserv appserv-lib)
(define-ffi-definer define-appkit appkit-lib)

(define delete-me null)

(define (objc-delete o)
  (tellv o release))

(define (clean-up-deleted)
  (free-remembered-now objc-delete))

(define objc-allocator (allocator remember-to-free-later))

(define-syntax-rule (as-objc-allocation expr)
  ((objc-allocator (lambda () expr))))

(define-syntax-rule (as-objc-allocation-with-retain expr)
  ((objc-allocator (lambda () (let ([v expr])
                                (tellv v retain)
                                v)))))

(define release ((deallocator) objc-delete))
(define retain ((retainer release car)
                (lambda (obj)
                  (tellv obj retain))))

(import-class NSAutoreleasePool)

;; Use `with-autorelease' and `call-with-autorelease' 
;; in atomic mode
(define-syntax-rule (with-autorelease expr ...)
  (call-with-autorelease (lambda () expr ...)))
(define (call-with-autorelease thunk)
  (let ([pool (tell (tell NSAutoreleasePool alloc) init)])
    (begin0
     (thunk)
     (tellv pool release))))

(define (clean-menu-label str)
  (regexp-replace* #rx"&(.)" str "\\1"))

(define (->wxb wx)
  (make-weak-box wx))

(define (->wx wxb)
  (and wxb
       (weak-box-value wxb)))

(define-appkit NSAppKitVersionNumber _double)

(define old-cocoa? 
  ; earlier than 10.5?
  (NSAppKitVersionNumber . < . 949))
(define (version-10.6-or-later?)
  (NSAppKitVersionNumber . >= . 1038))
