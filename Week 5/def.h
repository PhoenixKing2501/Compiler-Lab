#pragma once

#ifndef _DEF_H_
#define _DEF_H_

#include <ass5_20CS10063_20CS30057_translator.h>

int yylex();
int yyparse();

void yyerror(const string &);
void yyinfo(const string &);

extern char *yytext;
extern int yyleng;
extern int yylineno;

#endif // _DEF_H_
