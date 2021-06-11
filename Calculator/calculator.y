%{
#include <stdlib.h>
#include <stdio.h>
extern "C" {
	#include "expr_list.h"
	int yylex();
}
void yyerror(const char*);
extern int yy_flex_debug;
float *stmts;
void print(ExprList* exprs);
%}

// Support for integer and floating point operands
%union {
	int ival;
	float fval;
	ExprList *exprs;
}

// Assign tokens to member of union
%token <ival> INTEGER
%token <fval> FLOAT
%type <fval> expr
%type <exprs> expr_list;
// Associativity
%left '-' '+'
%left '*' '/'

%%

// Formal grammar
program:	
	expr_list '\n'			
		{
			print($1);
			expr_list_free($1);
		}
	| program expr_list '\n'
		{
			print($2);
			expr_list_free($2);
		}
	;

expr_list:
	expr ';'
		{
			$$ = expr_list_create(1);
			expr_list_push($$, $1);
		}
	| expr_list expr ';'
		{
			$$ = $1;
			expr_list_push($1, $2);
		}
	| error ';'				
		{
			$$ = expr_list_create(1);
		}
	| expr_list error ';'	{ $$ = $1; }	// Do nothing (ignore bad stmt)
	;

expr:
	INTEGER			{ $$ = $1; }
	| FLOAT			{ $$ = $1; }
	| '-' expr		{ $$ = 0 - $2; }
	| expr '-' expr	{ $$ = $1 - $3; }
	| expr '+' expr { $$ = $1 + $3; }
	| expr '*' expr { $$ = $1 * $3; }
	| expr '/' expr { $$ = $1 / $3; }
	| '(' expr ')'	{ $$ = $2; }
	;

%%

void yyerror(const char* msg){
	fprintf(stderr, "ERROR: %s\n", msg);
}

void print(ExprList* exprs){
	for (float* p = exprs->data; p < exprs->data + expr_list_length(exprs); p++) {
		printf("Result: %g\n", *p);
	}
}

int main(void){
	// Explicitly disable lex tracing
	yy_flex_debug = 1;
	yydebug = 0;
	yyparse();
	return 0;
}
