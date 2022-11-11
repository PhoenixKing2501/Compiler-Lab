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

libass2_20CS30057.a: ass2_20CS30057.o
	ar -rcs libass2_20CS30057.a ass2_20CS30057.o

ass2_20CS30057.o: ass2_20CS30057.c myl.h
	gcc -c -Wall -I. ass2_20CS30057.c

clean:
	-rm parser *.o *.s ass6_20CS10063_20CS30057.yy.* ass6_20CS10063_20CS30057.tab.* ass6_20CS10063_20CS30057.output *.a tinyC_out/*

test: parser libass2_20CS30057.a
	@echo "Generating assembly files"
	./parser ass6_20CS10063_20CS30057_test1 > quads/ass6_20CS10063_20CS30057_quads1.txt
	./parser ass6_20CS10063_20CS30057_test2 > quads/ass6_20CS10063_20CS30057_quads2.txt
	./parser ass6_20CS10063_20CS30057_test3 > quads/ass6_20CS10063_20CS30057_quads3.txt
	./parser ass6_20CS10063_20CS30057_test4 > quads/ass6_20CS10063_20CS30057_quads4.txt
	./parser ass6_20CS10063_20CS30057_test5 > quads/ass6_20CS10063_20CS30057_quads5.txt
	./parser ass6_20CS10063_20CS30057_test6 > quads/ass6_20CS10063_20CS30057_quads6.txt
	./parser ass6_20CS10063_20CS30057_test7 > quads/ass6_20CS10063_20CS30057_quads7.txt
	@echo "Compiling assembly files"
	gcc -Wall ass6_20CS10063_20CS30057_test1.s -L. -lass2_20CS30057 -no-pie -o tinyC_out/test1
	gcc -Wall ass6_20CS10063_20CS30057_test2.s -L. -lass2_20CS30057 -no-pie -o tinyC_out/test2
	gcc -Wall ass6_20CS10063_20CS30057_test3.s -L. -lass2_20CS30057 -no-pie -o tinyC_out/test3
	gcc -Wall ass6_20CS10063_20CS30057_test4.s -L. -lass2_20CS30057 -no-pie -o tinyC_out/test4
	gcc -Wall ass6_20CS10063_20CS30057_test5.s -L. -lass2_20CS30057 -no-pie -o tinyC_out/test5
	gcc -Wall ass6_20CS10063_20CS30057_test6.s -L. -lass2_20CS30057 -no-pie -o tinyC_out/test6
	gcc -Wall ass6_20CS10063_20CS30057_test7.s -L. -lass2_20CS30057 -no-pie -o tinyC_out/test7
	@echo "Binaries generated. Run using ./test<num>"
	@echo "Running test1:"
	@./tinyC_out/test1
	@echo "Running test2:"
	@./tinyC_out/test2
	@echo "Running test3:"
	@./tinyC_out/test3
	@echo "Running test4:"
	@./tinyC_out/test4
	@echo "Running test5:"
	@./tinyC_out/test5
	@echo "Running test6:"
	@./tinyC_out/test6
	@echo "Running test7:"
	@./tinyC_out/test7
