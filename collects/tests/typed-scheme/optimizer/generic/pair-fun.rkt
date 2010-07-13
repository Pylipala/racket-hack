(module pair-fun typed/scheme #:optimize
  (require racket/unsafe/ops)
  (: f ((Listof Integer) -> Integer))
  (define (f x)
    (if (null? x)
        1
        (car x))))