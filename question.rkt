#lang racket/base

(require scribble/core
         scribble/base
         scribble/html-properties
         racket/function
         racket/bool)

(provide question
         option
         multiple-choice
         multiple-select)


;; Option is (option Content Boolean)
(struct option (label correct?)
  #:transparent
  #:guard (lambda (label correct? name)
            (unless (content? label)
              (error (format "Invalid option; expects label content? Given: ~a" label)))
            (unless (boolean? correct?)
              (error (format "Invalid option; expects correct? boolean? Given: ~a" correct?))) 
            (values label correct?)))


;; Multiple-Choice is (option Content (listof Option))
(struct multiple-choice (label options)
  #:transparent
  #:guard (lambda (label options name)

            (unless (content? label)
              (error (format "Invalid problem; expects label content? Given: ~a" label)))
             
            (unless (not (eq? options '()))
              (error "Invalid options; expects non-empty options"))
             
            (unless (for/fold ([correct-found? #false])
                              ([option options])
                      (unless (option? option)
                        (error "Invalid options; list contains non-option"))
                      (or (and (option-correct? option)
                               correct-found?
                               (error "Invalid options; contains multiple correct options"))
                          (or (option-correct? option)
                              correct-found?)))
              (error "Invalid options; no correct option found"))
            (values label options)))

;; Multiple-Select is (multiple-select Content (listof Option))
(struct multiple-select (label options)
  #:transparent
  #:guard (lambda (label options name)

            (unless (content? label)
              (error (format "Invalid problem; expects label content? Given: ~a" label)))
             
            (unless (andmap option? options)
              (error "Invalid options; list contains non-option"))
             
            (values label options)))


;; Problem is one of:
;; - Multiple-Choice
;; - Multiple-Select

(define (problem? x)
  (or (multiple-choice? x)
      (multiple-select? x)))

(define question-style
  (style "question"
         (list (alt-tag "div")
               (css-addition "qstyle.css")
               (js-addition "script.js"))))


(define correct-icon
  (elem
   #:style
   (style "result-icon"
          (list (alt-tag "img")
                (attributes
                 '((src . "https://docs.racket-lang.org/images/pict_62.png")
                   (id . "correct-icon")))))))


(define incorrect-icon
  (elem
   #:style
   (style "result-icon"
          (list (alt-tag "img")
                (attributes
                 '((src . "https://docs.racket-lang.org/images/pict_61.png")
                   (id . "incorrect-icon")))))))

;; Option String String -> Content
(define (render-option op type name)
  (elem #:style (style "option" (list (alt-tag "div")))
        (elem #:style (style (if (option-correct? op)
                                 "correct"
                                 #f) (list (alt-tag "label")))
              (list (elem #:style (style #f (list (alt-tag "input")
                                                  (attributes
                                                   `((type . ,type)
                                                     (name . ,name)
                                                     (value . ,(symbol->string (gensym)))))))
                          (elem #:style (style "option-label" (list (alt-tag "div")))
                                (elem #:style (style #f (list (alt-tag "span")))
                                      (option-label op))))))))

;; Multiple-Choice -> Content 
(define (render-multiple-choice p)
  (define name (symbol->string (gensym)))
  (elem #:style (style "multiple-choice" (list (alt-tag "div")))
        (list (multiple-choice-label p)
              (elem #:style (style "options" (list (alt-tag "div")))
                    (map (curryr render-option "radio" name) (multiple-choice-options p))))))

;; Multiple-Select -> Content
(define (render-multiple-select p)
  (define name (symbol->string (gensym)))
  (elem #:style (style "multiple-select" (list (alt-tag "div")))
        (list (multiple-select-label p)
              (elem #:style (style "options" (list (alt-tag "div")))
                    (map (curryr render-option "checkbox" name) (multiple-select-options p))))))

;; Problem -> Content
(define (render-problem p)
  (cond [(multiple-choice? p) (render-multiple-choice p)]
        [(multiple-select? p) (render-multiple-select p)]))

;; (listof Problem) -> Content
(define (render-problems lop)
  (elem #:style (style "problems" (list (alt-tag "div")))
        (map render-problem lop)))

;; Content|false -> Content
(define (render-hint hint)
  (cond [(content? hint)
         ;=>
         (elem #:style (style "hint-container"
                              (list (alt-tag "div")))
               hint)]
        [else '()]))
  

;; Content|false -> Content
(define (render-explanation expl)
  (cond [(content? expl)
         ;=>
         (elem #:style (style "explanation-container"
                              (list (alt-tag "div")))
               expl)]
        [else '()]))


;; Content (listof Problem) [Content] [Content] -> Content
(define (question label problems [hint #false] [explanation #false])
  (elem
   #:style (style "question"
                  (list (alt-tag "div")
                        (css-addition "qstyle.css")
                        (js-addition "script.js")))
   (list label
         (render-problems problems)
         (elem #:style (style "result-buttons" (list (alt-tag "div")))
               (list (elem #:style (style "submit-btn-container" (list (alt-tag "div")))
                           (list (elem #:style (style "submit" (list (alt-tag "button")
                                                                     (attributes
                                                                      `((type . "button")))))
                                       "Submit"))
                           correct-icon
                           incorrect-icon)
                     (if (false? hint)
                         '()
                         (elem #:style (style "hint" (list (alt-tag "button")
                                                           (attributes
                                                            '((type . "button")))))
                               "Hint"))))
         (render-hint hint)
         (render-explanation explanation))))

