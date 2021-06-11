%option noyywrap

%{
#include <stdlib.h>
#include "expr_list.h"
#include "calculator.tab.h"
#define YY_DECL extern "C" int yylex()
void yyerror(const char*);
%}

digit	[0-9]

%%

{digit}+				{ 
							yylval.ival = atoi(yytext);
							return INTEGER;
						}
{digit}+(\.){digit}+	{
							yylval.fval = atof(yytext);
							return FLOAT;
						}
[-+*/\n();]				{
							return *yytext;
						}
[ \t]+					;
.						{
							/* Change to return *yytext - allows parser to handle syntax error and attempt recovery */
							yyerror("Unrecognised character.");
						}

%%
