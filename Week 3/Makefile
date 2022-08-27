tinyCLA: lex.yy.o
	gcc lex.yy.o -o tinyCLA

lex.yy.o: lex.yy.c def.h
	gcc -c lex.yy.c -I.

lex.yy.c: lex.l
	flex lex.l
