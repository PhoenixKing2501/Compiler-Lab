%{
	/* C headers */
	#include "def.h"
	#include "ass5_20CS10063_20CS30057.tab.h"

	#include <string.h>
%}

%option yylineno
%option nounput

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
CHAR_CONST					\'{C_CHAR_SEQ}\'
STRING_LITERAL				\"{S_CHAR_SEQ}\"

%%

"auto"						{ return AUTO; }
"enum"						{ return ENUM; }
"restrict"					{ return RESTRICT; }
"unsigned"					{ return UNSIGNED; }
"break"						{ return BREAK; }
"extern"					{ return EXTERN; }
"return"					{ return RETURN; }
"void"						{ return KEY_VOID; }
"case"						{ return CASE; }
"float"						{ return KEY_FLOAT; }
"short"						{ return SHORT; }
"volatile"					{ return VOLATILE; }
"char"						{ return KEY_CHAR; }
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
"int"						{ return KEY_INT; }
"switch"					{ return SWITCH; }
"double"					{ return DOUBLE; }
"long"						{ return LONG; }
"typedef"					{ return TYPEDEF; }
"else"						{ return ELSE; }
"register"					{ return REGISTER; }
"union"						{ return UNION;  }

"..."						{ return ELLIPSIS; }
"<<="						{ return LEFT_SHIFT_ASSIGNMENT; }
">>="						{ return RIGHT_SHIFT_ASSIGNMENT; }
"++"						{ return INCREMENT; }
"--"						{ return DECREMENT; }
"->"						{ return ARROW; }
"<<"						{ return LEFT_SHIFT; }
">>"						{ return RIGHT_SHIFT; }
"*="						{ return STAR_ASSIGNMENT; }
"/="						{ return FRONT_SLASH_ASSIGNMENT; }
"%="						{ return MODULO_ASSIGNMENT; }
"+="						{ return PLUS_ASSIGNMENT; }
"-="						{ return MINUS_ASSIGNMENT; }
"<="						{ return LESS_THAN_EQUAL_TO; }
">="						{ return GREATER_THAN_EQUAL_TO; }
"=="						{ return EQUAL_TO; }
"&&"						{ return LOGICAL_AND; }
"||"						{ return LOGICAL_OR; }
"!="						{ return NOT_EQUAL_TO; }
"&="						{ return BITWISE_AND_ASSIGNMENT; }
"|="						{ return BITWISE_OR_ASSIGNMENT; }
"^="						{ return BITWISE_XOR_ASSIGNMENT; }

"["							{ return LEFT_SQUARE_BRACKET; }
"]"							{ return RIGHT_SQUARE_BRACKET; }
"/"							{ return FRONT_SLASH; }
"?"							{ return QUESTION_MARK; }
"="							{ return ASSIGNMENT; }
","							{ return COMMA; }
"("							{ return LEFT_PARENTHESES; }
"{"							{ return LEFT_BRACE; }
"}"							{ return RIGHT_BRACE; }
"."							{ return DOT; }
"*"							{ return STAR; }
"+"							{ return PLUS; }
"-"							{ return MINUS; }
"~"							{ return TILDE; }
"!"							{ return EXCLAMATION; }
"%"							{ return MODULO; }
"<"							{ return LESS_THAN; }
">"							{ return GREATER_THAN; }
":"							{ return COLON; }
";"							{ return SEMI_COLON; }
"#"							{ return HASH; }
")"							{ return RIGHT_PARENTHESES; }
"&"							{ return BITWISE_AND; }
"|"							{ return BITWISE_OR; }
"^"							{ return BITWISE_XOR; }

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

{IDENTIFIER}				{ yylval.symbol = currentTable->lookup(yytext);	return IDENTIFIER; }
{INT_CONST}					{ yylval.intVal = atoi(yytext);					return INTEGER_CONSTANT; }
{FLOAT_CONST}				{ strcpy(yylval.floatVal, yytext);				return FLOATING_CONSTANT; }
{CHAR_CONST}				{ strcpy(yylval.charVal, yytext);				return CHARACTER_CONSTANT; }
{STRING_LITERAL}			{ strcpy(yylval.stringVal, yytext);				return STRING_LITERAL; }
[ \t]						{;}
[\r]?[\n]					{ printf("\n"); }
.							{ printf("Unknown token on line %d: %s\n", yylineno, yytext); return YYUNDEF; }

%%
