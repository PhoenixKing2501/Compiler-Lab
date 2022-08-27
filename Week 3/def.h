#pragma once

#ifndef _DEF_H_
#define _DEF_H_

#include <stdio.h>

enum TOKENS
{
	KEYWORD = 100,
	IDENTIFIER,
	CONSTANT,
	STRING_LITERAL,
	PUNCTUATOR
};

int yywrap(void)
{
	return 1;
}

extern char *yytext;
extern int yyleng;
extern int yylineno;

#endif // _DEF_H_
