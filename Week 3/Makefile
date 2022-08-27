tinyCLA: lex.yy.o
	gcc main.o

lex.yy.o: lex.yy.c def.h
	gcc -c lex.yy.c -I.

lex.yy.c: lex.l
	flex lex.l
