/* ============================================================
   a2_icg.y  —  Parser for Assignment 2 (Extended PE6):
                Three-Address Intermediate Code Generation
                for if-else and do-while statements.
                Prints each IC instruction as a quadruple:
                    (op, arg1, arg2, result)

   Productions supported:
       S   → T_ID '=' expr ';'
           | if (C) {S} else {S}
           | do {S} while (C) ;
       C   → T_ID rel T_ID
       rel → < | > | <= | >= | == | !=

   ICG strategy:
     if-else  → ifFalse<rel> jumps to else-label; goto jumps to end-label
                (backpatched after parsing each branch)
     do-while → label emitted before body; if<rel> jumps back to label

   Compile:
       bison -d -o a2_icg.tab.c a2_icg.y
       flex  -o a2_icg.lex.c  a2_icg.l
       gcc   -o a2_icg  a2_icg.tab.c a2_icg.lex.c -lfl
   Run:
       ./a2_icg
       x = a + b;
       if (x >= y) { z = x * 2; } else { z = y - x; }
       do { i = i + 1; } while (i != n);
       <Ctrl+D>
   ============================================================ */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int  yylex();

/* ─── Quadruple table ─────────────────────────────────── */
#define MAX_QUADS 500

typedef struct {
    char op[16];
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

/* ─── Label generator ─────────────────────────────────── */
int label_count = 0;

char *new_label() {
    char *l = (char *)malloc(16);
    sprintf(l, "L%d", ++label_count);
    return l;
}

/* ─── Core emit function ──────────────────────────────── */
/* Appends one quad to the table; returns its index. */
int emit_quad(const char *op, const char *arg1,
              const char *arg2, const char *result) {
    strcpy(quads[quad_count].op,     op);
    strcpy(quads[quad_count].arg1,   arg1   ? arg1   : "");
    strcpy(quads[quad_count].arg2,   arg2   ? arg2   : "");
    strcpy(quads[quad_count].result, result ? result : "");
    return quad_count++;
}

/* Emit binary-op quad; return new temp name */
char *emit_binop(const char *op, const char *a1, const char *a2) {
    char *t = new_temp();
    emit_quad(op, a1, a2, t);
    return t;
}

/* Emit:  result = rhs */
void emit_assign(const char *lhs, const char *rhs) {
    emit_quad("=", rhs, "", lhs);
}

/* Emit a label pseudo-instruction */
void emit_label(const char *label) {
    emit_quad("label", "", "", label);
}

/* ─── Backpatch ───────────────────────────────────────── */
/* Fill in the jump target of quad[idx] after the target label is known */
void backpatch(int idx, const char *label) {
    strcpy(quads[idx].result, label);
}

/* ─── Print quadruple table ───────────────────────────── */
void print_quads() {
    printf("\n%-4s %-12s %-14s %-14s %-14s\n",
           "No.", "op", "arg1", "arg2", "result");
    printf("------------------------------------------------------------\n");
    for (int i = 0; i < quad_count; i++)
        printf("%-4d (%-12s, %-14s, %-14s, %-14s)\n",
               i + 1,
               quads[i].op,
               quads[i].arg1,
               quads[i].arg2,
               quads[i].result);
}

/* ─── Simple stacks for backpatching ─────────────────── */

/* Stack 1: index of the ifFalse jump in if-else */
static int jmp_stack[64];
static int jmp_top = 0;
void _push_jmp(int idx)  { jmp_stack[jmp_top++] = idx; }
int  _pop_jmp()          { return jmp_stack[--jmp_top]; }

/* Stack 2: index of the unconditional goto at end of then-branch */
static int jmp2_stack[64];
static int jmp2_top = 0;
void _push_jmp2(int idx) { jmp2_stack[jmp2_top++] = idx; }
int  _pop_jmp2()         { return jmp2_stack[--jmp2_top]; }

/* Stack 3: do-while loop-start label */
static char *do_stack[64];
static int   do_top = 0;
void  _push_do_label(char *l) { do_stack[do_top++] = l; }
char *_pop_do_label()         { return do_stack[--do_top]; }
%}

/* ─── Token / type declarations ──────────────────────── */
%union {
    char *str;
    struct { char *id1; char *rel; char *id2; } cond;
}

%token <str>  T_ID NUM REL
%token        IF ELSE DO WHILE

%type <str>   expr
%type <cond>  cond

%right '='
%left  '+' '-'
%left  '*' '/'

%%

/* ─── Grammar rules ───────────────────────────────────── */

program : stmt_list
            {
                printf("\n=== Three-Address Code (Quadruples) ===");
                print_quads();
            }
        ;

stmt_list : stmt
          | stmt_list stmt
          ;

/* ── S → T_ID = expr ; ──────────────────────────────── */
stmt : T_ID '=' expr ';'
            {
                emit_assign($1, $3);
            }

/* ── S → if (C) {S1} else {S2}  ─────────────────────
 *
 *  Generated code pattern:
 *      ifFalse<rel>  id1, id2,  L_false    ← quad[idx] (backpatched)
 *      <S1 code>
 *      goto          -, -,      L_end      ← quad[goto_idx] (backpatched)
 *  L_false:  (label quad)
 *      <S2 code>
 *  L_end:    (label quad)
 * ─────────────────────────────────────────────────── */
     | IF '(' cond ')' '{'
            {
                /* Emit ifFalse jump with placeholder target "?" */
                char op[20];
                sprintf(op, "ifFalse%s", $3.rel);
                int idx = emit_quad(op, $3.id1, $3.id2, "?");
                _push_jmp(idx);          /* remember for backpatch */
            }
       stmt_list '}'
            {
                /* End of then-branch: emit unconditional jump to L_end */
                int goto_idx = emit_quad("goto", "", "", "?");
                _push_jmp2(goto_idx);

                /* Now we know where the else-branch starts → backpatch ifFalse */
                char *lf = new_label();
                emit_label(lf);
                backpatch(_pop_jmp(), lf);
            }
       ELSE '{' stmt_list '}'
            {
                /* End of else-branch: emit L_end and backpatch the goto */
                char *le = new_label();
                emit_label(le);
                backpatch(_pop_jmp2(), le);
            }

/* ── S → do {S} while (C) ;  ────────────────────────
 *
 *  Generated code pattern:
 *  L_start:  (label quad)
 *      <S code>
 *      if<rel>  id1, id2,  L_start
 * ─────────────────────────────────────────────────── */
     | DO
            {
                /* Emit loop-start label before parsing the body */
                char *ls = new_label();
                emit_label(ls);
                _push_do_label(ls);
            }
       '{' stmt_list '}' WHILE '(' cond ')' ';'
            {
                char *ls = _pop_do_label();
                char op[20];
                sprintf(op, "if%s", $8.rel);
                emit_quad(op, $8.id1, $8.id2, ls);
            }
     ;

/* ── C → T_ID rel T_ID ───────────────────────────── */
cond : T_ID REL T_ID
            {
                $$.id1 = $1;
                $$.rel = $2;
                $$.id2 = $3;
            }
     ;

/* ── Arithmetic expressions ──────────────────────── */
expr : expr '+' expr  { $$ = emit_binop("+", $1, $3); }
     | expr '-' expr  { $$ = emit_binop("-", $1, $3); }
     | expr '*' expr  { $$ = emit_binop("*", $1, $3); }
     | expr '/' expr  { $$ = emit_binop("/", $1, $3); }
     | '(' expr ')'   { $$ = $2; }
     | T_ID            { $$ = $1; }
     | NUM             { $$ = $1; }
     ;

%%

void yyerror(const char *s) { fprintf(stderr, "Syntax Error: %s\n", s); }

int main() {
    printf("Enter statements (assignments, if-else, do-while):\n");
    printf("End with EOF (Ctrl+D / Ctrl+Z).\n\n");
    yyparse();
    return 0;
}
