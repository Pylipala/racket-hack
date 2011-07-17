#lang racket/base
(require ffi/unsafe
         ffi/unsafe/define
         ffi/unsafe/objc
         ffi/unsafe/alloc
         racket/draw/unsafe/jpeg
         racket/draw/unsafe/png
         test-engine/racket-tests)

(define (iloveracket)
  (display "I love iRacket"))
(iloveracket)
(printf "~n")

(system-type)

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

(define quartz-lib
  (ffi-lib (format "/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics")))

(define-ffi-definer define-quartz quartz-lib
  #:provide provide-protected)

(define _size_t _long)

(define _CGContextRef (_cpointer 'CGContextRef))
(define _CGContextRef/null (_cpointer/null 'CGContextRef))
(define _CGBitmapInfo _uint32)
(define _CGColorSpaceRef (_cpointer 'CGColorSpaceRef))

(define-quartz CGContextRelease
  (_fun _CGContextRef -> _void)
  #:wrap (deallocator))

(define-quartz CGBitmapContextCreate
  (_fun _pointer _size_t _size_t _size_t _size_t _CGColorSpaceRef _CGBitmapInfo -> _CGContextRef)
  #:make-fail make-not-available
  #:wrap (allocator CGContextRelease))

#|
;; libpng
(define-ffi-definer define-png main-lib
  #:provide provide)
(define _png_structp (_cpointer 'png_structp))
(define _png_infop (_cpointer 'png_infop))
(define _png_end_infop (_cpointer 'png_end_infop))
(define _png_size_t _long)
(define-png png_access_version_number (_fun -> _uint32))

;; libjpeg
(define-ffi-definer define-jpeg main-lib
  #:provide provide)
(define _j_common_ptr _pointer)
(define _size_t _long)
(define _JDIMENSION _uint)
(define _J_COLOR_SPACE _int)
(define _J_DCT_METHOD _int)
(define _J_DITHER_MODE _int)
(define _pool_id _int)
(define JPOOL_PERMANENT 0)
(define JPOOL_IMAGE 1)
(define JPOOL_NUMPOOLS 2)
(define JMSG_LENGTH_MAX  200)

(define-cstruct _jpeg_error_mgr ([error_exit (_fun _j_common_ptr -> _void)]
                                 [emit_message _pointer]
                                 [output_message _pointer]
                                 [format_message (_fun _j_common_ptr _pointer -> _void)]
                                 ;; and more, including an inline character                                                                       
                                 ;; array that is a pain to handle here                                                                           
                                 ))
(define sizeof_jpeg_error_mgr 1024)
|#

(check-expect (+ 1 2) 4)
(test)