#pragma once

#ifndef _TRANSLATOR_H_
#define _TRANSLATOR_H_

#include <cstring>
#include <functional>
#include <iomanip>
#include <iostream>
#include <list>
#include <string>
#include <unordered_map>
#include <vector>

using namespace std;

struct SymbolType;
struct SymbolTable;
struct Symbol;
struct Label;
struct Quad;
struct Expression;
struct Array;
struct Statement;

struct SymbolType
{
	enum struct SymbolEnum
	{
		VOID,
		INT,
		FLOAT,
		CHAR,
		PTR,
		FUNC,
		ARRAY,
		BLOCK,
	} type{};

	size_t width{};
	SymbolType *array_type{};

	SymbolType(SymbolEnum, SymbolType * = nullptr, size_t = 1);
	size_t getSize();
	string toString();
};

struct SymbolTable
{
	string name{};
	unordered_map<string, Symbol> symbols{};
	SymbolTable *parent{};

	SymbolTable(string = "NULL", SymbolTable * = nullptr);
	Symbol *lookup(string);
	void print();
	void update();
};

struct Symbol
{
	string name{};
	size_t size{}, offset{};
	SymbolType *type{};
	SymbolTable *nested_table{};
	string initialValue{};
	bool isFunction{};

	Symbol(string, SymbolType::SymbolEnum = SymbolType::SymbolEnum::INT, string = "");
	Symbol *update(SymbolType *);
	Symbol *convert(SymbolType::SymbolEnum);
};

struct Quad
{
	string op{}, arg1{}, arg2{}, result{};

	Quad(string, string, string = "=", string = "");
	Quad(string, int, string = "=", string = "");
	void print();
};

struct Expression
{
	Symbol *symbol{};

	enum struct ExprEnum
	{
		NONBOOL,
		BOOL,
	} type{};

	list<int> trueList{}, falseList{}, nextList{};

	void toInt();
	void toBool();
};

struct Array
{
	Symbol *temp{};

	enum struct ArrayEnum
	{
		OTHER,
		POINTER,
		ARRAY,
	} type{};

	Symbol *symbol{};
	SymbolType *subArrayType{};
};

struct Statement
{
	list<int> nextList{};
};

void emit(string, string, string = "", string = "");
void emit(string, string, int, string = "");

void backpatch(list<int>, int);
list<int> make_list(int);
list<int> merge_list(list<int>, list<int>);

int nextInstruction();
Symbol *gentemp(SymbolType::SymbolEnum, string = "");
void changeTable(SymbolTable *);

bool typeCheck(Symbol *&, Symbol *&);

extern vector<Quad *> quad_array{};
extern SymbolTable *current_table{}, *global_table{};
extern Symbol *current_symbo{};
extern SymbolType::SymbolEnum current_type{};
extern int table_count{}, temp_count{};

extern int yyparse();

#endif // _TRANSLATOR_H_
