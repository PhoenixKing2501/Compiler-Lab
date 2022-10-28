#include "translator.h"

vector<Quad *> quad_array{};
SymbolTable *current_table{}, *global_table{};
Symbol *current_symbo{};
SymbolType::SymbolEnum current_type{};
int table_count{}, temp_count{};

SymbolType::SymbolType(SymbolEnum type, SymbolType *array_type, size_t width)
	: type(type), width(width), array_type(array_type) {}

size_t SymbolType::getSize()
{
	switch (this->type)
	{
	case SymbolEnum::INT:
	case SymbolEnum::PTR:
		return 4;
		break;

	case SymbolEnum::CHAR:
		return 1;
		break;

	case SymbolEnum::FLOAT:
		return 8;
		break;

	case SymbolEnum::ARRAY:
		return this->width * this->array_type->getSize();
		break;

	default:
		return 0;
		break;
	}
}

string SymbolType::toString()
{
	switch (this->type)
	{
	case SymbolEnum::VOID:
		return "void";
		break;

	case SymbolEnum::INT:
		return "int";
		break;

	case SymbolEnum::FLOAT:
		return "float";
		break;

	case SymbolEnum::CHAR:
		return "char";
		break;

	case SymbolEnum::PTR:
		return "ptr(" + this->array_type->toString() + ")";
		break;

	case SymbolEnum::FUNC:
		return "function";
		break;

	case SymbolEnum::ARRAY:
		return "array(" + to_string(this->width) + ", " + this->array_type->toString() + ")";
		break;

	case SymbolEnum::BLOCK:
		return "block";
		break;

	default:
		return "";
		break;
	}
}

SymbolTable::SymbolTable(string name, SymbolTable *parent)
	: name(name), parent(parent) {}

Symbol *SymbolTable::lookup(string name)
{
	if (this->symbols.contains(name))
	{
		return &this->symbols[name];
	}

	Symbol *ret_ptr = nullptr;

	if (this->parent)
	{
		ret_ptr = this->parent->lookup(name);
	}

	if (this == current_table && !ret_ptr)
	{
		this->symbols[name] = Symbol(name);
		return &this->symbols[name];
	}

	return ret_ptr;
}

void SymbolTable::update()
{
	vector<SymbolTable *> visited{}; // vector to keep track of children tables to visit
	size_t offset{};

	for (auto &&map_entry : this->symbols) // for all symbols in the table
	{
		if (map_entry.first == this->symbols.begin()->first) // if the symbol is the first one in the table then set offset of it to 0
		{
			map_entry.second.offset = 0;
			offset = map_entry.second.size;
		}
		else // else update the offset of the symbol and update the offset by adding the symbols width
		{
			map_entry.second.offset = offset;
			offset += map_entry.second.size;
		}

		if (map_entry.second.nested_table) // remember children table
		{
			visited.push_back(map_entry.second.nested_table);
		}
	}

	for (auto &&table : visited) // update children table
	{
		table->update();
	}
}
