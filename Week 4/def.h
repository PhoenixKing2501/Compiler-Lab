#ifndef _DEF_H_
#define _DEF_H_

int yylex();
int yyparse();

void yyerror(char *);
void yyinfo(char *);

int yywrap(void);

extern char *yytext;
extern int yyleng;
extern int yylineno;

#endif // _DEF_H_
