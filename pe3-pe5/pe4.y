%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex();

int sym[26];
int declared[26] = {0};
%}

%union {
    int val;
    int idx;
}

%token <val> NUM
%token <idx> VAR
%type <val> expr

%left '+' '-'
%left '*' '/'

%%
stmts: stmts stmt | stmt ;
stmt: VAR '=' expr ',' { sym[$1] = $3; declared[$1] = 1; printf("Updated %c = %d\n", $1+'a', $3); }
    | VAR '=' expr '.' { sym[$1] = $3; declared[$1] = 1; printf("Updated %c = %d\n", $1+'a', $3); }
    | VAR '=' expr     { sym[$1] = $3; declared[$1] = 1; printf("Updated %c = %d\n", $1+'a', $3); }
    ;

expr: expr '+' expr { $$ = $1 + $3; }
    | expr '-' expr { $$ = $1 - $3; }
    | expr '*' expr { $$ = $1 * $3; }
    | expr '/' expr { $$ = $1 / $3; }
    | '(' expr ')'  { $$ = $2; }
    | NUM           { $$ = $1; }
    | VAR           {
                        if (!declared[$1]) {
                            printf("Error: Variable '%c' not declared!\n", $1+'a');
                            $$ = 0;
                        } else {
                            $$ = sym[$1];
                        }
                    }
    ;
%%

void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }
int main() { printf("Enter expressions (e.g., a=5,b=8,c=9,d=a+b*c.):\n"); yyparse(); return 0; }
