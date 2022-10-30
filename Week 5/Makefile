parser: ass5_20CS10063_20CS30057.yy.o ass5_20CS10063_20CS30057.tab.o ass5_20CS10063_20CS30057_translator.o
	g++ -Wall -I. -std=c++20 ass5_20CS10063_20CS30057.yy.o ass5_20CS10063_20CS30057.tab.o ass5_20CS10063_20CS30057_translator.o -o parser

ass5_20CS10063_20CS30057_translator.o: ass5_20CS10063_20CS30057_translator.cxx ass5_20CS10063_20CS30057_translator.h
	g++ -c -Wall -I. -std=c++20 ass5_20CS10063_20CS30057_translator.cxx

ass5_20CS10063_20CS30057.yy.o: ass5_20CS10063_20CS30057.yy.c ass5_20CS10063_20CS30057_translator.h
	g++ -c -Wall -I. -std=c++20 ass5_20CS10063_20CS30057.yy.c

ass5_20CS10063_20CS30057.tab.o: ass5_20CS10063_20CS30057.tab.c ass5_20CS10063_20CS30057_translator.h
	g++ -c -Wall -I. -std=c++20 ass5_20CS10063_20CS30057.tab.c

ass5_20CS10063_20CS30057.yy.c: ass5_20CS10063_20CS30057.l ass5_20CS10063_20CS30057.tab.h
	flex --outfile=ass5_20CS10063_20CS30057.yy.c ass5_20CS10063_20CS30057.l

ass5_20CS10063_20CS30057.tab.c ass5_20CS10063_20CS30057.tab.h: ass5_20CS10063_20CS30057.y
	bison -d --debug --report=all ass5_20CS10063_20CS30057.y

clean:
	rm parser ass5_20CS10063_20CS30057_translator.o ass5_20CS10063_20CS30057.yy.* ass5_20CS10063_20CS30057.tab.* ass5_20CS10063_20CS30057.output
