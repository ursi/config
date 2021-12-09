(define-syntax X
  (letrec ([take (lambda (n l)
                   (if (= n 0) '() (cons (car l) (take (- n 1) (cdr l)))))]
           [drop (lambda (n l) (if (= n 0) l (drop (- n 1) (cdr l))))]
           [gen-list (lambda (n f)
                       (do ([i 1 (+ i 1)] [list '() (cons (f i) list)])
                           ((> i n) list)))])
    (lambda (x)
      (syntax-case x ()
        [(_ (v1 v2 ...) b1 b2 ...)
         (let* ([args #'(v1 v2 ...)]
                [num-args (length args)]
                [body #'(b1 b2 ...)])
           #`(case-lambda
               #,@(map (lambda (pair)
                         (cons
                           (car pair)
                           (if (= (length (car pair)) num-args)
                               body
                               #`((X #,(cdr pair) #,@body)))))
                       (gen-list
                         num-args
                         (lambda (i)
                           (cons (take i args) (drop i args)))))))]))))

; ------------ CHARS -------------

(define code-point (.> char->integer (flip number->string 16)))

; ------------ DEBUGGING ---------

(define debug-log (X (a) (pretty-print a) a))

; ------------ CURRIED FORMS -----

(eval
  `(begin
     ,@(map (X (a)
               `(define ,(car a) (X (a b) (,(cdr a) a b))))
            '((add . +)
              (sub . -)
              (mul . *)
              (div . /)
              (^ . expt)))))

; ------------ FP ----------------
(define (-> v . fs) ((apply .> fs) v))

(define (.> . fs)
  (if (null? fs)
      id
      (X (a) ((apply .> (cdr fs)) ((car fs) a)))))

(define <>
  (X (a b)
     (cond
       [(string? a) (string-append a b)]
       [(list? a) (append a b)]
       [(symbol? a) (string->symbol (<> (symbol->string a) (symbol->string b)))]
       [else (error "<>" "not a string or a list" a)])))

(define id (X (a) a))
(define const (X (a b) a))
(define-syntax const* (syntax-rules () [(_ a) (X (b) a)]))
(define flip (X (f a b) (f b a)))

(define fold
  (X (f list)
     (if (null? list)
         '()
         (fold-left f (car list) (cdr list)))))

; ------------ LISTS -------------

(define drop (X (n l) (if (= n 0) l (drop (- n 1) (cdr l)))))

(define gen-list
  (X (n f)
     (do ([i 0 (+ i 1)] [list '() (cons (f i) list)])
         ((= i n) (reverse list)))))

(define range
  (X (a b) (gen-list (+ (- b a) 1) (X (i) (+ a i)))))

(define take (X (n l) (if (= n 0) '() (cons (car l) (take (- n 1) (cdr l))))))

; ------------ MATH -------------

(define log_ (X (a b) (log b a)))
(define pi (* 2 (acos 0)))

; ------------ RANDOM ------------

(define rand-int (X (a b) (+ a (random (+ (- b a) 1)))))

(define rand-int-list
  (X (length lower upper)
    (gen-list length (const* (rand-int lower upper)))))

; ------------ STRINGS -----------

(define string-car (X (s) (car (string->list s))))
