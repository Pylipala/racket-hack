#lang scheme/base
(require ffi/unsafe
         ffi/unsafe/define
         ffi/unsafe/alloc
         setup/dirs
         "../private/libs.rkt"
         "../private/utils.rkt")

(define quartz-lib
  (ffi-lib (format "/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics")))

(define-ffi-definer define-quartz quartz-lib
  #:provide provide-protected)

(define _size_t _long)

(define _CGContextRef (_cpointer 'CGContextRef))
(define _CGContextRef/null (_cpointer/null 'CGContextRef))
(define _CGBitmapInfo _uint32)
(define _CGColorSpaceRef (_cpointer 'CGColorSpaceRef))

(define-quartz CGColorSpaceCreateDeviceRGB
  (_fun _void -> _CGColorSpaceRef)
  #:make-fail make-not-available
  #:wrap (allocator CGColorSpaceRelease))

(define-quartz CGColorSpaceRelease
  (_fun _CGColorSpaceRef -> _void)
  #:wrap (deallocator))

(define-quartz CGContextRelease
  (_fun _CGContextRef -> _void)
  #:wrap (deallocator))

(define-quartz CGBitmapContextCreate
  (_fun _pointer _size_t _size_t _size_t _size_t _CGColorSpaceRef _CGBitmapInfo -> _CGContextRef)
  #:make-fail make-not-available
  #:wrap (allocator CGContextRelease))


