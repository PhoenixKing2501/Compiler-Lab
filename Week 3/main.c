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
			printf("< INTEGER CONSTANT , `%s` >", yytext);
			break;

		case FLOAT_CONST:
			printf("< FLOAT CONSTANT , `%s` >", yytext);
			break;

		case ENUM_CONST:
			printf("< ENUMERATION CONSTANT , `%s` >", yytext);
			break;

		case CHAR_CONST:
			printf("< CHARACTER CONSTANT , `%s` >", yytext);
			break;

		case STRING_LITERAL:
			printf("< STRING LITERAL , `%s` >", yytext);
			break;

		case PUNCTUATOR:
			printf("< PUNCTUATOR , `%s` >", yytext);
			break;

		// case LINE_COMMENT:
		// 	printf("< LINE COMMENT >");
		// 	break;

		// case BLOCK_COMMENT:
		// 	printf("< BLOCK COMMENT >");
		// 	break;

		case KEYWORD:
			printf("< KEYWORD , `%s` >", yytext);
			break;

		default:
			break;
		}
	}

	return 0;
}
