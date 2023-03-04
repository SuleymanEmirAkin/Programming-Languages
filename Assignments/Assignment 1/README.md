How to compile:
1) yacc -d peakasso.y
2) flex peakasso.l
3) gcc -g lex.yy.c y.tab.c -o peakasso

How to take input:
When you run like this ./peakasso
If you enter 0 the program takes input from .txt file and if you enter takes input from terminal.
