#pragma once

#ifndef _DEF_H_
#define _DEF_H_

enum TOKENS
{
	KEYWORD = 100,
	IDENTIFIER,
	CONSTANT,
	STRING_LITERAL,
	PUNCTUATOR
};

int yywrap()
{
	return 1;
}

extern char *yytext;
extern int yyleng;

#endif // _DEF_H_
