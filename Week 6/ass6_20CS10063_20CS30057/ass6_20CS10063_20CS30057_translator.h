#pragma once

#ifndef _TRANSLATOR_H_
#define _TRANSLATOR_H_

#include <cctype>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <functional>
#include <iomanip>
#include <iostream>
#include <list>
#include <map>
#include <ranges>
#include <stack>
#include <string>
#include <unordered_map>
#include <vector>

using namespace std;

struct ActivationRecord;
struct Array;
struct Expression;
struct Label;
struct Quad;
struct Statement;
struct Symbol;
struct SymbolTable;
struct SymbolType;

struct ActivationRecord
{
	int total_displacement{};
	map<string, int> displacement{};

	ActivationRecord();
};

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
	map<string, Symbol> symbols{};
	SymbolTable *parent{};
	ActivationRecord *activation_record{};
	vector<string> parameters{};

	SymbolTable(const string & = "NULL", SymbolTable * = nullptr);
	Symbol *lookup(const string &);
	void print();
	void update();
};

struct Symbol
{
	enum struct SymbolCategory
	{
		LOCAL,
		GLOBAL,
		PARAM,
		TEMP,
		FUNC
	} category{};

	string name{};
	size_t size{}, offset{};
	SymbolType *type{};
	SymbolTable *nested_table{};
	string initial_value{};

	// Symbol() = default;
	Symbol(const string & = "", SymbolType::SymbolEnum = SymbolType::SymbolEnum::INT, const string & = "");
	Symbol *update(SymbolType *);
	Symbol *convert(SymbolType::SymbolEnum);
};

struct Quad
{
	string op{}, arg1{}, arg2{}, result{};

	Quad(const string &, const string &, const string & = "=", const string & = "");
	Quad(const string &, int, const string & = "=", const string & = "");
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

	list<size_t> true_list{}, false_list{}, next_list{};

	void to_int();
	void to_bool();
};

struct Array
{
	enum struct ArrayEnum
	{
		OTHER,
		PTR,
		ARRAY,
	} type{};

	Symbol *symbol{}, *temp{};
	SymbolType *sub_array_type{};
};

struct Statement
{
	list<size_t> next_list{};
};

void emit(const string &, const string &, const string & = "", const string & = "");
void emit(const string &, const string &, int, const string & = "");

void backpatch(const list<size_t> &list_, size_t addr);
void final_backpatch();
list<size_t> make_list(size_t);
list<size_t> merge_list(list<size_t> &first, list<size_t> second);

size_t next_instruction();
Symbol *gentemp(SymbolType::SymbolEnum, const string & = "");
void change_table(SymbolTable *);

bool type_check(Symbol *&, Symbol *&);

extern vector<Quad *> quad_array;
extern SymbolTable *current_table, *global_table;
extern Symbol *current_symbol;
extern SymbolType::SymbolEnum current_type;
extern int table_count, temp_count;
extern vector<string> stringLiterals;
extern FILE *yyin;
extern char *yytext;
extern int yylineno;

int yyparse();
int yylex();

void yyerror(const string &);
void yyinfo(const string &);

#endif // _TRANSLATOR_H_
