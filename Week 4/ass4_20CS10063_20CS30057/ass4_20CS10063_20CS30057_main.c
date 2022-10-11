#include "def.h"
#include <stdio.h>

void yyerror(char *s)
{
	printf("ERROR at line %d: %s\n", yylineno, s);
}

void yyinfo(char *s)
{
	printf("Line %d: %s\n", yylineno, s);
}

int yywrap(void)
{
	return 1;
}

int main()
{
	yyparse();
	return 0;
}
