tinyCLA: lex.yy.o main.o
	gcc lex.yy.o main.o -o tinyCLA

main.o: main.c def.h
	gcc -c main.c -I.

lex.yy.o: lex.yy.c def.h
	gcc -c lex.yy.c -I.

lex.yy.c: lex.l
	flex lex.l

clean:
	rm lex.yy.o lex.yy.c main.o tinyCLA
