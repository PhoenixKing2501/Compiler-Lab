#ifndef _DEF_H_
#define _DEF_H_

// enum TOKENS
// {
// 	KEYWORD = 100,
// 	IDENTIFIER,
// 	INT_CONST,
// 	FLOAT_CONST,
// 	ENUM_CONST,
// 	CHAR_CONST,
// 	STRING_LITERAL,
// 	PUNCTUATOR,
// 	ERROR,
// };

int yylex();
int yyparse();

void yyerror(char *);
void yyinfo(char *);

int yywrap(void);

extern char *yytext;
extern int yyleng;
extern int yylineno;

#endif // _DEF_H_
