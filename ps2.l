## The idea is to produce valid Javascript from valid Picolisp.
## All usefull (good parts) of Javascript should be produceable., however perhaps not all Picolisp will be convertable to Javascript. The ideal is that if it works in Javascript, it should work in Picolisp with the same results...
#In other words, javascript is a subset of picolisp.
#Not everything needs to be translateble from ps, also not everything needs to represented in ps, meaning not every js construct needs to be expressible in ps.
#Make a clear distinction between functions that map 1 to 1 , functions that are partial translations (behave the same in each language, but the pl version is more featured) and functions that translate to js or a bunch of js that do not work the same in pl, or functions that are new in pl, but native in js (mapping 1 1 or partial)
#You can write ps macros. Functions that abstract away js boilerplate etc. These macros can be different for every application, dsl's iow.

#A few problems:
#-----------------------------
#variable hoisting

#Pl has no floating point

#Booleans, null, NAN, equality etc

## Pl returns its last value from every function, js does this only when there is an explicit return statement, so put a return before the last statement. 

## If the last statement is a conditional you need to recursively go down its branches. How about loops? Check out coffeescript and parenscript..., 

## Not all statements are expressions in js, so when translating pl make sure you return an explicit value, by wrapping it in a function perhaps?
#try finally for dynamic binding? 
#or use uniquely named variables to simulate lexical closures?

## And the big one: ps does not have closures as such, it has job and first class environments, closures can be implemented. So there has to be a special ps function defining function (dec?) that translate into a closure in js and a implementation of it in pl

#classes and constructors and prototypes...


# pl's @ X (A . X) (A . @)....

#js doesn't know symbols, just variables. So just quoted symbols. Variables have as value another variable. They just point to the same thing...


(nil
   (setq *Indent 0
      *Operators '(+ - * /)
      *StOut 1
      )

   #Translator functions
   #Objects {} and arrays [] out of lists.
   #( ( a . b ) ( c . d ) etc) is an object.
   #( 1 2 a "bla" ((a . b)) ( 4 5 6)  etc ) is an array of numbers, variables, strings, arrays and objects
   
####################get, put, putl, getl, place###############
   (de js-put @
      (do (dec (length (rest))) 
         (let type (get-type (next))
            (if (<> type "qstring") (quit "Not a qstring: " (arg))
               (prin (strip (arg)))
               (if (< 1 (length (rest))) (prin '.)) )
            )
         )
      (prin " = " ) 
      (print-element (next))
 )
   
   (ps (put 'X 'a (+ 1 2))   #X.a = 1+2
      
 ) 
   
  ## (de placed (N S V) (set S (place N (val S) V))) 
  
 ##############################3 
  
   (de js-list @
      ## (msg "in jslist")
      ## (pretty (rest)) (prinl)
      (cond
         ((and (pair (next)) (= (size (arg) 1)) )
          (prin "{ ")
          (pass js-object, (arg))
          (prinl " }") )
         (T (prin "[" )
            ## (println (arg) (rest))
            (apply 'print-list (rest) "," (arg))
            (prin "]")
            )
         )

      )

   ## (de js-list @
   ##    (prinl "we're in js-list")
   ##    (prin "[" )
   ##    (apply 'print-list (arg) (rest))
   ##    (prin "]")
   ##  )

   (de js-object (X . @)
      (prin (car X) ":" (cdr X))
      (when (rest)
         (prog
            (prinl ",") 
            (pass js-object)
            ) ) )

   (de js-func-call (X . @)
      (prin X "(")
      (pass print-list ",")
      (prin ")")
 )
   # (ps (myfunc 1 2))

   (de js-assign (Name Expr)
      (prin (indent) Name " = " )
      (print-element Expr)
      ) 
   ## (ps (setq a (+ 1 2)))
   
   (de lambda (Args Name . Prg)

      )

   (de js-function (Name Parms . @)
      (prinl (indent) "var " (validate Name)
         " = function (" (js-parameters Parms) ") {" )
      (indent +)
      (pass js-statement-block)
      (indent -)
      (prin (indent) "}")
      
      ) 
   ## (ps (de testfunc (a b) (myfunc 1 2))) 
   
   (de js-new (Constr . @)
      (prin "new " Constr "(")
      (print-list (rest))
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
   
   (de js-operator (X . @)
      (prin "(")
      (pass print-list X) 
      (prin ")")
 )
   # (ps (* (+ 2 3) (- 3 4 5)))

   #The main disentangler, it processes a sexpr and calls the appropriate handler based on the first atom in the list
   (de js-sexpr (X . @)
      (cond
         ((= X 'list) (pass js-list))
         ((member X *Operators) (pass 'js-operator X))
         ((num? X) (pass 'js-list X))
         ((= X 'setq) (pass js-assign))
         ((= X 'de) (pass js-function))
         ((= X 'put) (pass js-put))
         ((= X 'get) (pass js-put))
         
         ((= X 'quote) (pass js-lambda))
         ((= X 'prog) (pass js-statement-block) )
         (T (pass 'js-func-call X))
         ## (T (throw T (prinl "Error: " (pretty (cdr X)))))
 ) )

   (de print-element (X)
      (case (get-type X)
         (list
            (apply 'js-sexpr X) )
         (string  (prin "\"" X "\"") )
         (qstring  (prin "\"" (cdr X) "\"") )
         (number   (prin X))
         (identifier  (prin X)) 
         (T (prin X))
      )
 ) 
   
   #This takes a list of lists and atoms and outputs a list of javascript statements/expressions, each ended with a semicolon
   #This would be for {} blocks
   (de js-statement-block (X . @)
      (when X 
         (prin (indent))
         (print-element X)
         (prinl ";")
         (pass js-statement-block )
         )
 )

   #This takes a list of lists and atoms and outputs a list of javascript statements/expressions, separated by Sep,
   #This would be for contents of arrays and parameter lists, compound expressions.
   (de print-list (Sep X . @)
      (print-element X)
      (when (rest)
         (prog
            (prin Sep) 
            (pass print-list Sep)
            ) ) ) 

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
               (T (throw T "indent function only takes + or -")) ) ) ) ) 

   (de get-type (X)
      (cond
         ((num? X) 'number)
         ((pair X)
          (ifn (= 'quote (car X))
             'list
             (if (pair (cdr X))
                (quit "Can't translate a quoted list." X)
                'qstring ) ) )
         ((str? X) 'string)
         (T 'identifier) ) )

   
   #The main translator,
   #Basically a reader, it takes apart its unevaluted args and tries to make valid Javascript out of it. If Fd is NIL the X gets evaluated as picolisp, otherwise it is a file descriptor. .
   ## (de ps (Fd .  X)
   (de ps X
      (let Fd 1 
         (ifn Fd (run X)
            (out Fd (apply 'js-statement-block X)) ) ) )

###############################################
   #Example call to ps
   ## (ps
   ##    ## "picoscript.js"
   ##    NIL
   ##    2
   ##    (setq a 1)
   ##    (de myfunc (arg1 arg2)
   ##       (log> console  "hello") )
   ##  )


###############################################
   #Tests
   ## (load 'test.l)

   #Test functions 
   (de ps-test  (Exp . X)
      (setq Exp (listefy Exp))
      (let Result 
         (pipe
            (apply 'js-statement-block X)
            (make (while (line T)
                     (link @) ) ) )
         (when  (catch '("test") (test Exp Result))
            (prinl "Expected:" )
            (for X Exp (prinl X))
            (prinl "But got:" )
            (for X Result (prinl X))
            ) 
         )
      NIL ) 

   (de listefy (Str)
      (make  
         (pipe (prin Str)
            (while (not (eof))
               (if (line T)
                  (link @) ) ) ) ) )

  #make test 
   (de psmt X
      (out "+testps.l" 
         (prinl "# " (stamp))
         (prin "(ps-test \"")
         #we need to escape quotes now..
         (pipe 
            (apply 'js-statement-block X)
            (while (char)
               (if (= @ "\"") (prin "\\\"")
                  (prin @) )
               ) )
         (prin "\" ")
         (for Y X (print Y) (prin " "))
         (prinl ")")
         (prinl)
         )
      )

   (load 'testps.l)

 )

## (ps-test "[1,a,\"quotestring1\",\"string2\",[1,2,3]];
## " (list 1 a 'string1 "string2" (list 1 2 3)) )
