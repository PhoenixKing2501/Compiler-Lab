ass4_20CS10063_20CS30057_output.txt: parser ass4_20CS10063_20CS30057_test.c
	./parser < ass4_20CS10063_20CS30057_test.c > ass4_20CS10063_20CS30057_output.txt

parser: ass4_20CS10063_20CS30057.yy.o ass4_20CS10063_20CS30057.tab.o ass4_20CS10063_20CS30057_main.o
	gcc -Wall ass4_20CS10063_20CS30057.yy.o ass4_20CS10063_20CS30057.tab.o ass4_20CS10063_20CS30057_main.o -o parser

ass4_20CS10063_20CS30057_main.o: ass4_20CS10063_20CS30057_main.c
	gcc -c -Wall ass4_20CS10063_20CS30057_main.c

ass4_20CS10063_20CS30057.yy.o: ass4_20CS10063_20CS30057.yy.c
	gcc -c -Wall ass4_20CS10063_20CS30057.yy.c

ass4_20CS10063_20CS30057.tab.o: ass4_20CS10063_20CS30057.tab.c
	gcc -c -Wall ass4_20CS10063_20CS30057.tab.c

ass4_20CS10063_20CS30057.yy.c: ass4_20CS10063_20CS30057.l ass4_20CS10063_20CS30057.tab.h
	flex --outfile=ass4_20CS10063_20CS30057.yy.c ass4_20CS10063_20CS30057.l

ass4_20CS10063_20CS30057.tab.c ass4_20CS10063_20CS30057.tab.h: ass4_20CS10063_20CS30057.y
	bison -d --debug --report=all ass4_20CS10063_20CS30057.y

clean:
	rm parser ass4_20CS10063_20CS30057_main.o ass4_20CS10063_20CS30057.yy.* ass4_20CS10063_20CS30057.tab.* ass4_20CS10063_20CS30057.output
