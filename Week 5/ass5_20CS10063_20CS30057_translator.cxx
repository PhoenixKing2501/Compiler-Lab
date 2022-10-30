#include "ass5_20CS10063_20CS30057_translator.h"

vector<Quad *> quad_array{};
SymbolTable *current_table{}, *global_table{};
Symbol *current_symbol{};
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

SymbolTable::SymbolTable(const string &name, SymbolTable *parent)
	: name(name), parent(parent) {}

Symbol *SymbolTable::lookup(const string &name_)
{
	if (this->symbols.contains(name_))
	{
		return &this->symbols[name_];
	}

	Symbol *ret_ptr = nullptr;

	if (this->parent)
	{
		ret_ptr = this->parent->lookup(name_);
	}

	if (this == current_table && !ret_ptr)
	{
		this->symbols[name_] = Symbol(name_);
		return &this->symbols[name_];
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

void SymbolTable::print()
{
	cout << string(140, '*') << '\n';
	cout << "Table Name: `" << this->name << "`\t\t Parent Name: `" << (this->parent ? this->parent->name : "None") << "`\n";
	cout << string(140, '*') << '\n';

	cout << setw(20) << "Name"
		 << setw(40) << "Type"
		 << setw(20) << "Initial Value"
		 << setw(20) << "Size"
		 << setw(20) << "Offset"
		 << setw(20) << "Child"
		 << '\n';

	cout << setw(20) << "----"
		 << setw(40) << "----"
		 << setw(20) << "-------------"
		 << setw(20) << "------"
		 << setw(20) << "----"
		 << setw(20) << "-----"
		 << "\n\n";

	vector<SymbolTable *> tovisit{};

	for (auto &&map_entry : this->symbols)
	{
		cout << setw(20) << quoted(map_entry.first, '`')
			 << setw(40) << quoted(map_entry.second.is_function ? "function" : map_entry.second.type->toString(), '`')
			 << setw(20) << (map_entry.second.initial_value == "" or map_entry.second.initial_value.empty() ? "" : '`' + map_entry.second.initial_value + '`')
			 << setw(20) << quoted(to_string(map_entry.second.size), '`')
			 << setw(20) << quoted(to_string(map_entry.second.offset), '`')
			 << setw(20) << quoted(map_entry.second.nested_table ? map_entry.second.nested_table->name : "NULL", '`')
			 << '\n';

		if (map_entry.second.nested_table)
		{
			tovisit.push_back(map_entry.second.nested_table);
		}
	}

	cout << string(140, '*') << string(4, '\n');

	for (auto &&table : tovisit)
	{
		table->print();
	}
}

Symbol::Symbol(const string &name_, SymbolType::SymbolEnum type_, const string &init)
	: name(name_), offset(0), type(new SymbolType(type_)),
	  nested_table(nullptr), initial_value(init)
{
	this->size = this->type->getSize();
}

Symbol *Symbol::update(SymbolType *type_)
{
	this->type = type_;
	size = this->type->getSize();
	return this;
}

Symbol *Symbol::convert(SymbolType::SymbolEnum type_)
{
	// if the current type is float
	if (this->type->type == SymbolType::SymbolEnum::FLOAT)
	{
		// if the target type is int
		if (type_ == SymbolType::SymbolEnum::INT)
		{
			// generate symbol of new type
			Symbol *fin_ = gentemp(type_);
			emit("=", fin_->name, "Float_To_Int(" + this->name + ")");
			return fin_;
		}
		// if the target type is char
		else if (type_ == SymbolType::SymbolEnum::CHAR)
		{
			// generate symbol of new type
			Symbol *fin_ = gentemp(type_);
			emit("=", fin_->name, "Float_To_Char(" + this->name + ")");
			return fin_;
		}
		// reutrn orignal symbol if the final type is not int or
		// char
		return this;
	}
	// if current type is int
	else if (this->type->type == SymbolType::SymbolEnum::INT)
	{
		// if the target type is float
		if (type_ == SymbolType::SymbolEnum::FLOAT)
		{
			// generate symbol of new type
			Symbol *fin_ = gentemp(type_);
			emit("=", fin_->name, "Int_To_Float(" + this->name + ")");
			return fin_;
		}
		// if the target type is char
		else if (type_ == SymbolType::SymbolEnum::CHAR)
		{
			// generate symbol of new type
			Symbol *fin_ = gentemp(type_);
			emit("=", fin_->name, "Int_To_Char(" + this->name + ")");
			return fin_;
		}
		// return orignal symbol if the final type is not float or
		// char
		return this;
	}
	// if the current type is char
	else if (this->type->type == SymbolType::SymbolEnum::CHAR)
	{
		// if the target type is int
		if (type_ == SymbolType::SymbolEnum::INT)
		{
			// generate symbol of new type
			Symbol *fin_ = gentemp(type_);
			emit("=", fin_->name, "Char_To_Int(" + this->name + ")");
			return fin_;
		}
		// if the target type is float
		else if (type_ == SymbolType::SymbolEnum::FLOAT)
		{
			// generate symbol of new type
			Symbol *fin_ = gentemp(type_);
			emit("=", fin_->name, "Char_To_Float(" + this->name + ")");
			return fin_;
		}
		// return orignal symbol if the final type is not int or
		// float
		return this;
	}
	return this;
}

Quad::Quad(const string &op, const string &arg1, const string &arg2, const string &result)
	: op(op), arg1(arg1), arg2(arg2), result(result) {}
Quad::Quad(const string &op, int arg1, const string &arg2, const string &result)
	: op(op), arg1(to_string(arg1)), arg2(arg2), result(result) {}

void Quad::print()
{
	// if binary operations
	auto binary_print = [&]()
	{
		cout << "\t" << this->result
			 << " = " << this->arg1
			 << " " << this->op
			 << " " << this->arg2
			 << '\n';
	};

	// if relational operators
	auto relation_print = [&]()
	{
		cout << "\tif " << this->arg1
			 << " " << this->op
			 << " " << this->arg2
			 << " goto L" << this->result
			 << '\n';
	};

	// if shift operators
	auto shift_print = [&]()
	{
		cout << "\t" << this->result
			 << " " << this->op[0]
			 << " " << this->op[1]
			 << this->arg1
			 << '\n';
	};

	// if special type of operators
	auto shift_print_str = [&](const string &tp)
	{
		cout << "\t" << this->result
			 << " " << tp
			 << " " << this->arg1
			 << '\n';
	};

	/* we define the printing format for all operators */
	if (this->op == "=")
	{
		cout << "\t" << this->result
			 << " = " << this->arg1
			 << '\n';
	}
	else if (this->op == "goto")
	{
		cout << "\tgoto L" << this->result
			 << '\n';
	}
	else if (this->op == "return")
	{
		cout << "\treturn " << this->result
			 << '\n';
	}
	else if (this->op == "call")
	{
		cout << "\t" << this->result
			 << " = call " << this->arg1
			 << ", " << this->arg2
			 << '\n';
	}
	else if (this->op == "param")
	{
		cout << "\tparam " << this->result
			 << '\n';
	}
	else if (this->op == "label")
	{
		cout << this->result << '\n';
	}
	else if (this->op == "=[]")
	{
		cout << "\t" << this->result
			 << " = " << this->arg1
			 << "[" << this->arg2
			 << "]\n";
	}
	else if (this->op == "[]=")
	{
		cout << "\t" << this->result
			 << "[" << this->arg1
			 << "] = " << this->arg2
			 << '\n';
	}
	else if (this->op == "+" or
			 this->op == "-" or
			 this->op == "*" or
			 this->op == "/" or
			 this->op == "%" or
			 this->op == "|" or
			 this->op == "^" or
			 this->op == "&" or
			 this->op == "<<" or
			 this->op == ">>")
	{
		binary_print();
	}
	else if (this->op == "==" or
			 this->op == "!=" or
			 this->op == "<" or
			 this->op == ">" or
			 this->op == "<=" or
			 this->op == ">=")
	{
		relation_print();
	}
	else if (this->op == "=&" or
			 this->op == "=*")
	{
		shift_print();
	}
	else if (this->op == "*=")
	{
		cout << "\t"
			 << "*" << this->result
			 << " = " << this->arg1
			 << '\n';
	}
	else if (this->op == "minus")
	{
		shift_print_str("= minus");
	}
	else if (this->op == "~")
	{
		shift_print_str("= ~");
	}
	else if (this->op == "!")
	{
		shift_print_str("= !");
	}
	else
	{
		// if none of the above operators
		cout << this->op
			 << this->arg1
			 << this->arg2
			 << this->result
			 << '\n';

		cout << "INVALID OPERATOR\n ";
	}
}

void emit(const string &op, const string &result, const string &arg1, const string &arg2)
{
	quad_array.push_back(new Quad(op, arg1, arg2, result));
}
void emit(const string &op, const string &result, int arg1, const string &arg2)
{
	quad_array.push_back(new Quad(op, arg1, arg2, result));
}

void backpatch(const list<size_t> &list_, size_t addr)
{
	// for all the addresses in the list, add the target address
	for (auto &i : list_)
	{
		quad_array[i - 1]->result = to_string(addr);
	}
}

list<size_t> make_list(size_t base)
{
	// returns list with the base address as its only value
	return {base};
}

list<size_t> merge_list(list<size_t> &first, list<size_t> second)
{
	// merge two lists
	list<size_t> ret = move(first);
	ret.merge(second);
	return ret;
}

void Expression::to_int()
{
	// if the expression type is boolean
	if (this->type == Expression::ExprEnum::BOOL)
	{
		// generate symbol of new type and do backpatching and other required operations
		this->symbol = gentemp(SymbolType::SymbolEnum::INT);
		backpatch(this->true_list, (quad_array.size() + 1));  // update the true list
		emit("=", this->symbol->name, "true");				  // emit the quad
		emit("goto", to_string(quad_array.size() + 2));		  // emit the goto quad
		backpatch(this->false_list, (quad_array.size() + 1)); // update the false list
		emit("=", this->symbol->name, "false");
	}
}

void Expression::to_bool()
{
	// if the expression type is non boolean
	if (this->type == Expression::ExprEnum::NONBOOL)
	{
		// generate symbol of new type and do backpatching and other required operations
		this->false_list = make_list(quad_array.size() + 1); // update the false_list
		emit("==", "", this->symbol->name, "0");			 // emit general goto statements
		this->true_list = make_list(quad_array.size() + 1);	 // update the true_list
		emit("goto", "");
	}
}

size_t next_instruction()
{
	return quad_array.size() + 1;
}

Symbol *gentemp(SymbolType::SymbolEnum type, const string &s)
{
	string &&name = "t" + to_string(temp_count++);
	return &(current_table->symbols[name] = Symbol(name, type, s));
}

void change_table(SymbolTable *table)
{
	current_table = table;
}

bool type_check(Symbol *&a, Symbol *&b)
{
	// lambda function to check if a and b are of the same type
	function<bool(SymbolType *, SymbolType *)>
		type_comp = [&](SymbolType *first, SymbolType *second) -> bool
	{
		if (not first and not second)
		{
			return true;
		}
		else if (not first or
				 not second or
				 first->type != second->type)
		{
			return false;
		}
		else
		{
			return type_comp(first->array_type, second->array_type);
		}
	};
	// if the types are same return true
	if (type_comp(a->type, b->type))
		return true;
	// if the types are not same but can be cast safely according the rules, then cast and return
	else if (a->type->type == SymbolType::SymbolEnum::FLOAT or
			 b->type->type == SymbolType::SymbolEnum::FLOAT)
	{
		a = a->convert(SymbolType::SymbolEnum::FLOAT);
		b = b->convert(SymbolType::SymbolEnum::FLOAT);
		return true;
	}
	else if (a->type->type == SymbolType::SymbolEnum::INT or
			 b->type->type == SymbolType::SymbolEnum::INT)
	{
		a = a->convert(SymbolType::SymbolEnum::INT);
		b = b->convert(SymbolType::SymbolEnum::INT);
		return true;
	}
	// return false if not possible to cast safelt to same type
	else
	{
		return false;
	}
}

int main()
{
	// initialization of global variables
	table_count = 0;
	temp_count = 0;
	global_table = new SymbolTable("global");
	current_table = global_table;
	cout << left; // left allign

	yyparse();

	list<size_t> l1, l2;
	l2 = merge_list(l1, make_list(next_instruction()));

	global_table->update();
	global_table->print();
	int ins{};

	for (auto &&it : quad_array)
	{
		cout << setw(6) << "L" + to_string(++ins) << ":\t";
		it->print();
	}
}
