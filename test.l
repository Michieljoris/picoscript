#Test functions 
(de ps-test  (Exp . X)
   (setq Exp (listefy Exp))
   (let Result 
      (pipe
         (apply 'js-prog-ss X)
         (make (while (line T)
                  (link @) ) ) )
      (when  (catch '("test") (test Exp Result))
         (prinl "Expected:" )
         (for X Exp (prinl X))
         (prinl "But got:" )
         (for X Result (prinl X))
         ) 
      (for X Result (prinl X)))
   NIL ) 

(de listefy (Str)
   (make  
      (pipe (prin Str)
         (while (not (eof))
            (if (line T)
               (link @)) ) ) ) )

