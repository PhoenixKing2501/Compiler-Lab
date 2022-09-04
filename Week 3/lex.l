%{
	/* C headers */
	#include "def.h"
%}

/* Regular Expression Definitions */
LETTER_						[a-zA-Z_]
DIGIT						[0-9]
NZDIGIT 					[1-9]
DIGIT_SEQ					{DIGIT}+
EXPONENT					[Ee]
SIGN						[+-]
ESC_SEQ						\\\'|\\\"|\\\?|\\\\|\\a|\\b|\\f|\\n|\\r|\\t|\\v
C_CHAR						{ESC_SEQ}|[^'\\\n]
C_CHAR_SEQ					{C_CHAR}+
S_CHAR						{ESC_SEQ}|[^"\\\n]
S_CHAR_SEQ					{S_CHAR}+

EXP_PART					{EXPONENT}{SIGN}{DIGIT_SEQ}
FRAC_CONST					{DIGIT_SEQ}?\.{DIGIT_SEQ}|{DIGIT_SEQ}\.

LINE_COMMENT				\/\/[^\n]*
BLOCK_COMMENT				\/\*
IDENTIFIER					{LETTER_}({LETTER_}|{DIGIT})*
INT_CONST					{NZDIGIT}{DIGIT}*
FLOAT_CONST					{FRAC_CONST}{EXP_PART}?|{DIGIT_SEQ}{EXP_PART}
ENUM_CONST					{IDENTIFIER}
CHAR_CONST					\'{C_CHAR_SEQ}\'
STRING_LITERAL				\"{S_CHAR_SEQ}\"
PUNCTUATOR					<<=|>>=|->|\+\+|--|<<|>>|<=|>=|==|!=|&&|\.\.\.|\*=|\/=|%=|\+=|-=|&=|\^=|\|\||\|=|[[\](){}.+\-*\/&~!%<>\^|?:;,#=]

%%

"auto"						|
"enum"						|
"restrict"					|
"unsigned"					|
"break"						|
"extern"					|
"return"					|
"void"						|
"case"						|
"float"						|
"short"						|
"volatile"					|
"char"						|
"for"						|
"signed"					|
"while"						|
"const"						|
"goto"						|
"sizeof"					|
"_Bool"						|
"continue"					|
"if"						|
"static"					|
"_Complex"					|
"default"					|
"inline"					|
"struct"					|
"_Imaginary"				|
"do"						|
"int"						|
"switch"					|
"double"					|
"long"						|
"typedef"					|
"else"						|
"register"					|
"union"						/*{printf("< KEYWORD , `%s` > ", yytext);}*/ {return KEYWORD;}			

{LINE_COMMENT}				/*{printf("< LINE COMMENT > ");}*/ {return LINE_COMMENT;}
{BLOCK_COMMENT}				{
								int c;

								while(1)
								{
									while ((c = input()) != '*' && c != EOF)
										;	/* eat up text of comment */

									if (c == '*')
									{
										while ((c = input()) == '*')
											;

										if (c == '/')
										{
											/*printf("< BLOCK COMMENT > ");*/ return BLOCK_COMMENT;
											break;
										}	/* found the end */
									}
								}
							}

{IDENTIFIER}				/*{printf("< IDENTIFIER , `%s` > ", yytext);}*/	{return IDENTIFIER;}
{INT_CONST}					/*{printf("< INTEGER CONSTANT , `%s` > ", yytext);}*/ {return INT_CONST;}
{FLOAT_CONST}				/*{printf("< FLOAT CONSTANT , `%s` > ", yytext);}*/ {return FLOAT_CONST;}
{ENUM_CONST}				/*{printf("< ENUMERATION CONSTANT , `%s` > ", yytext);}*/ {return ENUM_CONST;}
{CHAR_CONST}				/*{printf("< CHARACTER CONSTANT , `%s` > ", yytext);}*/ {return CHAR_CONST;}
{STRING_LITERAL}			/*{printf("< STRING LITERAL , `%s` > ", yytext);}*/ {return STRING_LITERAL;}
{PUNCTUATOR}				/*{printf("< PUNCTUATOR , `%s` > ", yytext);}*/ {return PUNCTUATOR;}
[ \t]						{;}
[\r]?[\n]					{printf("\n");}

%%

int main()
{
	yylex();
}
