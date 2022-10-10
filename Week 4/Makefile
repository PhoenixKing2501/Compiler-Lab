ass4_20CS10063_20CS30057_output.txt: parser ass4_20CS10063_20CS30057_test.c
	./parser < ass4_20CS10063_20CS30057_test.c > ass4_20CS10063_20CS30057_output.txt

parser: lex.yy.o ass4_20CS10063_20CS30057.tab.o ass4_20CS10063_20CS30057_main.o
	gcc -Wall lex.yy.o ass4_20CS10063_20CS30057.tab.o ass4_20CS10063_20CS30057_main.o -o parser

ass4_20CS10063_20CS30057_main.o: ass4_20CS10063_20CS30057_main.c
	gcc -c -Wall ass4_20CS10063_20CS30057_main.c

lex.yy.o: lex.yy.c
	gcc -c -Wall lex.yy.c

ass4_20CS10063_20CS30057.tab.o: ass4_20CS10063_20CS30057.tab.c
	gcc -c -Wall ass4_20CS10063_20CS30057.tab.c

lex.yy.c: ass4_20CS10063_20CS30057.l ass4_20CS10063_20CS30057.tab.h
	flex ass4_20CS10063_20CS30057.l

ass4_20CS10063_20CS30057.tab.c ass4_20CS10063_20CS30057.tab.h: ass4_20CS10063_20CS30057.y
	bison --header --debug --report=all ass4_20CS10063_20CS30057.y

clean:
	rm parser ass4_20CS10063_20CS30057_main.o lex.yy.* ass4_20CS10063_20CS30057.tab.* ass4_20CS10063_20CS30057.output
