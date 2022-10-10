%{
	/* C headers */
	#include "def.h"
	#include "ass4_20CS10063_20CS30057.tab.h"
%}

%option yylineno

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

EXP_PART					{EXPONENT}{SIGN}?{DIGIT_SEQ}
FRAC_CONST					{DIGIT_SEQ}?\.{DIGIT_SEQ}|{DIGIT_SEQ}\.

LINE_COMMENT				\/\/[^\n]*
BLOCK_COMMENT				\/\*
IDENTIFIER					{LETTER_}({LETTER_}|{DIGIT})*
INT_CONST					0|{NZDIGIT}{DIGIT}*
FLOAT_CONST					{FRAC_CONST}{EXP_PART}?|{DIGIT_SEQ}{EXP_PART}
ENUM_CONST					{IDENTIFIER}
CHAR_CONST					\'{C_CHAR_SEQ}\'
STRING_LITERAL				\"{S_CHAR_SEQ}\"
/* PUNCTUATOR					<<=|>>=|->|\+\+|--|<<|>>|<=|>=|==|!=|&&|\.\.\.|\*=|\/=|%=|\+=|-=|&=|\^=|\|\||\|=|[[\](){}.+\-*\/&~!%<>\^|?:;,#=] */

%%

"auto"						{ return AUTO; }
"enum"						{ return ENUM; }
"restrict"					{ return RESTRICT; }
"unsigned"					{ return UNSIGNED; }
"break"						{ return BREAK; }
"extern"					{ return EXTERN; }
"return"					{ return RETURN; }
"void"						{ return VOID; }
"case"						{ return CASE; }
"float"						{ return FLOAT; }
"short"						{ return SHORT; }
"volatile"					{ return VOLATILE; }
"char"						{ return CHAR; }
"for"						{ return FOR; }
"signed"					{ return SIGNED; }
"while"						{ return WHILE; }
"const"						{ return CONST; }
"goto"						{ return GOTO; }
"sizeof"					{ return SIZEOF; }
"_Bool"						{ return _BOOL; }
"continue"					{ return CONTINUE; }
"if"						{ return IF; }
"static"					{ return STATIC; }
"_Complex"					{ return _COMPLEX; }
"default"					{ return DEFAULT; }
"inline"					{ return INLINE; }
"struct"					{ return STRUCT; }
"_Imaginary"				{ return _IMAGINARY; }
"do"						{ return DO; }
"int"						{ return INT; }
"switch"					{ return SWITCH; }
"double"					{ return DOUBLE; }
"long"						{ return LONG; }
"typedef"					{ return TYPEDEF; }
"else"						{ return ELSE; }
"register"					{ return REGISTER; }
"union"						{ return UNION;  }

{LINE_COMMENT}				{;}
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
											break;
										}	/* found the end */
									}
								}
							}

{IDENTIFIER}				{ return IDENTIFIER; }
{INT_CONST}					{ return INTEGER_CONSTANT; }
{FLOAT_CONST}				{ return FLOATING_CONSTANT; }
{ENUM_CONST}				{ return ENUMERATION_CONSTANT; }
{CHAR_CONST}				{ return CHARACTER_CONSTANT; }
{STRING_LITERAL}			{ return STRING_LITERAL; }
[ \t]						{;}
[\r]?[\n]					{ printf("\n"); }
.							{ printf("Unknown token `%s` found on line %d\n", yytext, yylineno); return ERROR; }

%%
