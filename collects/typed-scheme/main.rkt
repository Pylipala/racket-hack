#lang s-exp "minimal.rkt"
           


(providing (libs (except scheme/base #%module-begin #%top-interaction with-handlers number? lambda #%app)
                 (except "private/prims.rkt")
                 (except "private/base-types.rkt")
                 (except "private/base-types-extra.rkt"))
	   (basics #%module-begin		   		   		   
		   #%top-interaction
		   lambda
		   #%app))
(require "private/base-env.rkt" 
	 "private/base-special-env.rkt"
	 "private/base-env-numeric.rkt"
	 "private/base-env-indexing-old.rkt"
	 "private/extra-procs.rkt"
         (for-syntax "private/base-types-extra.rkt"))
(provide (rename-out [with-handlers: with-handlers] [real? number?])
         (for-syntax (all-from-out "private/base-types-extra.rkt"))
	 assert with-type)