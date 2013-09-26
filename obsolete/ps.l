## The idea is to produce valid Javascript from valid Picolisp.
## All usefull (good parts) of Javascript should be produceable., however perhaps not all Picolisp will be convertable to Javascript. The ideal is that if it works in Javascript, it should work in Picolisp with the same results...

#Constants
(setq *Indent 0
   *Operators '(+ - * /)

   )

(de js-list @
   (cond
      ((and (pair (next)) (= (size (arg) 1)) )
       (prin "{ ")
       (pass js-object, (arg))
       (prinl " }") )
      (T (prin "[" )
         (apply 'js-prog-cs (arg) (rest))
         (prin "]")
         )
      )

   )

(de js-object (X . @)
   (prin (car X) ":" (cdr X))
   (when (rest)
      (prog
         (prinl ",") 
         (pass js-object)
         ) ) )

(de js-func-call (X . @)
   (prin X "(")
   (js-prog-cs (rest))
   (prinl ")")
   )

(de js-assign (Name Expr)
   (prin (indent) Name " = " )
   (js-expr Expr)
   ) 

(de lambda (Args Name . Prg)

   )

(de js-function (Name Parms . @)
   (prinl (indent) "var " (validate Name)
      " = function (" (js-parameters Parms) ") {" )
   (indent +)
   (js-prog-ss (rest))
   (indent -)
   (prinl (indent) "}")
   
   ) 

(de js-new (Constr . @)
   (prin "new " Constr "(")
   (js-prog-cs (rest))
   (prin ")")
   )

(de js-parameters (X)
   (when X
      (prin (car X))
      (setq X (cdr X))
      (recur (X)
         (when X
            (prin "," (car X))
            (recurse (cdr X)) ) ) )
   )

#Helper functions
(de validate (Name)
   #(if (Name has other than $ _ letter or number) (throw T (pack Name " is not a valid javascript name")
   Name
   )

(de indent X
   (job '((spaces . NIL))
      (ifn (car X) spaces
         (case @
            (+ (setq spaces (cons " " spaces)))
            (- (setq spaces (cdr spaces)))
            (0 (off spaces))
            (T (throw T "indent function only takes + or -")) ) )
      )
   ) 

#The main translator,
#Basically a reader, it takes apart its unevaluted args and tries to make valid Javascript out of it.
(de ps-to-js (Fd .  X) (out Fd (apply 'js-prog-ss X) ) )

#This takes a list of lists and atoms and outputs a list of java statements/expressions, each ended with a semicolon
#This would be for {} blocks
(de js-prog-ss (X . @)
   (when X 
      (prin (indent))
      (cond
         ((pair X) (apply 'js-sexpr X))
         (T (prin X))
         )
      (prin ";")
      (js-prog-ss (rest))
      )
   )


#This takes a list of lists and atoms and outputs a list of java statements/expressions, separated by commas,
#This would be for contents of arrays and parameter lists.
(de js-prog-cs (X . @)
      (cond
         ((pair X) (apply 'js-sexpr X))
         (T (prin X))
         )
      (when (rest)
         (prog
            (prin ",") 
            (js-prog-cs @)
            ) ) ) 
i
## rest args arg pass nex                 
#The main disentangler, it processes a sexpr and calls the appropriate handler based on the first atom in the list
#You could do this different where you redefine all picolisp functions you want to translate, call the original first off so there is no change with how picolisp works and output javascript code
(de js-sexpr (X . @)
   (cond
      ((= X 'de) (pass js-function))
      ((= X 'setq) (pass js-assign))
      ((= X 'quote) (pass js-lambda))
      ((= X 'list) (pass js-list))
      ((member X *Operators) (pass 'js-operator X))
      ((num? X) (pass 'js-list X))
      ((= X 'prog) (js-prog-ss (rest)) )
      
      (T (pass 'js-func-call X))
      ## (T (throw T (prinl "Error: " (pretty (cdr X)))))
      ) )


## (ps-to-js
##    ## "picoscript.js"
##    2
##    (setq a 1)
##    (de myfunc (arg1 arg2)
##       (log> console  "hello") )
##    )


## (out "picoscript.js" (prinl "Hello bdsfaffrom pico"))
## (out "picoscript.js" (prinl "Hello bdom pico"))


