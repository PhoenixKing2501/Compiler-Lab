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


