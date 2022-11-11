#include "ass6_20CS10063_20CS30057_translator.h"

string input_name, assembly_name;
ActivationRecord *current_AR; // points to the activation record of the current function
ofstream assembly_file;		  // assembly file

unordered_map<int, string>
	ret_size_reg_map{
		{1, "al"},
		{4, "eax"},
		{8, "rax"},
	},
	arg1_size_reg_map{
		{1, "dil"},
		{4, "edi"},
		{8, "rdi"},
	},
	arg2_size_reg_map{
		{1, "sil"},
		{4, "esi"},
		{8, "rsi"},
	},
	arg3_size_reg_map{
		{1, "dl"},
		{4, "edx"},
		{8, "rdx"},
	},
	arg4_size_reg_map{
		{1, "cl"},
		{4, "ecx"},
		{8, "rcx"},
	};
unordered_map<int, unordered_map<int, string>> arg_reg_map{
	{1, arg1_size_reg_map},
	{2, arg2_size_reg_map},
	{3, arg3_size_reg_map},
	{4, arg4_size_reg_map},
};

unordered_map<char, int> escape_char_ascii{
	{'n', 10},
	{'t', 9},
	{'r', 13},
	{'b', 8},
	{'f', 12},
	{'v', 11},
	{'a', 7},
	{'0', 0},
};

int32_t get_ascii_value(const string &str)
{
	if (str.length() == 3)
	{
		return static_cast<int32_t>(str[1]);
	}
	else if (escape_char_ascii.contains(str[2]))
	{
		return escape_char_ascii[str[2]];
	}
	else
	{
		return static_cast<int32_t>(str[2]);
	}
}

string get_reg(const string &param_name, int param_num, size_t sz)
{
	string reg = arg_reg_map[param_num][sz];
	return "%" + reg;
}

string get_stack(const string &param_name)
{
	if (current_AR->displacement.count(param_name))
	{
		return to_string(current_AR->displacement[param_name]) + "(%rbp)";
	}
	else
	{
		return param_name;
	}
}

void load_param(string param_name, int param_num)
{
	Symbol *symbol = current_table->lookup(param_name);
	size_t sz = symbol->size;
	SymbolType::SymbolEnum type = symbol->type->type;
	string &&movIns = "";
	// if it is an array just store_param the address
	if (type == SymbolType::SymbolEnum::ARRAY)
	{
		movIns = "movq";
		sz = 8;
	}
	else if (sz == 1)
	{
		movIns = "movb";
	}
	else if (sz == 4)
	{
		movIns = "movl";
	}
	else if (sz == 8)
	{
		movIns = "movq";
	}
	assembly_file << "\t"
				  << setw(8) << movIns
				  << get_reg(param_name, param_num, sz) << ", "
				  << get_stack(param_name) << '\n';
}

void store_param(string param_name, int param_num)
{
	Symbol *symbol = current_table->lookup(param_name);
	int size = symbol->size;
	SymbolType::SymbolEnum type = symbol->type->type;
	string &&movIns = "";
	// if it is an array just store_param the address
	if (type == SymbolType::SymbolEnum::ARRAY)
	{
		movIns = "leaq";
		size = 8;
	}
	else if (size == 1)
	{
		movIns = "movb";
	}
	else if (size == 4)
	{
		movIns = "movl";
	}
	else if (size == 8)
	{
		movIns = "movq";
	}
	string reg = get_reg(param_name, param_num, size);
	assembly_file << "\t" << setw(8) << movIns << get_stack(param_name) << ", " << reg << '\n';
}

void translate()
{
	assembly_file.open(assembly_name);

	assembly_file << left;
	assembly_file << "\t.file\t\"" + input_name + "\"" << '\n';

	assembly_file << '\n';
	// activation records
	assembly_file << "#\t"
				  << "Allocation of function variables and temporaries on the stack:\n"
				  << '\n';

	for (auto &&symbol : global_table->symbols)
	{
		if (symbol.second.category == Symbol::SymbolCategory::FUNC)
		{
			assembly_file << "#\t" << symbol.second.name << '\n';
			for (auto &&record : symbol.second.nested_table->activation_record->displacement)
			{
				assembly_file << "#\t" << record.first << ": " << record.second << '\n';
			}
		}
	}
	assembly_file << '\n';

	// string literals in the rodata section
	if (stringLiterals.size() > 0)
	{
		assembly_file << "\t.section\t.rodata" << '\n';
		int i{};

		for (auto &&stringLiteral : stringLiterals)
		{
			assembly_file << ".LC" << i++ << ":" << '\n';
			assembly_file << "\t.string\t" << stringLiteral << '\n';
		}
	}

	// global variables (uninitialised)
	for (auto &&symbol : global_table->symbols)
	{
		if (symbol.second.initial_value.empty() and symbol.second.category == Symbol::SymbolCategory::GLOBAL)
		{
			assembly_file << "\t.comm\t"
						  << symbol.first << ","
						  << symbol.second.size << ","
						  << symbol.second.size << '\n';
		}
	}

	// convert tac labels to assembly labels
	unordered_map<int, string> label_map;
	int quad_num = 1, label_num = 0;
	for (auto &&quad : quad_array)
	{
		if (quad->op == "label")
		{
			label_map[quad_num] = ".LFB" + to_string(label_num);
		}
		else if (quad->op == "labelend")
		{
			label_map[quad_num] = ".LFE" + to_string(label_num);
			++label_num;
		}
		++quad_num;
	}
	for (auto &&quad : quad_array)
	{
		if (quad->op == "goto" or
			quad->op == "==" or
			quad->op == "!=" or
			quad->op == "<" or
			quad->op == ">" or
			quad->op == "<=" or
			quad->op == ">=")
		{
			int loc = stoi(quad->result);
			if (not label_map.contains(loc))
			{
				label_map[loc] = ".L" + to_string(label_num);
				++label_num;
			}
		}
	}

	bool in_text_space = false; // whether we are currently inside a function body or in the global space
	string global_string_temp{};
	int global_int_temp{}, global_char_temp{}; // for char simply hold the ascii value
	string func_end_label{};
	stack<string> params{}; // stack to store_param the params for function calls, especially helpful for nested function calls
							// of the type fun1(fun2(arg1, arg2), fun3(arg3, arg4))
	quad_num = 1;
	for (auto &quad : quad_array)
	{

		if (quad->op == "label")
		{
			if (not in_text_space)
			{
				assembly_file << "\t.text" << '\n';
				in_text_space = true;
			}

			current_table = global_table->lookup(quad->result)->nested_table;
			current_AR = current_table->activation_record;

			func_end_label = label_map[quad_num];
			func_end_label[3] = 'E';

			// function prologue
			assembly_file << "\t" << setw(8) << ".globl" << quad->result << '\n';
			assembly_file << "\t" << setw(8) << ".type" << quad->result << ", @function" << '\n';
			assembly_file << quad->result << ":" << '\n';
			assembly_file << label_map[quad_num] << ":" << '\n';
			assembly_file << "\t"
						  << ".cfi_startproc" << '\n';
			assembly_file << "\t" << setw(8) << "pushq"
						  << "%rbp" << '\n';
			assembly_file << "\t.cfi_def_cfa_offset 16" << '\n';
			assembly_file << "\t.cfi_offset 6, -16" << '\n';
			assembly_file << "\t" << setw(8) << "movq"
						  << "%rsp, %rbp" << '\n';
			assembly_file << "\t.cfi_def_cfa_register 6" << '\n';
			assembly_file << "\t" << setw(8) << "subq"
						  << "$" << -current_AR->total_displacement << ", %rsp" << '\n';

			int paramNum = 1;
			for (auto param : current_table->parameters)
			{
				load_param(param, paramNum);
				paramNum++;
			}
		}
		else if (quad->op == "labelend")
		{
			// function epilogue
			assembly_file << label_map[quad_num] << ":" << '\n';
			assembly_file << "\t" << setw(8) << "movq"
						  << "%rbp, %rsp" << '\n';
			assembly_file << "\t" << setw(8) << "popq"
						  << "%rbp" << '\n';
			assembly_file << "\t"
						  << ".cfi_def_cfa 7, 8" << '\n';
			assembly_file << "\t"
						  << "ret" << '\n';
			assembly_file << "\t"
						  << ".cfi_endproc" << '\n';
			assembly_file << "\t" << setw(8) << ".size" << quad->result << ", .-" << quad->result << '\n';

			in_text_space = false;
		}
		else
		{
			if (in_text_space)
			{
				// process the function instructions
				string op = quad->op;
				string result = quad->result;
				string arg1 = quad->arg1;
				string arg2 = quad->arg2;

				if (label_map.count(quad_num))
				{
					assembly_file << label_map[quad_num] << ":" << '\n';
				}

				if (op == "=")
				{
					// first check if arg1 is a constant
					if (isdigit(arg1[0]))
					{
						// integer constant
						assembly_file << "\t" << setw(8) << "movl"
									  << "$" << arg1 << ", " << get_stack(result) << '\n';
					}
					else if (arg1[0] == '\'')
					{
						// character constant
						assembly_file << "\t" << setw(8) << "movb"
									  << "$" << get_ascii_value(arg1) << ", " << get_stack(result) << '\n';
					}
					else
					{
						// variable
						// check the size of arg1 in the current table and apply the corresponding move from arg1 to result via the appropriate register
						int sz = current_table->lookup(arg1)->size;
						if (sz == 1)
						{
							assembly_file << "\t" << setw(8) << "movb" << get_stack(arg1) << ", %al" << '\n';
							assembly_file << "\t" << setw(8) << "movb"
										  << "%al, " << get_stack(result) << '\n';
						}
						else if (sz == 4)
						{
							assembly_file << "\t" << setw(8) << "movl" << get_stack(arg1) << ", %eax" << '\n';
							assembly_file << "\t" << setw(8) << "movl"
										  << "%eax, " << get_stack(result) << '\n';
						}
						else if (sz == 8)
						{
							assembly_file << "\t" << setw(8) << "movq" << get_stack(arg1) << ", %rax" << '\n';
							assembly_file << "\t" << setw(8) << "movq"
										  << "%rax, " << get_stack(result) << '\n';
						}
					}
				}
				else if (op == "=str")
				{
					assembly_file << "\t" << setw(8) << "movq"
								  << "$.LC" << arg1 << ", " << get_stack(result) << '\n';
				}
				else if (op == "param")
				{
					params.push(result);
				}
				else if (op == "call")
				{
					// call function
					int param_cnt = stoi(arg2);
					while (param_cnt)
					{
						store_param(params.top(), param_cnt);
						params.pop();
						--param_cnt;
					}

					assembly_file << "\t" << setw(8) << "call" << arg1 << '\n';
					// check the size of result in the current table and apply the corresponding move from appropriate return register to result
					int sz = current_table->lookup(result)->size;
					if (sz == 1)
					{
						assembly_file << "\t" << setw(8) << "movb"
									  << "%al, " << get_stack(result) << '\n';
					}
					else if (sz == 4)
					{
						assembly_file << "\t" << setw(8) << "movl"
									  << "%eax, " << get_stack(result) << '\n';
					}
					else if (sz == 8)
					{
						assembly_file << "\t" << setw(8) << "movq"
									  << "%rax, " << get_stack(result) << '\n';
					}
				}
				else if (op == "return")
				{
					// return from function
					if (not result.empty())
					{
						// check the size of result in the current table and apply the corresponding move from result to return register
						int sz = current_table->lookup(result)->size;
						if (sz == 1)
						{
							assembly_file << "\t"
										  << setw(8) << "movb"
										  << get_stack(result) << ", %al"
										  << '\n';
						}
						else if (sz == 4)
						{
							assembly_file << "\t"
										  << setw(8) << "movl"
										  << get_stack(result) << ", %eax"
										  << '\n';
						}
						else if (sz == 8)
						{
							assembly_file << "\t"
										  << setw(8) << "movq"
										  << get_stack(result) << ", %rax"
										  << '\n';
						}
					}
					if (quad_array[quad_num]->op != "labelend") // if the next quad is not a labelend, then we need to jump to the function end
						assembly_file << "\t"
									  << setw(8) << "jmp"
									  << func_end_label
									  << '\n';
				}
				else if (op == "goto")
				{
					// unconditional jump
					assembly_file << "\t"
								  << setw(8) << "jmp"
								  << label_map[stoi(result)]
								  << '\n';
				}
				else if (op == "==" or
						 op == "!=" or
						 op == "<" or
						 op == "<=" or
						 op == ">" or
						 op == ">=")
				{
					// check if arg1 == arg2
					int sz = current_table->lookup(arg1)->size;
					string movins{}, cmpins{}, movreg{};
					if (sz == 1)
					{
						movins = "movb";
						cmpins = "cmpb";
						movreg = "%al";
					}
					else if (sz == 4)
					{
						movins = "movl";
						cmpins = "cmpl";
						movreg = "%eax";
					}
					else if (sz == 8)
					{
						movins = "movq";
						cmpins = "cmpq";
						movreg = "%rax";
					}
					assembly_file << "\t" << setw(8) << movins << get_stack(arg2) << ", " << movreg << '\n';
					assembly_file << "\t" << setw(8) << cmpins << movreg << ", " << get_stack(arg1) << '\n';
					if (op == "==")
					{
						assembly_file << "\t" << setw(8) << "je" << label_map[stoi(result)] << '\n';
					}
					else if (op == "!=")
					{
						assembly_file << "\t" << setw(8) << "jne" << label_map[stoi(result)] << '\n';
					}
					else if (op == "<")
					{
						assembly_file << "\t" << setw(8) << "jl" << label_map[stoi(result)] << '\n';
					}
					else if (op == "<=")
					{
						assembly_file << "\t" << setw(8) << "jle" << label_map[stoi(result)] << '\n';
					}
					else if (op == ">")
					{
						assembly_file << "\t" << setw(8) << "jg" << label_map[stoi(result)] << '\n';
					}
					else if (op == ">=")
					{
						assembly_file << "\t" << setw(8) << "jge" << label_map[stoi(result)] << '\n';
					}
				}
				else if (op == "+")
				{
					// result = arg1 + arg2
					if (result == arg1)
					{
						// increment arg1
						assembly_file << "\t" << setw(8) << "incl" << get_stack(arg1) << '\n';
					}
					else
					{
						assembly_file << "\t" << setw(8) << "movl" << get_stack(arg1) << ", "
									  << "%eax" << '\n';
						assembly_file << "\t" << setw(8) << "addl" << get_stack(arg2) << ", "
									  << "%eax" << '\n';
						assembly_file << "\t" << setw(8) << "movl"
									  << "%eax"
									  << ", " << get_stack(result) << '\n';
					}
				}
				else if (op == "-")
				{
					// result = arg1 - arg2
					if (result == arg1)
					{
						// decrement arg1
						assembly_file << "\t" << setw(8) << "decl" << get_stack(arg1) << '\n';
					}
					else
					{
						assembly_file << "\t" << setw(8) << "movl" << get_stack(arg1) << ", "
									  << "%eax" << '\n';
						assembly_file << "\t" << setw(8) << "subl" << get_stack(arg2) << ", "
									  << "%eax" << '\n';
						assembly_file << "\t" << setw(8) << "movl"
									  << "%eax"
									  << ", " << get_stack(result) << '\n';
					}
				}
				else if (op == "*")
				{
					// result = arg1 * arg2
					assembly_file << "\t" << setw(8) << "movl" << get_stack(arg1) << ", "
								  << "%eax" << '\n';
					if (isdigit(arg2[0]))
					{
						assembly_file << "\t" << setw(8) << "imull"
									  << "$" + get_stack(arg2) << ", "
									  << "%eax" << '\n';
					}
					else
					{
						assembly_file << "\t" << setw(8) << "imull" << get_stack(arg2) << ", "
									  << "%eax" << '\n';
					}
					assembly_file << "\t" << setw(8) << "movl"
								  << "%eax"
								  << ", " << get_stack(result) << '\n';
				}
				else if (op == "/")
				{
					// result = arg1  / arg2
					assembly_file << "\t" << setw(8) << "movl" << get_stack(arg1) << ", "
								  << "%eax" << '\n';
					assembly_file << "\t" << setw(8) << "cdq" << '\n';
					assembly_file << "\t" << setw(8) << "idivl" << get_stack(arg2) << '\n';
					assembly_file << "\t" << setw(8) << "movl"
								  << "%eax"
								  << ", " << get_stack(result) << '\n';
				}
				else if (op == "%")
				{
					// result = arg1 % arg2
					assembly_file << "\t" << setw(8) << "movl" << get_stack(arg1) << ", "
								  << "%eax" << '\n';
					assembly_file << "\t" << setw(8) << "cdq" << '\n';
					assembly_file << "\t" << setw(8) << "idivl" << get_stack(arg2) << '\n';
					assembly_file << "\t" << setw(8) << "movl"
								  << "%edx"
								  << ", " << get_stack(result) << '\n';
				}
				else if (op == "=[]")
				{
					// result = arg1[arg2]
					Symbol *symbol = current_table->lookup(arg1);
					if (symbol->category == Symbol::SymbolCategory::PARAM)
					{
						assembly_file << "\t" << setw(8) << "movl" << get_stack(arg2) << ", "
									  << "%eax" << '\n';
						assembly_file << "\t" << setw(8) << "cltq" << '\n';
						assembly_file << "\t" << setw(8) << "addq" << get_stack(arg1) << ", "
									  << "%rax" << '\n';
						assembly_file << "\t" << setw(8) << "movl"
									  << "(%rax)"
									  << ", "
									  << "%eax" << '\n';
						assembly_file << "\t" << setw(8) << "movl"
									  << "%eax"
									  << ", " << get_stack(result) << '\n';
					}
					else
					{
						assembly_file << "\t" << setw(8) << "movl" << get_stack(arg2) << ", "
									  << "%eax" << '\n';
						assembly_file << "\t" << setw(8) << "cltq" << '\n';
						assembly_file << "\t" << setw(8) << "movl" << current_AR->displacement[arg1] << "(%rbp, %rax, 1)"
									  << ", "
									  << "%eax" << '\n';
						assembly_file << "\t" << setw(8) << "movl"
									  << "%eax"
									  << ", " << get_stack(result) << '\n';
					}
				}
				else if (op == "[]=")
				{
					// result[arg1] = arg2
					Symbol *symbol = current_table->lookup(result);
					if (symbol->category == Symbol::SymbolCategory::PARAM)
					{
						assembly_file << "\t" << setw(8) << "movl" << get_stack(arg1) << ", "
									  << "%eax" << '\n';
						assembly_file << "\t" << setw(8) << "cltq" << '\n';
						assembly_file << "\t" << setw(8) << "addq" << get_stack(result) << ", "
									  << "%rax" << '\n';
						assembly_file << "\t" << setw(8) << "movl" << get_stack(arg2) << ", "
									  << "%ebx" << '\n';
						assembly_file << "\t" << setw(8) << "movl"
									  << "%ebx"
									  << ", "
									  << "(%rax)" << '\n';
					}
					else
					{
						assembly_file << "\t" << setw(8) << "movl" << get_stack(arg1) << ", "
									  << "%eax" << '\n';
						assembly_file << "\t" << setw(8) << "cltq" << '\n';
						assembly_file << "\t" << setw(8) << "movl" << get_stack(arg2) << ", "
									  << "%ebx" << '\n';
						assembly_file << "\t" << setw(8) << "movl"
									  << "%ebx"
									  << ", " << current_AR->displacement[result] << "(%rbp, %rax, 1)" << '\n';
					}
				}
				else if (op == "=&")
				{
					// result = &arg1
					assembly_file << "\t" << setw(8) << "leaq" << get_stack(arg1) << ", "
								  << "%rax" << '\n';
					assembly_file << "\t" << setw(8) << "movq"
								  << "%rax"
								  << ", " << get_stack(result) << '\n';
				}
				else if (op == "=*")
				{
					// result = *arg1
					assembly_file << "\t" << setw(8) << "movq" << get_stack(arg1) << ", "
								  << "%rax" << '\n';
					assembly_file << "\t" << setw(8) << "movl"
								  << "(%rax)"
								  << ", "
								  << "%eax" << '\n';
					assembly_file << "\t" << setw(8) << "movl"
								  << "%eax"
								  << ", " << get_stack(result) << '\n';
				}
				else if (op == "minus")
				{
					// result = -arg1
					assembly_file << "\t" << setw(8) << "movl" << get_stack(arg1) << ", "
								  << "%eax" << '\n';
					assembly_file << "\t" << setw(8) << "negl"
								  << "%eax" << '\n';
					assembly_file << "\t" << setw(8) << "movl"
								  << "%eax"
								  << ", " << get_stack(result) << '\n';
				}
				else if (op == "*=")
				{
					// *result = arg1
					assembly_file << "\t" << setw(8) << "movl" << get_stack(arg1) << ", "
								  << "%eax" << '\n';
					assembly_file << "\t" << setw(8) << "movq" << get_stack(result) << ", "
								  << "%rbx" << '\n';
					assembly_file << "\t" << setw(8) << "movl"
								  << "%eax"
								  << ", "
								  << "(%rbx)" << '\n';
				}
			}
			else
			{
				// process the global assignments
				current_symbol = global_table->lookup(quad->result);

				// first store_param the assignment value, this removes the need of temporaries, sort of a peep hole optimisation
				if (current_symbol->category == Symbol::SymbolCategory::TEMP)
				{
					if (current_symbol->type->type == SymbolType::SymbolEnum::INT)
					{
						global_int_temp = stoi(quad->arg1);
					}
					else if (current_symbol->type->type == SymbolType::SymbolEnum::CHAR)
					{
						global_char_temp = get_ascii_value(quad->arg1);
					}
					else if (current_symbol->type->type == SymbolType::SymbolEnum::PTR)
					{
						global_string_temp = ".LC" + quad->arg1;
					}
				}
				else
				{
					if (current_symbol->type->type == SymbolType::SymbolEnum::INT)
					{
						assembly_file << "\t" << setw(8) << ".globl" << current_symbol->name << '\n';
						assembly_file << "\t" << setw(8) << ".data" << '\n';
						assembly_file << "\t" << setw(8) << ".align" << 4 << '\n';
						assembly_file << "\t" << setw(8) << ".type" << current_symbol->name << ", @object" << '\n';
						assembly_file << "\t" << setw(8) << ".size" << current_symbol->name << ", 4" << '\n';
						assembly_file << current_symbol->name << ":" << '\n';
						assembly_file << "\t" << setw(8) << ".long" << global_int_temp << '\n';
					}
					else if (current_symbol->type->type == SymbolType::SymbolEnum::CHAR)
					{
						assembly_file << "\t" << setw(8) << ".globl" << current_symbol->name << '\n';
						assembly_file << "\t" << setw(8) << ".data" << '\n';
						assembly_file << "\t" << setw(8) << ".type" << current_symbol->name << ", @object" << '\n';
						assembly_file << "\t" << setw(8) << ".size" << current_symbol->name << ", 1" << '\n';
						assembly_file << current_symbol->name << ":" << '\n';
						assembly_file << "\t" << setw(8) << ".byte" << global_char_temp << '\n';
					}
					else if (current_symbol->type->type == SymbolType::SymbolEnum::PTR)
					{
						assembly_file << "\t"
									  << ".section	.data.rel.local" << '\n';
						assembly_file << "\t" << setw(8) << ".align" << 8 << '\n';
						assembly_file << "\t" << setw(8) << ".type" << current_symbol->name << ", @object" << '\n';
						assembly_file << "\t" << setw(8) << ".size" << current_symbol->name << ", 8" << '\n';
						assembly_file << current_symbol->name << ":" << '\n';
						assembly_file << "\t" << setw(8) << ".quad" << global_string_temp << '\n';
					}
				}
			}
		}

		quad_num++;
	}

	assembly_file.close();
}

int main(int argc, char const *argv[])
{
	input_name = "./test/" + string(argv[1]) + ".c";
	assembly_name = "./asms/" + string(argv[1]) + ".s";

	table_count = 0;
	temp_count = 0;
	global_table = new SymbolTable("global");
	current_table = global_table;
	cout << left; // left allign

	yyin = fopen(input_name.c_str(), "r");
	yyparse();

	global_table->update();
	final_backpatch();
	global_table->print();
	int ins{};

	for (auto &&it : quad_array)
	{
		cout << setw(6) << "L" + to_string(++ins) << ":\t";
		it->print();
	}

	translate();
}
