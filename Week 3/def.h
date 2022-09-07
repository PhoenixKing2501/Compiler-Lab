#ifndef _DEF_H_
#define _DEF_H_

enum TOKENS
{
	KEYWORD = 100,
	IDENTIFIER,
	CONSTANT,
	INT_CONST,
	FLOAT_CONST,
	ENUM_CONST,
	CHAR_CONST,
	STRING_LITERAL,
	PUNCTUATOR,
	ERROR,
};

int yylex();
int yywrap();

extern char *yytext;
extern int yyleng;
extern int yylineno;

#endif // _DEF_H_
