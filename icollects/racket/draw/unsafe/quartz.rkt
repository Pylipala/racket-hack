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

(define _CGFloat (make-ctype (if 64-bit? _double _float)
(define-cstruct _CGPoint ([x _CGFloat]
			  [y _CGFloat]))
(define-cstruct _CGSize ([width _CGFloat]
			 [height _CGFloat]))
(define-cstruct CGRect ([origin _CGPoint]
			[size _CGSize]))

(define _CGContextRef (_cpointer 'CGContextRef))
(define _CGContextRef/null (_cpointer/null 'CGContextRef))
(define _CGBitmapInfo _uint32)
(define _CGColorSpaceRef (_cpointer 'CGColorSpaceRef))
(define _CGImageRef (_cpointer 'CGImageRef))

(define-quartz CGColorSpaceRelease
  (_fun _CGColorSpaceRef -> _void)
  #:wrap (deallocator))

(define-quartz CGContextRelease
  (_fun _CGContextRef -> _void)
  #:wrap (deallocator))

(define-quartz CGColorSpaceCreateDeviceRGB
  (_fun _void -> _CGColorSpaceRef)
  #:make-fail make-not-available
  #:wrap (allocator CGColorSpaceRelease))

(define-quartz CGBitmapContextCreate
  (_fun _pointer _size_t _size_t _size_t _size_t _CGColorSpaceRef _CGBitmapInfo -> _CGContextRef)
  #:make-fail make-not-available
  #:wrap (allocator CGContextRelease))

(define-quartz CGBitmapContextCreateImage
  (_fun _CGContextRef -> _CGImageRef))

(define-quartz CGBitmapContextGetHeight
  (_fun _CGContextRef -> _size_t))

(define-quartz CGBitmapContextGetWidth
  (_fun _CGContextRef -> _size_t))

(define-quartz CGBitmapContextGetBitsPerPixel
  (_fun _CGContextRef -> _size_t))

(define-quartz CGBitmapContextGetBitsPerComponent
  (_fun _CGContextRef -> _size_t))

(define-quartz CGBitmapContextGetData
  (_fun _CGContextRef -> _cpointer/null))

(define-quartz CGBitmapContextGetBytesPerRow
  (_fun _CGContextRef -> _size_t))

(define-quartz CGContextBeginPath
  (_fun _CGContextRef -> _void))

(define-quartz CGContextClosePath
  (_fun _CGContextRef -> _void))

(define-quartz CGContextDrawImage
  (_fun _CGContextRef _CGRect _CGImageRef -> _void))

(define-quartz CGImageCreateWithImageInRect
  (_fun _CGImageRef _CGRect -> _CGImageRef))

(define-quartz CGImageRelease
  (_fun _CGImageRef -> _void))

(define-quartz CGContextConvertRectToUserSpace
  (_fun _CGContextRef _CGRect -> _CGRect))

(define-quartz CGRectMake
  (_fun _CGFloat _CGFLoat _CGFloat _CGFloat -> _CGRect))

(define-enum 0
  kCGImageAlphaNone
  kCGImageAlphaPremultipliedLast
  kCGImageAlphaPremultipliedFirst
  kCGImageAlphaLast
  kCGImageAlphaFirst
  kCGImageAlphaNoneSkipLast
  kCGImageAlphaNoneSkipFirst)

(define-enum 0
  (kCGBitmapAlphaInfoMask = #x1F)
  (kCGBitmapFloatComponents = (arithmetic-shift 1 8))
  (kCGBitmapByteOrderMask = #x7000)
  (kCGBitmapByteOrderDefault = (arithmetic-shift 0 12))
  (kCGBitmapByteOrder16Little = (arithmetic-shift 1 12))
  (kCGBitmapByteOrder32Little = (arithmetic-shift 2 12))
  (kCGBitmapByteOrder16Big = (arithmetic-shift 3 12))
  (kCGBitmapByteOrder32Big = (arithmetic-shift 4 12)))

