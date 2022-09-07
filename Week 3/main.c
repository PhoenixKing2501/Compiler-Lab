#include "def.h"
#include <stdio.h>

int yywrap()
{
	return 1;
}

int main()
{
	int token;

	while (token = yylex())
	{
		switch (token)
		{
		case IDENTIFIER:
			printf("< IDENTIFIER , `%s` >\n", yytext);
			break;

		case INT_CONST:
			printf("< INTEGER_CONSTANT , `%s` >\n", yytext);
			break;

		case FLOAT_CONST:
			printf("< FLOAT_CONSTANT , `%s` >\n", yytext);
			break;

		case ENUM_CONST:
			printf("< ENUMERATION_CONSTANT , `%s` >\n", yytext);
			break;

		case CHAR_CONST:
			printf("< CHARACTER_CONSTANT , `%s` >\n", yytext);
			break;

		case STRING_LITERAL:
			printf("< STRING_LITERAL , `%s` >\n", yytext);
			break;

		case PUNCTUATOR:
			printf("< PUNCTUATOR , `%s` >\n", yytext);
			break;

		case KEYWORD:
			printf("< KEYWORD , `%s` >\n", yytext);
			break;

		case ERROR:
			printf("Unknown token `%s` found on line %d\n", yytext, yylineno);

		default:
			break;
		}
	}

	return 0;
}
