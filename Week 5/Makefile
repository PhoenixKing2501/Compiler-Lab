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
	rm parser ass5_20CS10063_20CS30057_translator.o ass5_20CS10063_20CS30057.yy.* ass5_20CS10063_20CS30057.tab.* ass5_20CS10063_20CS30057put output/*

test: parser
	@echo "Running test 1 (Arithmetic, shift, and bit expressions)"
	./parser < test/ass5_20CS10063_20CS30057_test1.c > output/ass5_20CS10063_20CS30057_quads1.txt
	@echo "Test 1 complete"

	@echo "Running test 2 (Unary expressions and operators)"
	./parser < test/ass5_20CS10063_20CS30057_test2.c > output/ass5_20CS10063_20CS30057_quads2.txt
	@echo "Test 2 complete"

	@echo "Running test 3 (Relational and boolean operators with if-else blocks)"
	./parser < test/ass5_20CS10063_20CS30057_test3.c > output/ass5_20CS10063_20CS30057_quads3.txt
	@echo "Test 3 complete"

	@echo "Running test 4 (Arrays and pointers)"
	./parser < test/ass5_20CS10063_20CS30057_test4.c > output/ass5_20CS10063_20CS30057_quads4.txt
	@echo "Test 4 complete"

	@echo "Running test 5 (Declarations and assignments)"
	./parser < test/ass5_20CS10063_20CS30057_test5.c > output/ass5_20CS10063_20CS30057_quads5.txt
	@echo "Test 5 complete"

	@echo "Running test 6 (Loops)"
	./parser < test/ass5_20CS10063_20CS30057_test6.c > output/ass5_20CS10063_20CS30057_quads6.txt
	@echo "Test 6 complete"

	@echo "Running test 7 (Function calls)"
	./parser < test/ass5_20CS10063_20CS30057_test7.c > output/ass5_20CS10063_20CS30057_quads7.txt
	@echo "Test 7 complete"

	@echo "Running test 8 (General file)"
	./parser < test/ass5_20CS10063_20CS30057_test8.c > output/ass5_20CS10063_20CS30057_quads8.txt
	@echo "Test 8 complete"
