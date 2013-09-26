picoscript
==========

The beginning of version of picolisp that translates to javascript.

But only perhaps 10% done, but with tests.

## The idea is to produce valid Javascript from valid Picolisp.

## All usefull (good parts) of Javascript should be produceable., however perhaps not all Picolisp will be convertable to Javascript. The ideal is that if it works in Javascript, it should work in Picolisp with the same results...

#In other words, javascript is a subset of picolisp.

#Not everything needs to be translateble from ps, also not everything needs to represented in ps, meaning not every js construct needs to be expressible in ps.

#Make a clear distinction between functions that map 1 to 1 , functions that are partial translations (behave the same in each language, but the pl version is more featured) and functions that translate to js or a bunch of js that do not work the same in pl, or functions that are new in pl, but native in js (mapping 1 1 or partial)

#You can write ps macros. Functions that abstract away js boilerplate etc. These macros can be different for every application, dsl's iow.

#A few problems:
-----------------------------

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
