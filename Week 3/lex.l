{%
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

IDENTIFIER					{LETTER_}({LETTER_|DIGIT})*
INT_CONST					{NZDIGIT}{DIGIT}*
FLOAT_CONST					{FRAC_CONST}{EXP_PART}?|{DIGIT_SEQ}{EXP_PART}
ENUM_CONST					{IDENTIFIER}
CHAR_CONST					\'{C_CHAR_SEQ}\'
STRING_LITERAL				\"{S_CHAR_SEQ}\"
PUNCTUATORt					[[\](){}.+\-*/&~!%<>\^|?:;,#]|->|\+\+|--|<<|>>|<=|>=|==|!=|&&|\.\.\.|\*=|/=|%=|\+=|-=|<<=|>>=|&=|\^=|\|\||\|=

%%


%%

