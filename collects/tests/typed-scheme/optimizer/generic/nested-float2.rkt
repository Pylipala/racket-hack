(module nested-float typed/scheme #:optimize
  (require racket/unsafe/ops)
  (+ 2.0 (* 3.0 4.0)))