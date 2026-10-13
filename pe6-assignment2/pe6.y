/* ============================================================
   pe6.y  —  Parser for PE6: Intermediate Code Generation
             for arithmetic expressions and assignment statements.
             Prints each IC instruction as a quadruple:
                 (op, arg1, arg2, result)

   Grammar:
       line  → T_ID '=' expr '\n'
              | expr '\n'
       expr  → expr op expr | '(' expr ')' | T_ID | NUM

   Compile:
       bison -d -o pe6.tab.c pe6.y
       flex  -o pe6.lex.c  pe6.l
       gcc   -o pe6  pe6.tab.c pe6.lex.c -lfl
   Run:
       ./pe6
       x = a + b * c    <Enter>
   ============================================================ */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int  yylex();

/* ─── Quadruple table ─────────────────────────────────── */
#define MAX_QUADS 200

typedef struct {
    char op[8];
    char arg1[32];
    char arg2[32];
    char result[32];
} Quad;

Quad quads[MAX_QUADS];
int  quad_count = 0;

/* ─── Temporary variable generator ───────────────────── */
int temp_count = 0;

char *new_temp() {
    char *t = (char *)malloc(16);
    sprintf(t, "t%d", ++temp_count);
    return t;
}

/* Emit a binary-op quad and return the result temp name */
char *emit(const char *op, const char *arg1, const char *arg2) {
    char *res = new_temp();
    strcpy(quads[quad_count].op,     op);
    strcpy(quads[quad_count].arg1,   arg1 ? arg1 : "");
    strcpy(quads[quad_count].arg2,   arg2 ? arg2 : "");
    strcpy(quads[quad_count].result, res);
    quad_count++;
    return res;
}

/* Emit an assignment quad:  result = arg1 */
void emit_assign(const char *result, const char *arg1) {
    strcpy(quads[quad_count].op,     "=");
    strcpy(quads[quad_count].arg1,   arg1);
    strcpy(quads[quad_count].arg2,   "");
    strcpy(quads[quad_count].result, result);
    quad_count++;
}

/* Print the full quadruple table */
void print_quads() {
    printf("\n%-4s %-6s %-12s %-12s %-12s\n",
           "No.", "op", "arg1", "arg2", "result");
    printf("--------------------------------------------\n");
    for (int i = 0; i < quad_count; i++)
        printf("%-4d (%-6s, %-12s, %-12s, %-12s)\n",
               i + 1,
               quads[i].op,
               quads[i].arg1,
               quads[i].arg2,
               quads[i].result);
}
%}

/* ─── Token / type declarations ──────────────────────── */
%union {
    char *str;
}

%token <str> T_ID NUM
%type  <str> expr

%right '='
%left  '+' '-'
%left  '*' '/'

%%

/* ─── Grammar rules ───────────────────────────────────── */

input : /* empty */
      | input line
      ;

line  : '\n'
      | T_ID '=' expr '\n'
            {
                emit_assign($1, $3);
                printf("\n--- Three-Address Code (Quadruples) ---");
                print_quads();
                /* reset counters for next statement */
                quad_count = 0;
                temp_count = 0;
            }
      | expr '\n'
            {
                printf("\n--- Three-Address Code (Quadruples) ---");
                print_quads();
                quad_count = 0;
                temp_count = 0;
            }
      ;

expr  : expr '+' expr  { $$ = emit("+", $1, $3); }
      | expr '-' expr  { $$ = emit("-", $1, $3); }
      | expr '*' expr  { $$ = emit("*", $1, $3); }
      | expr '/' expr  { $$ = emit("/", $1, $3); }
      | '(' expr ')'   { $$ = $2; }
      | T_ID            { $$ = $1; }
      | NUM             { $$ = $1; }
      ;

%%

void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }

int main() {
    printf("Enter assignment / arithmetic expression (e.g.  x = a + b * c):\n");
    yyparse();
    return 0;
}
