
//%require "3.7.4"
//%language "c++"
//%define api.value.type variant
//%define api.token.constructor


%{
#include <stdlib.h>
#include <stdio.h>
//#include <stdint.h>
//#include <vector>
extern "C" int yylex();
void yyerror(const char*);
extern int yy_flex_debug;
float *stmts;
void print(float *start, float *end);
%}

// Support for integer and floating point operands
%union {
	int ival;
	float fval;
	float *pstmt;
	bool ignore;
}

// Assign tokens to member of union
%token <ival> INTEGER
%token <fval> FLOAT
%type <fval> expr //stmt
%type <pstmt> stmt_list;
//%type <std::vector<float>> stmt_list;
// Associativity
%left '-' '+'
%left '*' '/'

%%

// Formal grammar
program:	
			stmt_list '\n'			{
										print(stmts, $1);
										free(stmts);
										stmts = NULL;
										/*for (std::vector<float>::iterator it = $1.begin; it != $1.end(); ++it){
											printf("Result: %g\n", *p);
										}*/
									}
			| program stmt_list '\n'	{
										print(stmts, $2);
										free(stmts);
										stmts = NULL;
										/*for (std::vector<float>::iterator it = $2.begin; it != $2.end(); ++it) {
											printf("Result: %g\n", *p);
										}*/
									}
			;

stmt_list:
			expr ';'				{
										// Allocate memory for statement array
										stmts = (float*)malloc(24 * sizeof(float));
										// Assign pointer for array
										$$ = stmts;
										// At pointer, assign statement value
										*$$ = $1; 
										// Increment pointer (for next job)
										$$++;

										//$$ = {$1};

									}
			| stmt_list expr ';'	{
										
										$$ = $1;
										*$$ = $2;
										$$++;
										/*$$ = $1;
										$$.push_back($2);*/
									}
			| error ';'				{
										stmts = (float*) malloc(24 * sizeof(float));
										$$ = stmts;
										//$$ = {};
									}
			| stmt_list error ';'	{ $$ = $1; }	// Do nothing (ignore bad stmt)
			;

/*stmt:
			expr ';'			{ $$ = $1; }
			| error ';'
			;
*/
expr:
			INTEGER		{ $$ = $1; }
			| FLOAT			{ $$ = $1; }
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

void print(float *start, float *end){
	for (float* p = start; p < end; p++) {
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
