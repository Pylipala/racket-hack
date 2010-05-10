#lang scheme/base
(require scheme/gui/dynamic)

(provide send-event)
  
(define send-event 
  (lambda (who class msg [data (void)] [args null])
    (if (gui-available?)
        ((gui-dynamic-require 'send-event) who class msg data args)
        (raise
         (make-exn:fail:unsupported
          "send-event: only supported in MrEd"
          (current-continuation-marks))))))
