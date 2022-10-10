#include "def.h"
#include <stdio.h>

int yywrap(void)
{
	return 1;
}

int main()
{
	yyparse();
	return 0;
}
