# 2012-08-09 20:32:07
(ps-test "1;
2;
3;
" 1 2 3 )

# 2012-08-09 22:10:45
(ps-test "\"str\";
" "str" )

# 2012-08-09 22:15:57
(ps-test "[1,a,\"str1\",\"str2\",[1,3]];
" (list 1 a 'str1 "str2" (list 1 3)) )

# 2012-08-09 22:47:46
(ps-test "((2+3)*(3-4-5));
" (* (+ 2 3) (- 3 4 5)) )

# 2012-08-09 22:55:57
(ps-test "a = (1+2);
" (setq a (+ 1 2)) )

# 2012-08-09 23:07:57
(ps-test "var testfunc = function () {
 (1+2);
};
" (de testfunc NIL (+ 1 2)) )

# 2012-08-09 23:11:30
(ps-test "myfunc(1,2);
" (myfunc 1 2) )

# 2012-08-09 23:15:45
(ps-test "var testfunc = function (a,b) {
 myfunc(1,2);
};
" (de testfunc (a b) (myfunc 1 2)) )

