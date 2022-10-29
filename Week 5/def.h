#pragma once

#ifndef _DEF_H_
#define _DEF_H_

#include <translator.h>

int yylex();
int yyparse();

void yyerror(const string &);
void yyinfo(const string &);

int yywrap(void);

extern char *yytext;
extern int yyleng;
extern int yylineno;

#endif // _DEF_H_
