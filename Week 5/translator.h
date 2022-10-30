#pragma once

#ifndef _TRANSLATOR_H_
#define _TRANSLATOR_H_

#include <cstring>
#include <functional>
#include <iomanip>
#include <iostream>
#include <list>
#include <map>
#include <string>
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
	map<string, Symbol> symbols{};
	SymbolTable *parent{};

	SymbolTable(const string & = "NULL", SymbolTable * = nullptr);
	Symbol *lookup(const string &);
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
list<size_t> make_list(int);
list<size_t> merge_list(list<size_t> &first, list<size_t> second);

size_t next_instruction();
Symbol *gentemp(SymbolType::SymbolEnum, const string & = "");
void changeTable(SymbolTable *);

bool type_check(Symbol *&, Symbol *&);

extern vector<Quad *> quad_array;
extern SymbolTable *current_table, *global_table;
extern Symbol *current_symbol;
extern SymbolType::SymbolEnum current_type;
extern int table_count, temp_count;

#endif // _TRANSLATOR_H_
