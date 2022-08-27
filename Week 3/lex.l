%{
	/* C headers */
	#include "def.h"
%}

/* Regular Expression Definitions */
LETTER						[a-zA-Z]
LETTER_						{LETTER}|_
DIGIT						[0-9]
NZDIGIT 					[1-9]
DIGIT_SEQ					{DIGIT}+
EXPONENT					[Ee]
SIGN						[+-]
ESC_SEQ						[\\\']|[\\\"]|[\\\?]|[\\\\]|[\\a]|[\\b]|[\\f]|[\\n]|[\\r]|[\\t]|[\\v]
C_CHAR						[^\'\\\n]|{ESC_SEQ}
C_CHAR_SEQ					{C_CHAR}+
S_CHAR						[^\"\\\n]|{ESC_SEQ}
S_CHAR_SEQ					{S_CHAR}+

EXP_PART					{EXPONENT}{SIGN}{DIGIT_SEQ}
FRAC_CONST					{DIGIT_SEQ}?\.{DIGIT_SEQ}|{DIGIT_SEQ}\.

LINE_COMMENT				"//"[^\n]
BLOCK_COMMENT				"/*".*"*/"
IDENTIFIER					{LETTER_}({LETTER_}|{DIGIT})*
INT_CONST					{NZDIGIT}{DIGIT}*
FLOAT_CONST					{FRAC_CONST}{EXP_PART}?|{DIGIT_SEQ}{EXP_PART}
ENUM_CONST					{IDENTIFIER}
CHAR_CONST					\'{C_CHAR_SEQ}\'
STRING_LITERAL				\"{S_CHAR_SEQ}\"
PUNCTUATOR					<<=|>>=|->|\+\+|--|<<|>>|<=|>=|==|!=|&&|\.\.\.|\*=|\/=|%=|\+=|-=|&=|\^=|\|\||\|=|[[\](){}.+\-*\/&~!%<>\^|?:;,#=]

%%

{LINE_COMMENT}				{printf("< LINE COMMENT >");}
{BLOCK_COMMENT}				{printf("< BLOCK COMMENT >");}
{IDENTIFIER}				{printf("< IDENTIFIER , %s >", yytext);}
{INT_CONST}					{printf("< INTEGER CONSTANT , %s >", yytext);}
{FLOAT_CONST}				{printf("< FLOAT CONSTANT , %s >", yytext);}
{ENUM_CONST}				{printf("< ENUMERATION CONSTANT , %s >", yytext);}
{CHAR_CONST}				{printf("< CHARACTER CONSTANT , %s >", yytext);}
{STRING_LITERAL}			{printf("< STRING LITERAL , %s >", yytext);}
{PUNCTUATOR}				{printf("< PUNCTUATION , %s >", yytext);}
[ \t]						{printf(" ");}
[\n]						{printf("\n");}


%%

int main()
{
	yylex();
}
