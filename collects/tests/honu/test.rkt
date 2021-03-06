#lang racket/base

(require 
  (prefix-in macro_ honu/core/private/macro2)
  (rename-in honu/core/private/honu2
             [honu-function honu_function]
             [honu-+ honu_plus]
             [honu-* honu_times]
             [honu-- honu_minus])
  (rename-in honu/core/private/literals
             [honu-= =]
             [semicolon |;|])
  (rename-in (only-in honu/core/private/honu-typed-scheme honu-var)
             [honu-var var])
  (for-syntax racket/base
              honu/core/private/macro2
              syntax/stx
              racket/port
              syntax/parse
              (prefix-in parse: honu/core/private/parse2))
  racket/port)

(define-syntax (fake-module-begin stx)
  (syntax-case stx ()
    [(_ stuff)
     (let ()
       (define output (parse:parse (stx-cdr #'stuff)))
       (printf "Output: ~a\n" (syntax->datum output))
       output)]))

#;
(fake-module-begin #hx(macro_macro foo (){ x:number }{
                            withSyntax [z 5]{
                               syntax(print(x); print(z););
                            }
                         }
                         foo 5))

(fake-module-begin #hx(var x = 2;
                       print(x)))

(let ()
  (fake-module-begin #hx(honu_function test(x){
                                       print(x)
                                       }))
  (test 5))

(let ()
  (fake-module-begin #hx(honu_function test(x){
                                       print(x);
                                       print(x)
                                       }
                         test(2))))


(let ()
  (fake-module-begin #hx(1 honu_plus 1)))

(let ()
  (fake-module-begin #hx(1 honu_plus 1 honu_minus 4)))

(let ()
  (fake-module-begin #hx(1 honu_plus 1 honu_minus 4 honu_times 8)))
