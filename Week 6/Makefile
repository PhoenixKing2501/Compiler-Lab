parser: ass6_20CS10063_20CS30057.yy.o ass6_20CS10063_20CS30057.tab.o ass6_20CS10063_20CS30057_translator.o ass6_20CS10063_20CS30057_target_translator.o
	g++ -Wall -I. -std=c++20 ass6_20CS10063_20CS30057.yy.o ass6_20CS10063_20CS30057.tab.o ass6_20CS10063_20CS30057_translator.o ass6_20CS10063_20CS30057_target_translator.o -o parser

ass6_20CS10063_20CS30057_target_translator.o: ass6_20CS10063_20CS30057_target_translator.cxx ass6_20CS10063_20CS30057_translator.h
	g++ -c -Wall -I. -std=c++20 ass6_20CS10063_20CS30057_target_translator.cxx

ass6_20CS10063_20CS30057_translator.o: ass6_20CS10063_20CS30057_translator.cxx ass6_20CS10063_20CS30057_translator.h
	g++ -c -Wall -I. -std=c++20 ass6_20CS10063_20CS30057_translator.cxx

ass6_20CS10063_20CS30057.yy.o: ass6_20CS10063_20CS30057.yy.c ass6_20CS10063_20CS30057_translator.h
	g++ -c -Wall -I. -std=c++20 ass6_20CS10063_20CS30057.yy.c

ass6_20CS10063_20CS30057.tab.o: ass6_20CS10063_20CS30057.tab.c ass6_20CS10063_20CS30057_translator.h
	g++ -c -Wall -I. -std=c++20 ass6_20CS10063_20CS30057.tab.c

ass6_20CS10063_20CS30057.yy.c: ass6_20CS10063_20CS30057.l ass6_20CS10063_20CS30057.tab.h
	flex --outfile=ass6_20CS10063_20CS30057.yy.c ass6_20CS10063_20CS30057.l

ass6_20CS10063_20CS30057.tab.c ass6_20CS10063_20CS30057.tab.h: ass6_20CS10063_20CS30057.y
	bison -d --debug --report=all ass6_20CS10063_20CS30057.y

libiolib.a: ass2_20CS30057.o
	ar -rcs libiolib.a ass2_20CS30057.o

ass2_20CS30057.o: ass2_20CS30057.c myl.h
	g++ -c -Wall -I. ass2_20CS30057.c

clean:
	rm parser ass6_20CS10063_20CS30057_*.o ass6_20CS10063_20CS30057.yy.* ass6_20CS10063_20CS30057.tab.* ass6_20CS10063_20CS30057.output *.a

test: parser libiolib.a
	@echo "hello"
