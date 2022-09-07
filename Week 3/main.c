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
			printf("< IDENTIFIER , `%s` >", yytext);
			break;

		case INT_CONST:
			printf("< INTEGER_CONSTANT , `%s` >", yytext);
			break;

		case FLOAT_CONST:
			printf("< FLOAT_CONSTANT , `%s` >", yytext);
			break;

		case ENUM_CONST:
			printf("< ENUMERATION_CONSTANT , `%s` >", yytext);
			break;

		case CHAR_CONST:
			printf("< CHARACTER_CONSTANT , `%s` >", yytext);
			break;

		case STRING_LITERAL:
			printf("< STRING_LITERAL , `%s` >", yytext);
			break;

		case PUNCTUATOR:
			printf("< PUNCTUATOR , `%s` >", yytext);
			break;

		case KEYWORD:
			printf("< KEYWORD , `%s` >", yytext);
			break;

		default:
			break;
		}
	}

	return 0;
}
