a.out: lex.yy.o ass3_20CS10063_20CS30057.o
	gcc lex.yy.o ass3_20CS10063_20CS30057.o

ass3_20CS10063_20CS30057.o: ass3_20CS10063_20CS30057.c def.h
	gcc -c ass3_20CS10063_20CS30057.c -I.

lex.yy.o: lex.yy.c def.h
	gcc -c lex.yy.c -I.

lex.yy.c: ass3_20CS10063_20CS30057.l
	flex -o lex.yy.c ass3_20CS10063_20CS30057.l

clean:
	rm lex.yy.o lex.yy.c ass3_20CS10063_20CS30057.o a.out
