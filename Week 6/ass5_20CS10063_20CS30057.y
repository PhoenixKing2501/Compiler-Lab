%{
	#include "ass5_20CS10063_20CS30057_translator.h"
%}

%union {
	int intVal;
	char floatVal[32];
	char identifierVal[1024];
	char charVal[1024];
	char stringVal[1024];
	char unaryOp[8];
	int instrNum;
	int paramCnt;
	Expression *expression;
	Statement *statement;
	Array *array;
	SymbolType *symbolType;
	Symbol *symbol;
}

%token AUTO
%token BREAK
%token CASE
%token KEY_CHAR
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE
%token ELSE
%token ENUM
%token EXTERN
%token KEY_FLOAT
%token FOR
%token GOTO
%token IF
%token INLINE
%token KEY_INT
%token LONG
%token REGISTER
%token RESTRICT
%token RETURN
%token SHORT
%token SIGNED
%token SIZEOF
%token STATIC
%token STRUCT
%token SWITCH
%token TYPEDEF
%token UNION
%token UNSIGNED
%token KEY_VOID
%token VOLATILE
%token WHILE
%token BOOL
%token COMPLEX
%token IMAGINARY

%token<symbol> IDENTIFIER
%token<intVal> INTEGER_CONSTANT
%token<floatVal> FLOATING_CONSTANT
%token<charVal> CHARACTER_CONSTANT
%token<stringVal> STRING_LITERAL

%token ELLIPSIS
%token LEFT_SHIFT_ASSIGNMENT
%token RIGHT_SHIFT_ASSIGNMENT
%token INCREMENT
%token DECREMENT
%token ARROW
%token LEFT_SHIFT
%token RIGHT_SHIFT
%token STAR_ASSIGNMENT
%token FRONT_SLASH_ASSIGNMENT
%token MODULO_ASSIGNMENT
%token PLUS_ASSIGNMENT
%token MINUS_ASSIGNMENT
%token LESS_THAN_EQUAL_TO
%token GREATER_THAN_EQUAL_TO
%token EQUAL_TO
%token LOGICAL_AND
%token LOGICAL_OR
%token NOT_EQUAL_TO
%token BITWISE_AND_ASSIGNMENT
%token BITWISE_OR_ASSIGNMENT
%token BITWISE_XOR_ASSIGNMENT
%token LEFT_SQUARE_BRACKET
%token RIGHT_SQUARE_BRACKET
%token FRONT_SLASH
%token QUESTION_MARK
%token ASSIGNMENT
%token COMMA
%token LEFT_PARENTHESES
%token LEFT_BRACE
%token RIGHT_BRACE
%token DOT
%token STAR
%token PLUS
%token MINUS
%token TILDE
%token EXCLAMATION
%token MODULO
%token LESS_THAN
%token GREATER_THAN
%token COLON
%token SEMI_COLON
%token HASH
%token RIGHT_PARENTHESES
%token BITWISE_AND
%token BITWISE_OR
%token BITWISE_XOR

%nonassoc RIGHT_PARENTHESES

%start translation_unit
%right THEN ELSE

// Store unary operator as character
%type<unaryOp> 
	unary_operator

// Store parameter count as integer
%type<paramCnt> 
	argument_expression_list 
	argument_expression_list_opt

// Expressions
%type<expression>
	expression
	primary_expression 
	multiplicative_expression
	additive_expression
	shift_expression
	relational_expression
	equality_expression
	AND_expression
	exclusive_OR_expression
	inclusive_OR_expression
	logical_AND_expression
	logical_OR_expression
	conditional_expression
	assignment_expression
	expression_statement
	expression_opt

// Arrays
%type<array> 
	postfix_expression
	unary_expression
	cast_expression

// Statements
%type <statement>  
	statement
	compound_statement
	selection_statement
	iteration_statement
	labeled_statement 
	jump_statement
	block_item
	block_item_list
	block_item_list_opt
	N

// Symbol Table
%type<symbolType>
	pointer

// Symbol
%type<symbol>
	initializer
	direct_declarator
	init_declarator
	declarator

// Instruction number for backpatching
%type <instrNum> 
	M


%%
/* Expressions */

primary_expression: 
	IDENTIFIER 
		{
			yyinfo("primary_expression ==> IDENTIFIER");
			$$ = new Expression{};
			$$->symbol = $1;
			$$->type = Expression::ExprEnum::NONBOOL;
		}
	| INTEGER_CONSTANT 
		{
			yyinfo("primary_expression ==> INTEGER_CONSTANT");
			$$ = new Expression{};
			$$->symbol = gentemp(SymbolType::SymbolEnum::INT, to_string($1));
			emit("=", $$->symbol->name, $1);
		}
	| FLOATING_CONSTANT 
		{
			yyinfo("primary_expression ==> FLOATING_CONSTANT");
			$$ = new Expression{};
			$$->symbol = gentemp(SymbolType::SymbolEnum::FLOAT, $1);
			emit("=", $$->symbol->name, $1);
		}
	| CHARACTER_CONSTANT 
		{
			yyinfo("primary_expression ==> CHARACTER_CONSTANT");
			$$ = new Expression{};
			$$->symbol = gentemp(SymbolType::SymbolEnum::CHAR, $1);
			emit("=", $$->symbol->name, $1);
		}
	| STRING_LITERAL 
		{
			yyinfo("primary_expression ==> STRING_LITERAL");
			$$ = new Expression{};
			$$->symbol = gentemp(SymbolType::SymbolEnum::PTR, $1);
			$$->symbol->type->array_type = new SymbolType(SymbolType::SymbolEnum::CHAR);

			emit("=str", $$->symbol->name, string_literals.size());
			string_literals.push_back($1);
		}
	| LEFT_PARENTHESES expression RIGHT_PARENTHESES
		{
			yyinfo("primary_expression ==> ( expression )");
			$$ = $2;
		}
	;

postfix_expression:
	primary_expression
		{
			yyinfo("postfix_expression ==> primary_expression");
			$$ = new Array{};
			$$->symbol = $1->symbol;
			$$->temp = $$->symbol;
			$$->sub_array_type = $1->symbol->type;
		}
	| postfix_expression LEFT_SQUARE_BRACKET expression RIGHT_SQUARE_BRACKET
		{
			yyinfo("postfix_expression ==> postfix_expression [ expression ]");

			$$ = new Array{};
			$$->symbol = $1->symbol;
			$$->sub_array_type = $1->sub_array_type->array_type;
			$$->temp = gentemp(SymbolType::SymbolEnum::INT);
			$$->type = Array::ArrayEnum::ARRAY;

			if ($1->type == Array::ArrayEnum::ARRAY)
			{
				Symbol *sym = gentemp(SymbolType::SymbolEnum::INT);
				emit("*", sym->name, $3->symbol->name, to_string($$->sub_array_type->getSize()));
				emit("+", $$->temp->name, $1->temp->name, sym->name);
			}
			else
			{
				emit("*", $$->temp->name, $3->symbol->name, to_string($$->sub_array_type->getSize()));
			}
		}
	| postfix_expression LEFT_PARENTHESES argument_expression_list_opt RIGHT_PARENTHESES
		{
			yyinfo("postfix_expression ==> postfix_expression ( argument_expression_list_opt )");

			$$ = new Array{};
			$$->symbol = gentemp($1->symbol->type->type);
			emit("call", $$->symbol->name, $1->symbol->name, to_string($3));
		}
	| postfix_expression DOT IDENTIFIER
		{ yyinfo("postfix_expression ==> postfix_expression . IDENTIFIER"); }
	| postfix_expression ARROW IDENTIFIER
		{ yyinfo("postfix_expression ==> postfix_expression -> IDENTIFIER"); }
	| postfix_expression INCREMENT
		{
			yyinfo("postfix_expression ==> postfix_expression ++");

			$$ = new Array{};
			$$->symbol = gentemp($1->symbol->type->type);
			emit("=", $$->symbol->name, $1->symbol->name);
			emit("+", $1->symbol->name, $1->symbol->name, "1"); 
		}
	| postfix_expression DECREMENT
		{
			yyinfo("postfix_expression ==> postfix_expression --");

			$$ = new Array{};
			$$->symbol = gentemp($1->symbol->type->type);
			emit("=", $$->symbol->name, $1->symbol->name);
			emit("-", $1->symbol->name, $1->symbol->name, "1"); 
		}
	| LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_BRACE initializer_list RIGHT_BRACE
		{ yyinfo("postfix_expression ==> ( type_name ) { initializer_list }"); }
	| LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_BRACE initializer_list COMMA RIGHT_BRACE
		{ yyinfo("postfix_expression ==> ( type_name ) { initializer_list , }"); }
	;

argument_expression_list_opt:
	argument_expression_list
		{
			yyinfo("argument_expression_list_opt ==> argument_expression_list");
			$$ = $1;
		}
	|
		{
			yyinfo("argument_expression_list_opt ==> epsilon");
			$$ = 0;
		}
	;

argument_expression_list:
	assignment_expression
		{
			yyinfo("argument_expression_list ==> assignment_expression");
			emit("param", $1->symbol->name);
			$$ = 1;
		}
	| argument_expression_list COMMA assignment_expression
		{
			yyinfo("argument_expression_list ==> argument_expression_list , assignment_expression");
			emit("param", $3->symbol->name);
			$$ = $1 + 1; 
		}
	;

unary_expression:
	postfix_expression
		{
			yyinfo("unary_expression ==> postfix_expression");
			$$ = $1;
		}
	| INCREMENT unary_expression
		{
			yyinfo("unary_expression ==> ++ unary_expression");
			$$ = $2;
			emit("+", $2->symbol->name, $2->symbol->name, "1");
		}
	| DECREMENT unary_expression
		{
			yyinfo("unary_expression ==> -- unary_expression");
			$$ = $2;
			emit("-", $2->symbol->name, $2->symbol->name, "1");
		}
	| unary_operator cast_expression
		{
			yyinfo("unary_expression ==> unary_operator cast_expression");

			if (strcmp($1, "&") == 0)
			{
				$$ = new Array{};
				$$->symbol = gentemp(SymbolType::SymbolEnum::PTR);
				$$->symbol->type->array_type = $2->symbol->type;

				emit("=&", $$->symbol->name, $2->symbol->name);
			}
			else if (strcmp($1, "*") == 0)
			{
				$$ = new Array{};
				$$->symbol = $2->symbol;
				$$->temp = gentemp($2->temp->type->array_type->type);
				$$->temp->type->array_type = $2->temp->type->array_type->array_type;
				$$->type = Array::ArrayEnum::PTR;

				emit("=*", $$->temp->name, $2->temp->name);
			}
			else if (strcmp($1, "+") == 0)
			{
				$$ = $2;
			}
			else
			{
				$$ = new Array{};
				$$->symbol = gentemp($2->symbol->type->type);
				emit($1, $$->symbol->name, $2->symbol->name);
			}
		}
	| SIZEOF unary_expression
		{ yyinfo("unary_expression ==> sizeof unary_expression"); }
	| SIZEOF LEFT_PARENTHESES type_name RIGHT_PARENTHESES
		{ yyinfo("unary_expression ==> sizeof ( type_name )"); }
	;

unary_operator:
	BITWISE_AND
		{
			yyinfo("unary_operator ==> &");
			strcpy($$, "&");
		}
	| STAR
		{
			yyinfo("unary_operator ==> *");
			strcpy($$, "*");
		}
	| PLUS
		{
			yyinfo("unary_operator ==> +");
			strcpy($$, "+");
		}
	| MINUS
		{
			yyinfo("unary_operator ==> -");
			strcpy($$, "minus");
		}
	| TILDE
		{
			yyinfo("unary_operator ==> ~");
			strcpy($$, "~");
		}
	| EXCLAMATION
		{
			yyinfo("unary_operator ==> !");
			strcpy($$, "+");
		}
	;

cast_expression:
	unary_expression
		{
			yyinfo("cast_expression ==> unary_expression");
			$$ = $1;
		}
	| LEFT_PARENTHESES type_name RIGHT_PARENTHESES cast_expression
		{
			yyinfo("cast_expression ==> ( type_name ) cast_expression");

			$$ = new Array{};
			$$->symbol = $4->symbol->convert(current_type);
		}
	;

/*
 * In this translation step, an array goes to an expression
 * 
 * We first extract the base type of the array, then obtain the value, by indexing if the type is array,
 * using the symbol name, the temporary is used to calculate the location and assign the newly generated temporary
 * 
 * If it is a pointer or normal array then equate the symbol
 * 
 * Once this is done apply the necessary operation (*, / or %) after proper type-checking
 * 
 * Follow the same procedure for additive and shift expressions, check types,
 * generate temporary and store the result of the operation in the newly generated temporary
 */

multiplicative_expression:
	cast_expression
		{
			yyinfo("multiplicative_expression ==> cast_expression");

			SymbolType *base_type = $1->symbol->type;
			while (base_type->array_type)
			{
				base_type = base_type->array_type;
			}

			$$ = new Expression{};
			if ($1->type == Array::ArrayEnum::ARRAY)
			{
				$$->symbol = gentemp(base_type->type);
				emit("=[]", $$->symbol->name, $1->symbol->name, $1->temp->name);
			}
			else if ($1->type == Array::ArrayEnum::PTR)
			{
				$$->symbol = $1->temp;
			}
			else
			{
				$$->symbol = $1->symbol;
			}
		}
	| multiplicative_expression STAR cast_expression
		{
			yyinfo("multiplicative_expression ==> multiplicative_expression * cast_expression");

			SymbolType *base_type = $3->symbol->type;
			while (base_type->array_type)
			{
				base_type = base_type->array_type;
			}

			Symbol *temp{};
			if ($3->type == Array::ArrayEnum::ARRAY)
			{
				temp = gentemp(base_type->type);
				emit("=[]", temp->name, $3->symbol->name, $3->temp->name);
			}
			else if ($3->type == Array::ArrayEnum::PTR)
			{
				temp = $3->temp;
			}
			else
			{
				temp = $3->symbol;
			}

			if (type_check($1->symbol, temp))
			{
				$$ = new Expression{};
				$$->symbol = gentemp($1->symbol->type->type);
				emit("*", $$->symbol->name, $1->symbol->name, temp->name);
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	| multiplicative_expression FRONT_SLASH cast_expression
		{
			yyinfo("multiplicative_expression ==> multiplicative_expression / cast_expression");

			SymbolType *base_type = $3->symbol->type;
			while (base_type->array_type)
			{
				base_type = base_type->array_type;
			}

			Symbol *temp;
			if ($3->type == Array::ArrayEnum::ARRAY)
			{
				temp = gentemp(base_type->type);
				emit("=[]", temp->name, $3->symbol->name, $3->temp->name);
			}
			else if ($3->type == Array::ArrayEnum::PTR)
			{
				temp = $3->temp;
			}
			else
			{
				temp = $3->symbol;
			}

			if (type_check($1->symbol, temp))
			{
				$$ = new Expression{};
				$$->symbol = gentemp($1->symbol->type->type);
				emit("/", $$->symbol->name, $1->symbol->name, temp->name);
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	| multiplicative_expression MODULO cast_expression
		{
			yyinfo("multiplicative_expression ==> multiplicative_expression % cast_expression");

			SymbolType *base_type = $3->symbol->type;
			while (base_type->array_type)
			{
				base_type = base_type->array_type;
			}

			Symbol *temp;
			if ($3->type == Array::ArrayEnum::ARRAY)
			{
				temp = gentemp(base_type->type);
				emit("=[]", temp->name, $3->symbol->name, $3->temp->name);
			}
			else if ($3->type == Array::ArrayEnum::PTR)
			{
				temp = $3->temp;
			}
			else
			{
				temp = $3->symbol;
			}

			if (type_check($1->symbol, temp))
			{
				$$ = new Expression{};
				$$->symbol = gentemp($1->symbol->type->type);
				emit("%", $$->symbol->name, $1->symbol->name, temp->name);
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	;

additive_expression:
	multiplicative_expression
		{
			yyinfo("additive_expression ==> multiplicative_expression");
			$$ = $1;
		}
	| additive_expression PLUS multiplicative_expression
		{
			yyinfo("additive_expression ==> additive_expression + multiplicative_expression");

			if (type_check($1->symbol, $3->symbol))
			{
				$$ = new Expression{};
				$$->symbol = gentemp($1->symbol->type->type);
				emit("+", $$->symbol->name, $1->symbol->name, $3->symbol->name);
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	| additive_expression MINUS multiplicative_expression
		{
			yyinfo("additive_expression ==> additive_expression - multiplicative_expression");

			if (type_check($1->symbol, $3->symbol))
			{
				$$ = new Expression{};
				$$->symbol = gentemp($1->symbol->type->type);
				emit("-", $$->symbol->name, $1->symbol->name, $3->symbol->name);
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	;

shift_expression:
	additive_expression
		{
			yyinfo("shift_expression ==> additive_expression");
			$$ = $1;
		}
	| shift_expression LEFT_SHIFT additive_expression
		{
			yyinfo("shift_expression ==> shift_expression << additive_expression");

			if (type_check($1->symbol, $3->symbol))
			{
				$$ = new Expression{};
				$$->symbol = gentemp($1->symbol->type->type);
				emit("<<", $$->symbol->name, $1->symbol->name, $3->symbol->name);
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	| shift_expression RIGHT_SHIFT additive_expression
		{
			yyinfo("shift_expression ==> shift_expression >> additive_expression");

			if (type_check($1->symbol, $3->symbol))
			{
				$$ = new Expression{};
				$$->symbol = gentemp($1->symbol->type->type);
				emit(">>", $$->symbol->name, $1->symbol->name, $3->symbol->name);
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	;

/*
 * For the next set of translations, boolean expression is made and
 * appropriate operation is applied.
 * Here the true_list and false_list are also made which will be later used 
 * backpatching with appropriate destinations.
 */

relational_expression:
	shift_expression
		{
			yyinfo("relational_expression ==> shift_expression");
			$$ = $1;
		}
	| relational_expression LESS_THAN shift_expression
		{
			yyinfo("relational_expression ==> relational_expression < shift_expression");

			if (type_check($1->symbol, $3->symbol))
			{
				$$ = new Expression{};
				$$->type = Expression::ExprEnum::BOOL;
				$$->true_list = make_list(next_instruction());
				$$->false_list = make_list(next_instruction() + 1);

				emit("<", "", $1->symbol->name, $3->symbol->name);
				emit("goto", "");
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	| relational_expression GREATER_THAN shift_expression
		{
			yyinfo("relational_expression ==> relational_expression > shift_expression");

			if (type_check($1->symbol, $3->symbol))
			{
				$$ = new Expression{};
				$$->type = Expression::ExprEnum::BOOL;
				$$->true_list = make_list(next_instruction());
				$$->false_list = make_list(next_instruction() + 1);

				emit(">", "", $1->symbol->name, $3->symbol->name);
				emit("goto", "");
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	| relational_expression LESS_THAN_EQUAL_TO shift_expression
		{
			yyinfo("relational_expression ==> relational_expression <= shift_expression");

			if (type_check($1->symbol, $3->symbol))
			{
				$$ = new Expression{};
				$$->type = Expression::ExprEnum::BOOL;
				$$->true_list = make_list(next_instruction());
				$$->false_list = make_list(next_instruction() + 1);

				emit("<=", "", $1->symbol->name, $3->symbol->name);
				emit("goto", "");
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	| relational_expression GREATER_THAN_EQUAL_TO shift_expression
		{
			yyinfo("relational_expression ==> relational_expression >= shift_expression");

			if (type_check($1->symbol, $3->symbol))
			{
				$$ = new Expression{};
				$$->type = Expression::ExprEnum::BOOL;
				$$->true_list = make_list(next_instruction());
				$$->false_list = make_list(next_instruction() + 1);

				emit(">=", "", $1->symbol->name, $3->symbol->name);
				emit("goto", "");
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	;

equality_expression:
	relational_expression
		{
			yyinfo("equality_expression ==> relational_expression");
			$$ = $1;
		}
	| equality_expression EQUAL_TO relational_expression
		{
			yyinfo("equality_expression ==> equality_expression == relational_expression");

			if (type_check($1->symbol, $3->symbol))
			{
				$1->to_int();
				$3->to_int();

				$$ = new Expression{};
				$$->type = Expression::ExprEnum::BOOL;
				$$->true_list = make_list(next_instruction());
				$$->false_list = make_list(next_instruction() + 1);

				emit("==", "", $1->symbol->name, $3->symbol->name);
				emit("goto", "");
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	| equality_expression NOT_EQUAL_TO relational_expression
		{
			yyinfo("equality_expression ==> equality_expression != relational_expression");

			if (type_check($1->symbol, $3->symbol))
			{
				$1->to_int();
				$3->to_int();

				$$ = new Expression{};
				$$->type = Expression::ExprEnum::BOOL;
				$$->true_list = make_list(next_instruction());
				$$->false_list = make_list(next_instruction() + 1);

				emit("!=", "", $1->symbol->name, $3->symbol->name);
				emit("goto", "");
			}
			else
			{
				yyerror("Type Error!");
			}
		}
	;

/*
 * For these translations, non boolean expression is made, 
 * type conversion is done, expression now represents INT type
 * here the true_list and false_list are now invalid,
 * a new temporary is generated,
 * appropriate operations are applied and result is stored in the newly
 * generated temporary
*/

AND_expression:
	equality_expression
		{
			yyinfo("AND_expression ==> equality_expression");
			$$ = $1;
		}
	| AND_expression BITWISE_AND equality_expression
		{
			yyinfo("AND_expression ==> AND_expression & equality_expression");

			$1->to_int();
			$3->to_int();
			$$ = new Expression{};
			$$->type = Expression::ExprEnum::NONBOOL;
			$$->symbol = gentemp(SymbolType::SymbolEnum::INT);

			emit("&", $$->symbol->name, $1->symbol->name, $3->symbol->name);
		}
	;

exclusive_OR_expression:
	AND_expression
		{
			yyinfo("exclusive_OR_expression ==> AND_expression");
			$$ = $1;
		}
	| exclusive_OR_expression BITWISE_XOR AND_expression
		{
			yyinfo("exclusive_OR_expression ==> exclusive_OR_expression ^ AND_expression");

			$1->to_int();
			$3->to_int();
			$$ = new Expression{};
			$$->type = Expression::ExprEnum::NONBOOL;
			$$->symbol = gentemp(SymbolType::SymbolEnum::INT);

			emit("^", $$->symbol->name, $1->symbol->name, $3->symbol->name);
		}
	;

inclusive_OR_expression:
	exclusive_OR_expression
		{
			yyinfo("inclusive_OR_expression ==> exclusive_OR_expression");
			$$ = $1;
		}
	| inclusive_OR_expression BITWISE_OR exclusive_OR_expression
		{
			yyinfo("inclusive_OR_expression ==> inclusive_OR_expression | exclusive_OR_expression");

			$1->to_int();
			$3->to_int();
			$$ = new Expression{};
			$$->type = Expression::ExprEnum::NONBOOL;
			$$->symbol = gentemp(SymbolType::SymbolEnum::INT);

			emit("|", $$->symbol->name, $1->symbol->name, $3->symbol->name);
		}
	;


/*
 * Marker rule
 * M -> stores the next instruction, the location of the quad generated at M, used for backpatching later
 *
 * Fall through guard rule
 * N -> nextlist, list of indices of dangling exits at N
 */

M:
		{
			yyinfo("M => epsilon");
			$$ = next_instruction();
		}
	;

N: 
		{
			yyinfo("N => epsilon");
			$$ = new Statement{};
			$$->next_list = make_list(next_instruction());
			emit("goto", "");
		}
	;

/*
 * The backpatching and merge being done for the next three translations is as discussed in the class
 * A conversion into BOOL is made and appropriate backpatching is carried out
 *
 * For logical and
 * backpatch(B 1 .true_list, M.instr );
 * B.true_list = B 2 .true_list;
 * B.false_list = merge(B 1 .false_list, B 2 .false_list);
 *
 * For logical or
 * backpatch(B 1 .false_list, M.instr );
 * B.true_list = merge(B 1 .true_list, B 2 .true_list);
 * B.false_list = B 2 .false_list;
 *
 * For ? :
 * E .loc = gentemp();
 * E .type = E 2 .type; // Assume E 2 .type = E 3 .type
 * emit(E .loc '=' E 3 .loc); // Control gets here by fall-through
 * l = makelist(nextinstr );
 * emit(goto .... );
 * backpatch(N 2 .nextlist, nextinstr );
 * emit(E .loc '=' E 2 .loc);
 * l = merge(l, makelist(nextinstr ));
 * emit(goto .... );
 * backpatch(N 1 .nextlist, nextinstr );
 * convInt2Bool(E 1 );
 * backpatch(E 1 .true_list, M 1 .instr );
 * backpatch(E 1 .false_list, M 2 .instr );
 * backpatch(l, nextinstr );
 *
 */


logical_AND_expression:
	inclusive_OR_expression
		{
			yyinfo("logical_AND_expression ==> inclusive_OR_expression");
			$$ = $1;
		}
	| logical_AND_expression LOGICAL_AND M inclusive_OR_expression
		{
			yyinfo("logical_AND_expression ==> logical_AND_expression && inclusive_OR_expression");

			$1->to_bool();
			$4->to_bool();
			$$ = new Expression{};
			$$->type = Expression::ExprEnum::BOOL;
			backpatch($1->true_list, $3);
			$$->true_list = $4->true_list;
			$$->false_list = merge_list($1->false_list, $4->false_list);
		}
	;

logical_OR_expression:
	logical_AND_expression
		{
			yyinfo("logical_OR_expression ==> logical_AND_expression");
			$$ = $1;
		}
	| logical_OR_expression LOGICAL_OR M logical_AND_expression
		{
			yyinfo("logical_OR_expression ==> logical_OR_expression || logical_AND_expression");

			$1->to_bool();
			$4->to_bool();
			$$ = new Expression{};
			$$->type = Expression::ExprEnum::BOOL;
			backpatch($1->false_list, $3);
			$$->true_list = merge_list($1->true_list, $4->true_list);
			$$->false_list = $4->false_list;
		}
	;

conditional_expression:
	logical_OR_expression
		{
			yyinfo("conditional_expression ==> logical_OR_expression");
			$$ = $1;
		}
	| logical_OR_expression N QUESTION_MARK M expression N COLON M conditional_expression
		{
			yyinfo("conditional_expression ==> logical_OR_expression ? expression : conditional_expression");

			$$->symbol = gentemp($5->symbol->type->type);
			emit("=", $$->symbol->name, $9->symbol->name);

			list<size_t> l = make_list(next_instruction());
			emit("goto", "");

			backpatch($6->next_list, next_instruction());
			emit("=", $$->symbol->name, $5->symbol->name);

			l = merge_list(l, make_list(next_instruction()));
			emit("goto", "");

			backpatch($2->next_list, next_instruction());
			$1->to_bool();

			backpatch($1->true_list, $4);
			backpatch($1->false_list, $8);
			backpatch(l, next_instruction());
		}
	;

assignment_expression:
	conditional_expression
		{
			yyinfo("assignment_expression ==> conditional_expression");
			$$ = $1;
		}
	| unary_expression assignment_operator assignment_expression
		{
			yyinfo("assignment_expression ==> unary_expression assignment_operator assignment_expression");

			switch ($1->type)
			{
				case Array::ArrayEnum::ARRAY:
				{
					// assignment to array
					$3->symbol = $3->symbol->convert($1->sub_array_type->type);
					emit("[]=", $1->symbol->name, $1->temp->name, $3->symbol->name);
				}
				break;

				case Array::ArrayEnum::PTR:
				{
					// assignment to pointer
					$3->symbol = $3->symbol->convert($1->temp->type->type);
					emit("*=", $1->temp->name, $3->symbol->name);
				}
				break;

				default:
				{
					// assignment to other
					$3->symbol = $3->symbol->convert($1->symbol->type->type);
					emit("=", $1->symbol->name, $3->symbol->name);
				}
				break;
			}
			
			$$ = $3;
		}
	;

assignment_operator:
	ASSIGNMENT
		{ yyinfo("assignment_operator ==> ="); }
	| STAR_ASSIGNMENT
		{ yyinfo("assignment_operator ==> *="); }
	| FRONT_SLASH_ASSIGNMENT
		{ yyinfo("assignment_operator ==> /="); }
	| MODULO_ASSIGNMENT
		{ yyinfo("assignment_operator ==> %="); }
	| PLUS_ASSIGNMENT
		{ yyinfo("assignment_operator ==> += "); }
	| MINUS_ASSIGNMENT
		{ yyinfo("assignment_operator ==> -= "); }
	| LEFT_SHIFT_ASSIGNMENT
		{ yyinfo("assignment_operator ==> <<="); }
	| RIGHT_SHIFT_ASSIGNMENT
		{ yyinfo("assignment_operator ==> >>="); }
	| BITWISE_AND_ASSIGNMENT
		{ yyinfo("assignment_operator ==> &="); }
	| BITWISE_XOR_ASSIGNMENT
		{ yyinfo("assignment_operator ==> ^="); }
	| BITWISE_OR_ASSIGNMENT
		{ yyinfo("assignment_operator ==> |="); }
	;

expression:
	assignment_expression
		{
			yyinfo("expression ==> assignment_expression");
			$$ = $1;
		}
	| expression COMMA assignment_expression
		{ yyinfo("expression ==> expression , assignment_expression"); }
	;

constant_expression:
	conditional_expression
		{ yyinfo("constant_expression ==> conditional_expression"); }
	;

/* Declarations */

declaration:
	declaration_specifiers init_declarator_list_opt SEMI_COLON
		{ yyinfo("declaration ==> declaration_specifiers init_declarator_list_opt ;"); }
	;

init_declarator_list_opt:
	init_declarator_list
		{ yyinfo("init_declarator_list_opt ==> init_declarator_list"); }
	|
		{ yyinfo("init_declarator_list_opt ==> epsilon"); }
	;

declaration_specifiers:
	storage_class_specifier declaration_specifiers_opt
		{ yyinfo("declaration_specifiers ==> storage_class_specifier declaration_specifiers_opt"); }
	| type_specifier declaration_specifiers_opt
		{ yyinfo("declaration_specifiers ==> type_specifier declaration_specifiers_opt"); }
	| type_qualifier declaration_specifiers_opt
		{ yyinfo("declaration_specifiers ==> type_qualifier declaration_specifiers_opt"); }
	| function_specifier declaration_specifiers_opt
		{ yyinfo("declaration_specifiers ==> function_specifier declaration_specifiers_opt"); }
	;

declaration_specifiers_opt:
	declaration_specifiers
		{ yyinfo("declaration_specifiers_opt ==> declaration_specifiers"); }
	|
		{ yyinfo("declaration_specifiers_opt ==> epsilon "); }
	;

init_declarator_list:
	init_declarator
		{ yyinfo("init_declarator_list ==> init_declarator"); }
	| init_declarator_list COMMA init_declarator
		{ yyinfo("init_declarator_list ==> init_declarator_list , init_declarator"); }
	;

init_declarator:
	declarator
		{
			yyinfo("init_declarator ==> declarator");
			$$ = $1;
		}
	| declarator ASSIGNMENT initializer
		{
			yyinfo("init_declarator ==> declarator = initializer");

			// if there is some initial value assign it 
			if ($3->initial_value != "") 
			{
				$1->initial_value = $3->initial_value;
			}
			
			// = assignment
			emit("=", $1->name, $3->name);
		}
	;

storage_class_specifier:
	EXTERN
		{ yyinfo("storage_class_specifier ==> extern"); }
	| STATIC
		{ yyinfo("storage_class_specifier ==> static"); }
	| AUTO
		{ yyinfo("storage_class_specifier ==> auto"); }
	| REGISTER
		{ yyinfo("storage_class_specifier ==> register"); }
	;

type_specifier:
	KEY_VOID
		{
			yyinfo("type_specifier ==> void");
			current_type = SymbolType::SymbolEnum::VOID;
		}
	| KEY_CHAR
		{
			yyinfo("type_specifier ==> char");
			current_type = SymbolType::SymbolEnum::CHAR;
		}
	| SHORT
		{ yyinfo("type_specifier ==> short"); }
	| KEY_INT
		{
			yyinfo("type_specifier ==> int");
			current_type = SymbolType::SymbolEnum::INT;
		}
	| LONG
		{ yyinfo("type_specifier ==> long"); }
	| KEY_FLOAT
		{
			yyinfo("type_specifier ==> float");
			current_type = SymbolType::SymbolEnum::FLOAT;
		}
	| DOUBLE
		{ yyinfo("type_specifier ==> double"); }
	| SIGNED
		{ yyinfo("type_specifier ==> signed"); }
	| UNSIGNED
		{ yyinfo("type_specifier ==> unsigned"); }
	| BOOL
		{ yyinfo("type_specifier ==> _Bool"); }
	| COMPLEX
		{ yyinfo("type_specifier ==> _Complex"); }
	| IMAGINARY
		{ yyinfo("type_specifier ==> _Imaginary"); }
	| enum_specifier 
		{ yyinfo("type_specifier ==> enum_specifier"); }
	;

specifier_qualifier_list:
	type_specifier specifier_qualifier_list_opt
		{ yyinfo("specifier_qualifier_list ==> type_specifier specifier_qualifier_list_opt"); }
	| type_qualifier specifier_qualifier_list_opt
		{ yyinfo("specifier_qualifier_list ==> type_qualifier specifier_qualifier_list_opt"); }
	;

specifier_qualifier_list_opt:
	specifier_qualifier_list
		{ yyinfo("specifier_qualifier_list_opt ==> specifier_qualifier_list"); }
	| 
		{ yyinfo("specifier_qualifier_list_opt ==> epsilon"); }
	;

enum_specifier:
	ENUM identifier_opt LEFT_BRACE enumerator_list RIGHT_BRACE 
		{ yyinfo("enum_specifier ==> enum identifier_opt { enumerator_list }"); }
	| ENUM identifier_opt LEFT_BRACE enumerator_list COMMA RIGHT_BRACE
		{ yyinfo("enum_specifier ==> enum identifier_opt { enumerator_list , }"); }
	| ENUM IDENTIFIER
		{ yyinfo("enum_specifier ==> enum IDENTIFIER"); }
	;

identifier_opt:
	IDENTIFIER 
		{ yyinfo("identifier_opt ==> IDENTIFIER"); }
	| 
		{ yyinfo("identifier_opt ==> epsilon"); }
	;

enumerator_list:
	enumerator 
		{ yyinfo("enumerator_list ==> enumerator"); }
	| enumerator_list COMMA enumerator
		{ yyinfo("enumerator_list ==> enumerator_list , enumerator"); }
	;

/* Here IDENTIFIER should have been ENUMERATION_CONSTANT, but since flex can't recognise it this rule gives error. Hence IDENTIFIER token used here */

enumerator:
	IDENTIFIER 
		{ yyinfo("enumerator ==> ENUMERATION_CONSTANT"); }
	| IDENTIFIER ASSIGNMENT constant_expression
		{ yyinfo("enumerator ==> ENUMERATION_CONSTANT = constant_expression"); }
	;

type_qualifier:
	CONST
		{ yyinfo("type_qualifier ==> const"); }
	| RESTRICT
		{ yyinfo("type_qualifier ==> restrict"); }
	| VOLATILE
		{ yyinfo("type_qualifier ==> volatile"); }
	;

function_specifier:
	INLINE
		{ yyinfo("function_specifier ==> inline"); }
	;

declarator:
	pointer direct_declarator
		{
			yyinfo("declarator ==> pointer direct_declarator");

			SymbolType *it = $1;
			while (it->array_type)
			{
				it = it->array_type;
			}

			it->array_type = $2->type;
			$$ = $2->update($1);
		}
	| direct_declarator
		{ yyinfo("declarator ==> direct_declarator"); }
	;

change_scope:
		{
			if (not current_symbol->nested_table)
			{
				change_table(new SymbolTable(""));
			}
			else
			{
				change_table(current_symbol->nested_table);
				emit("label", current_table->name);
			}
		}
	;

/* pointer_opt:
	pointer
		{ yyinfo("pointer_opt ==> pointer"); }
	|
		{ yyinfo("pointer_opt ==> epsilon"); }
	; 
*/

direct_declarator:
	IDENTIFIER 
		{
			yyinfo("direct_declarator ==> IDENTIFIER");
			$$ = $1->update(new SymbolType(current_type)); // update type to the last type seen
			current_symbol = $$;
		}
	| LEFT_PARENTHESES declarator RIGHT_PARENTHESES
		{
			yyinfo("direct_declarator ==> ( declarator )");
			$$ = $2;
		}
	| direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list assignment_expression RIGHT_SQUARE_BRACKET
		{ yyinfo("direct_declarator ==> direct_declarator [ type_qualifier_list assignment_expression ]"); }
	| direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list RIGHT_SQUARE_BRACKET
		{ yyinfo("direct_declarator ==> direct_declarator [ type_qualifier_list ]"); }
	| direct_declarator LEFT_SQUARE_BRACKET assignment_expression RIGHT_SQUARE_BRACKET
		{
			yyinfo("direct_declarator ==> direct_declarator [ assignment_expression ]");

			SymbolType *it1 = $1->type, *it2 = NULL;

			while (it1->type == SymbolType::SymbolEnum::ARRAY)
			{
				// go to the base level of a nested type
				it2 = it1;
				it1 = it1->array_type;
			}
			if (it2)
			{ 
				// nested array case
				it2->array_type = new SymbolType(SymbolType::SymbolEnum::ARRAY, it1, stoull($3->symbol->initial_value.c_str()));	
				$$ = $1->update($1->type);
			}
			else
			{
				// fresh array
				$$ = $1->update(new SymbolType(SymbolType::SymbolEnum::ARRAY, $1->type, stoull($3->symbol->initial_value.c_str())));
			}
		}
	| direct_declarator LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET
		{
			yyinfo("direct_declarator ==> direct_declarator [ ]");

			SymbolType *it1 = $1->type, *it2 = NULL;

			while (it1->type == SymbolType::SymbolEnum::ARRAY)
			{
				// go to the base level of a nested type
				it2 = it1;
				it1 = it1->array_type;
			}
			if (it2)
			{ 
				// nested array case
				it2->array_type = new SymbolType(SymbolType::SymbolEnum::ARRAY, it1, 0);
				$$ = $1->update($1->type);
			}
			else
			{
				// fresh array
				$$ = $1->update(new SymbolType(SymbolType::SymbolEnum::ARRAY, $1->type, 0));
			}
		}
	| direct_declarator LEFT_SQUARE_BRACKET STATIC type_qualifier_list assignment_expression RIGHT_SQUARE_BRACKET
		{ yyinfo("direct_declarator ==> direct_declarator [ static type_qualifier_list assignment_expression ]"); }
	| direct_declarator LEFT_SQUARE_BRACKET STATIC assignment_expression RIGHT_SQUARE_BRACKET
		{ yyinfo("direct_declarator ==> direct_declarator [ assignment_expression ]"); }
	| direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list STATIC assignment_expression RIGHT_SQUARE_BRACKET
		{ yyinfo("direct_declarator ==> direct_declarator [ type_qualifier_list static assignment_expression ]"); }
	| direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list STAR RIGHT_SQUARE_BRACKET
		{ yyinfo("direct_declarator ==> direct_declarator [ type_qualifier_list * ]"); }
	| direct_declarator LEFT_SQUARE_BRACKET STAR RIGHT_SQUARE_BRACKET
		{ yyinfo("direct_declarator ==> direct_declarator [ * ]"); }
	| direct_declarator LEFT_PARENTHESES change_scope parameter_type_list RIGHT_PARENTHESES
		{
			yyinfo("direct_declarator ==> direct_declarator ( parameter_type_list )");

			// function declaration
			current_table->name = $1->name;
			if ($1->type->type != SymbolType::SymbolEnum::VOID)
			{
				// set type of return value
				current_table->lookup("return")->update($1->type);
			}
			// move back to the global table and set the nested table for the function
			$1->nested_table = current_table;
			current_table->parent = global_table;
			change_table(global_table);
			current_symbol = $$;
		}
	| direct_declarator LEFT_PARENTHESES identifier_list RIGHT_PARENTHESES
		{ yyinfo("direct_declarator ==> direct_declarator ( identifier_list )"); }
	| direct_declarator LEFT_PARENTHESES change_scope RIGHT_PARENTHESES
		{
			yyinfo("direct_declarator => direct_declarator ( )");

			current_table->name = $1->name;
			if ($1->type->type != SymbolType::SymbolEnum::VOID) {
				// set type of return value
				current_table->lookup("return")->update($1->type);
			}
			// move back to the global table and set the nested table for the function
			$1->nested_table = current_table;
			current_table->parent = global_table;
			change_table(global_table);
			current_symbol = $$;
		}
	;

type_qualifier_list_opt:
	type_qualifier_list
		{ yyinfo("type_qualifier_list_opt ==> type_qualifier_list"); }
	|
		{ yyinfo("type_qualifier_list_opt ==> epsilon"); }
	;

/*
assignment_expression_opt:
	assignment_expression
		{ yyinfo("assignment_expression_opt ==> assignment_expression"); }
	|
		{ yyinfo("assignment_expression_opt ==> epsilon"); }
	;

identifier_list_opt:
	identifier_list
		{ yyinfo("identifier_list_opt ==> identifier_list"); }
	|
		{ yyinfo("identifier_list_opt ==> epsilon"); }
	;
*/

pointer:
	STAR type_qualifier_list_opt
		{
			yyinfo("pointer ==> * type_qualifier_list_opt");
			$$ = new SymbolType(SymbolType::SymbolEnum::PTR);
		}
	| STAR type_qualifier_list_opt pointer
		{
			yyinfo("pointer ==> * type_qualifier_list_opt pointer"); 
			$$ = new SymbolType(SymbolType::SymbolEnum::PTR, $3);
		}
	;

type_qualifier_list:
	type_qualifier
		{ yyinfo("type_qualifier_list ==> type_qualifier"); }
	| type_qualifier_list type_qualifier
		{ yyinfo("type_qualifier_list ==> type_qualifier_list type_qualifier"); }
	;

parameter_type_list:
	parameter_list
		{ yyinfo("parameter_type_list ==> parameter_list"); }
	| parameter_list COMMA ELLIPSIS
		{ yyinfo("parameter_type_list ==> parameter_list , ..."); }
	;

parameter_list:
	parameter_declaration
		{ yyinfo("parameter_list ==> parameter_declaration"); }
	| parameter_list COMMA parameter_declaration
		{ yyinfo("parameter_list ==> parameter_list , parameter_declaration"); }
	;

parameter_declaration:
	declaration_specifiers declarator
		{ yyinfo("parameter_declaration ==> declaration_specifiers declarator"); }
	| declaration_specifiers
		{ yyinfo("parameter_declaration ==> declaration_specifiers"); }
	;

identifier_list:
	IDENTIFIER 
		{ yyinfo("identifier_list ==> IDENTIFIER"); }
	| identifier_list COMMA IDENTIFIER
		{ yyinfo("identifier_list ==> identifier_list , IDENTIFIER"); }
	;

type_name:
	specifier_qualifier_list
		{ yyinfo("type_name ==> specifier_qualifier_list"); }
	;

initializer:
	assignment_expression
		{
			yyinfo("initializer ==> assignment_expression");
			$$ = $1->symbol;
		}
	| LEFT_BRACE initializer_list RIGHT_BRACE
		{ yyinfo("initializer ==> { initializer_list }"); }
	| LEFT_BRACE initializer_list COMMA RIGHT_BRACE
		{ yyinfo("initializer ==> { initializer_list , }"); }
	;

initializer_list:
	designation_opt initializer
		{ yyinfo("initializer_list ==> designation_opt initializer"); }
	| initializer_list COMMA designation_opt initializer
		{ yyinfo("initializer_list ==> initializer_list , designation_opt initializer"); }
	;

designation_opt:
	designation
		{ yyinfo("designation_opt ==> designation"); }
	|
		{ yyinfo("designation_opt ==> epsilon"); }
	;

designation:
	designator_list ASSIGNMENT
		{ yyinfo("designation ==> designator_list ="); }
	;

designator_list:
	designator
		{ yyinfo("designator_list ==> designator"); }
	| designator_list designator
		{ yyinfo("designator_list ==> designator_list designator"); }
	;

designator:
	LEFT_SQUARE_BRACKET constant_expression RIGHT_SQUARE_BRACKET
		{ yyinfo("designator ==> [ constant_expression ]"); }
	| DOT IDENTIFIER
		{ yyinfo("designator ==> . IDENTIFIER"); }
	;

/* Statements */

statement:
	labeled_statement
		{ yyinfo("statement ==> labeled_statement"); }
	| compound_statement
		{
			yyinfo("statement ==> compound_statement");
			$$ = $1;
		}
	| expression_statement
		{
			yyinfo("statement ==> expression_statement");

			$$ = new Statement{};
			$$->next_list = $1->next_list;
		}
	| selection_statement
		{
			yyinfo("statement ==> selection_statement");
			$$ = $1;
		}
	| iteration_statement
		{
			yyinfo("statement ==> iteration_statement");
			$$ = $1;
		}
	| jump_statement
		{
			yyinfo("statement ==> jump_statement");
			$$ = $1;
		}
	;

labeled_statement:
	IDENTIFIER COLON statement
		{ yyinfo("labeled_statement ==> IDENTIFIER : statement"); }
	| CASE constant_expression COLON statement
		{ yyinfo("labeled_statement ==> case constant_expression : statement"); } 
	| DEFAULT COLON statement
		{ yyinfo("labeled_statement ==> default : statement"); }
	;


/*
 * Used to change the symbol table when a new block is encountered
 * Helps create a hierarchy of symbol tables
 */

/* change_block: 
		{
			string name = current_table->name + "_" + to_string(table_count);
			table_count++;
			Symbol *s = current_table->lookup(name); // create new entry in symbol table
			s->nested_table = new SymbolTable(name, current_table);
			s->type = new SymbolType(SymbolType::SymbolEnum::BLOCK);
			current_symbol = s;
		} 
	; */

compound_statement:
	LEFT_BRACE change_scope block_item_list_opt RIGHT_BRACE
		{
			yyinfo("compound_statement ==> { block_item_list_opt }");
			$$ = $4;
			change_table(current_table->parent); // block over, move back to the parent table
		}
	;

block_item_list_opt:
	block_item_list
		{
			yyinfo("block_item_list_opt ==> block_item_list");
			$$ = $1;
		}
	|
		{
			yyinfo("block_item_list_opt ==> epsilon");
			$$ = new Statement{};
		}
	;

block_item_list:
	block_item
		{
			yyinfo("block_item_list ==> block_item");
			$$ = $1;
		}
	| block_item_list M block_item
		{
			yyinfo("block_item_list ==> block_item_list block_item");
			$$ = $3;

			backpatch($1->next_list, $2);
		}
	;

block_item:
	declaration
		{
			yyinfo("block_item ==> declaration");
			$$ = new Statement{};
		}
	| statement
		{
			yyinfo("block_item ==> statement");
			$$ = $1;
		}
	;

expression_statement:
	expression_opt SEMI_COLON
		{
			yyinfo("expression_statement ==> expression_opt ;");
			$$ = $1;
		}
	;

expression_opt:
	expression
		{
			yyinfo("expression_opt ==> expression");
			$$ = $1;
		}
	|
		{
			yyinfo("expression_opt ==> epsilon");
			$$ = new Expression{};
		}
	;

/*
 * IF ELSE
 * -> the %prec THEN is to remove conflicts during translation
 *
 * Markers M and guard N have been added as discussed in the class
 * S -> if (B) M S1 N
 * backpatch(B.truelist, M.instr )
 * S.nextlist = merge(B.falselist, merge(S1.nextlist, N.nextlist))
 *
 * S -> if (B) M 1 S 1 N else M 2 S 2
 * backpatch(B.truelist, M1.instr )
 * backpatch(B.falselist, M2.instr )
 * S.nextlist = merge(merge(S1.nextlist, N.nextlist), S2 .nextlist)
 *
 */

selection_statement:
	IF LEFT_PARENTHESES expression RIGHT_PARENTHESES M statement N %prec THEN
		{
			yyinfo("selection_statement ==> if ( expression ) statement");

			$$ = new Statement{};
			$3->to_bool();
			backpatch($3->true_list, $5);
			$$->next_list = merge_list($3->false_list, merge_list($6->next_list, $7->next_list));
		}
	| IF LEFT_PARENTHESES expression RIGHT_PARENTHESES M statement N ELSE M statement
		{
			yyinfo("selection_statement ==> if ( expression ) statement else statement");

			$$ = new Statement{};
			$3->to_bool();
			backpatch($3->true_list, $5); // if true go to M
			backpatch($3->false_list, $9); // if false go to else
			$$->next_list = merge_list($10->next_list, merge_list($6->next_list, $7->next_list));
		}
	| SWITCH LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
		{ yyinfo("selection_statement ==> switch ( expression ) statement"); }
	;


/*
 * LOOPS
 *
 * while M1 (B) M2 S1
 * backpatch(S1.nextlist, M1.instr );
 * backpatch(B.truelist, M2.instr );
 * S.nextlist = B.falselist;
 * emit(”goto”, M1.instr );
 *
 * do M1 S1 M2 while ( B );
 * backpatch(B.truelist, M1.instr );
 * backpatch(S1 .nextlist, M2.instr );
 * S.nextlist = B.falselist;
 *
 * for ( E1 ; M1 B ; M2 E2 N ) M3 S1
 * backpatch(B.truelist, M3.instr );
 * backpatch(N.nextlist, M1.instr );
 * backpatch(S1.nextlist, M2.instr );
 * emit(”goto” M2.instr );
 * S.nextlist = B.falselist;
 *
 */

iteration_statement:
	WHILE M LEFT_PARENTHESES expression RIGHT_PARENTHESES M statement
		{
			yyinfo("iteration_statement ==> while ( expression ) statement");

			$$ = new Statement{};
			$4->to_bool();
			backpatch($7->next_list, $2); // after statement go back to M1
			backpatch($4->true_list, $6); // if true go to M2
			$$->next_list = $4->false_list; // exit if false
			emit("goto", to_string($2));
		}
	| DO M statement M WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
		{
			yyinfo("iteration_statement ==> do statement while ( expression ) ;");

			$$ = new Statement{};
			$7->to_bool();
			backpatch($7->true_list, $2); // if true go back to M1
			backpatch($3->next_list, $4); // after statement is executed go to M2
			$$->next_list = $7->false_list;
		}
	| FOR LEFT_PARENTHESES expression_opt SEMI_COLON M expression_opt SEMI_COLON M expression_opt N RIGHT_PARENTHESES M statement
		{
			yyinfo("iteration_statement ==> for ( expression_opt ; expression_opt ; expression_opt ) statement");

			$$ = new Statement{};
			$6->to_bool();
			backpatch($6->true_list, $12); // if true go to M3 (loop body)
			backpatch($10->next_list, $5); // after N go to M1 (condition check)
			backpatch($13->next_list, $8); // after S1 (loop body) go to M2 (increment/decrement/any other operation)
			emit("goto", to_string($8));
			$$->next_list = $6->false_list;
		}
	| FOR LEFT_PARENTHESES declaration expression_opt SEMI_COLON expression_opt RIGHT_PARENTHESES statement
		{ yyinfo("iteration_statement ==> for ( declaration expression_opt ; expression_opt ) statement"); }
	;

jump_statement:
	GOTO IDENTIFIER SEMI_COLON
		{ yyinfo("jump_statement ==> goto IDENTIFIER ;"); }
	| CONTINUE SEMI_COLON
		{ yyinfo("jump_statement ==> continue ;"); }
	| BREAK SEMI_COLON
		{ yyinfo("jump_statement ==> break ;"); }
	| RETURN expression_opt SEMI_COLON
		{
			yyinfo("jump_statement ==> return expression_opt ;");

			$$ = new Statement{};
			if ($2->symbol)
			{
				emit("return", $2->symbol->name); // emit the current symbol name at return if it exists otherwise empty
			}
			else
			{
				emit("return", "");
			}
		}
	;

/* External definitions */

translation_unit:
	external_declaration
		{ yyinfo("translation_unit ==> external_declaration"); }
	| translation_unit external_declaration
		{ yyinfo("translation_unit ==> translation_unit external_declaration"); }
	;

external_declaration:
	function_definition
		{ yyinfo("external_declaration ==> function_definition"); }
	| declaration
		{ yyinfo("external_declaration ==> declaration"); }
	;

function_definition: // modified to prevent block change
	declaration_specifiers declarator declaration_list_opt change_scope LEFT_BRACE block_item_list_opt RIGHT_BRACE
		{
			yyinfo("function_definition ==> declaration_specifiers declarator declaration_list_opt { block_item_list_opt }");

			table_count = 0;
			emit("labelend", $2->name);
			if($2->type->type != SymbolType::SymbolEnum::VOID) {
				// set type of return value
				current_table->lookup("return")->update($2->type);
			}

			change_table(global_table);
		}
	;

declaration_list_opt:
	declaration_list
		{ yyinfo("declaration_list_opt ==> declaration_list"); }
	|
		{ yyinfo("declaration_list_opt ==> epsilon"); }
	;

declaration_list:
	declaration
		{ yyinfo("declaration_list ==> declaration"); }
	| declaration_list declaration
		{ yyinfo("declaration_list ==> declaration_list declaration"); }
	;
%%

void yyerror(const string &s)
{
	printf("ERROR [Line %d] : %s\n", yylineno, s.c_str());
}

void yyinfo(const string &s)
{
#ifdef PARSE
	printf("INFO [Line %d] : %s\n", yylineno, s.c_str());
#endif
}
