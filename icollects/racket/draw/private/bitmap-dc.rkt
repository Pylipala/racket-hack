#lang racket/base
(require racket/class
         ffi/unsafe/atomic
         "syntax.rkt"
         "../unsafe/cairo.rkt"
         "color.rkt"
         "bitmap.rkt"
	 "dc.rkt"
         "local.rkt")

(provide bitmap-dc%
         bitmap-dc-backend%)

(define bitmap-dc-backend%
  (class default-dc-backend%
    (init [(_bm bitmap) #f])
    (inherit reset-cr)

    (define c #f)
    (define bm #f)
    (define b&w? #f)
    
    (when _bm
      (do-set-bitmap _bm #f))

    (define/override (ok?) (and c #t))

    (define/private (do-set-bitmap v reset?)
      (when c
        (cairo_destroy c)
        (set! c #f))
      (set! bm v)
      (when (and bm (send bm ok?))
        (set! c (cairo_create (send bm get-cairo-surface)))
        (set! b&w? (not (send bm is-color?)))))

    (define/public (internal-set-bitmap v [direct? #f])
      (if direct?
          (do-set-bitmap v #t)
          (call-as-atomic
           (lambda ()
             (do-set-bitmap v #t)
             (when c (reset-cr c))))))

    (define/public (internal-get-bitmap) bm)

    (def/override (get-size)
      (let ([bm bm])
        (values (exact->inexact (send bm get-width))
                (exact->inexact (send bm get-height)))))

    (define/override (get-cr) c)

    (define/override (end-cr) (void))

    (define/override (dc-adjust-smoothing s) 
      (if b&w?
          'unsmoothed
          s))

    (define/override (install-color cr c a)
      (if b&w?
          (begin
            (cairo_set_operator cr CAIRO_OPERATOR_SOURCE)
            (if (zero? a)
                (super install-color cr c a)
                (if (and (= (color-red c) 255)
                         (= (color-green c) 255)
                         (= (color-blue c) 255))
                    (cairo_set_source_rgba cr 1.0 1.0 1.0 0.0)
                    (cairo_set_source_rgba cr 0.0 0.0 0.0 1.0))))
          (super install-color cr c a)))

    (define/override (collapse-bitmap-b&w?) b&w?)

    (super-new)))

(define black (send the-color-database find-color "black"))

(define bitmap-dc%
  (class (dc-mixin bitmap-dc-backend%)
    (inherit draw-bitmap-section
             internal-set-bitmap
             internal-get-bitmap
             get-size
             get-transformation
             set-transformation
             scale)
    
    (super-new)

    (def/override (get-gl-context)
      (let ([bm (internal-get-bitmap)])
        (and bm
             (send bm get-bitmap-gl-context))))

    (def/public (set-bitmap [(make-or-false bitmap%) v])
      (internal-set-bitmap v))

    (def/public (get-bitmap)
      (internal-get-bitmap))
    
    (def/public (set-pixel [real? x][real? y][color% c])
      (let ([s (bytes 255 (color-red c) (color-green c) (color-blue c))])
        (set-argb-pixels x y 1 1 s)))

    (def/public (get-pixel [real? x][real? y][color% c])
      (let-values ([(w h) (get-size)])
        (let ([b (make-bytes 4)])
          (get-argb-pixels x y 1 1 b)
          (send c set (bytes-ref b 1) (bytes-ref b 2) (bytes-ref b 3))
          (and (<= 0 x w) (<= 0 y h)))))

    (def/public (set-argb-pixels [exact-nonnegative-integer? x]
                                 [exact-nonnegative-integer? y]
                                 [exact-nonnegative-integer? w]
                                 [exact-nonnegative-integer? h]
                                 [bytes? bstr]
                                 [any? [set-alpha? #f]])
      (let ([bm (internal-get-bitmap)])
        (when bm
          (send bm set-argb-pixels x y w h bstr set-alpha?))))

    (def/public (get-argb-pixels [exact-nonnegative-integer? x]
                                 [exact-nonnegative-integer? y]
                                 [exact-nonnegative-integer? w]
                                 [exact-nonnegative-integer? h]
                                 [bytes? bstr]
                                 [any? [get-alpha? #f]])
      (let ([bm (internal-get-bitmap)])
        (when bm
          (send bm get-argb-pixels x y w h bstr get-alpha?))))

    (def/public (draw-bitmap-section-smooth [bitmap% src]
                                            [real? dest-x]
                                            [real? dest-y]
                                            [nonnegative-real? dest-w]
                                            [nonnegative-real? dest-h]
                                            [real? src-x]
                                            [real? src-y]
                                            [nonnegative-real? src-w]
                                            [nonnegative-real? src-h]
                                            [(symbol-in solid opaque xor) [style 'solid]]
                                            [(make-or-false color%) [color black]]
                                            [(make-or-false bitmap%) [mask #f]])
      (let ([sx (if (zero? src-w) 1.0 (/ dest-w src-w))]
            [sy (if (zero? src-h) 1.0 (/ dest-h src-h))])
        (let ([t (get-transformation)])
          (scale sx sy)
          (begin0
           (draw-bitmap-section src (/ dest-x sx) (/ dest-y sy) src-x src-y src-w src-h style color mask)
           (set-transformation t)))))))

(install-bitmap-dc-class! bitmap-dc%)
