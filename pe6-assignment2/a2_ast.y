/* ============================================================
   a2_ast.y  —  Parser for Assignment 2 (Extended PE5):
                AST construction for if-else and do-while.

   Productions supported:
       S  → T_ID '=' expr ';'
          | if (C) {S} else {S}
          | do {S} while (C) ;
       C  → T_ID rel T_ID
       rel → < | > | <= | >= | == | !=

   Output:
     1. Indented AST tree
     2. Postorder (RPN) traversal

   Compile:
       bison -d -o a2_ast.tab.c a2_ast.y
       flex  -o a2_ast.lex.c  a2_ast.l
       gcc   -o a2_ast  a2_ast.tab.c a2_ast.lex.c -lfl
   Run:
       ./a2_ast
       if (x < y) { z = a + b; } else { z = a - b; }
       do { x = x + 1; } while (x < n);
   ============================================================ */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int  yylex();

/* ─── AST Node ────────────────────────────────────────── */
typedef struct Node {
    char        *val;
    struct Node *left;
    struct Node *mid;    /* 'else' branch for if-else node */
    struct Node *right;
} Node;

Node *make_node(const char *val, Node *left, Node *mid, Node *right) {
    Node *n = (Node *)malloc(sizeof(Node));
    n->val   = strdup(val);
    n->left  = left;
    n->mid   = mid;
    n->right = right;
    return n;
}

/* ─── Indented AST print ──────────────────────────────── */
void print_ast(Node *root, int depth) {
    if (!root) return;
    for (int i = 0; i < depth; i++) printf("  ");
    printf("%s\n", root->val);
    print_ast(root->left,  depth + 1);
    print_ast(root->mid,   depth + 1);
    print_ast(root->right, depth + 1);
}

/* ─── Postorder traversal ─────────────────────────────── */
void print_postorder(Node *root) {
    if (!root) return;
    print_postorder(root->left);
    print_postorder(root->mid);
    print_postorder(root->right);
    printf("%s ", root->val);
}
%}

/* ─── Token / type declarations ──────────────────────── */
%union {
    char        *str;
    struct Node *node;
}

%token <str>  T_ID NUM REL
%token        IF ELSE DO WHILE

%type <node>  program stmt_list stmt expr cond

%right '='
%left  '+' '-'
%left  '*' '/'

%%

/* ─── Grammar rules ───────────────────────────────────── */

program : stmt_list
            {
                printf("\n=== AST (indented) ===\n");
                print_ast($1, 0);
                printf("\n=== Postorder Traversal ===\n");
                print_postorder($1);
                printf("\n");
            }
        ;

stmt_list : stmt
                { $$ = $1; }
          | stmt_list stmt
                { $$ = make_node("SEQ", $1, NULL, $2); }
          ;

/* ─── S → assignment ─── */
stmt : T_ID '=' expr ';'
            {
                $$ = make_node("=",
                               make_node($1, NULL, NULL, NULL),
                               NULL,
                               $3);
            }

/* ─── S → if (C) {S} else {S} ─── */
     | IF '(' cond ')' '{' stmt_list '}' ELSE '{' stmt_list '}'
            {
                /*  Node layout:
                      if-else
                      ├─ left  : condition
                      ├─ mid   : then-branch
                      └─ right : else-branch          */
                $$ = make_node("if-else", $3, $6, $10);
            }

/* ─── S → do {S} while (C); ─── */
     | DO '{' stmt_list '}' WHILE '(' cond ')' ';'
            {
                /*  Node layout:
                      do-while
                      ├─ left  : body
                      └─ right : condition            */
                $$ = make_node("do-while", $3, NULL, $7);
            }
     ;

/* ─── C → T_ID rel T_ID ─── */
cond : T_ID REL T_ID
            {
                $$ = make_node($2,
                               make_node($1, NULL, NULL, NULL),
                               NULL,
                               make_node($3, NULL, NULL, NULL));
            }
     ;

/* ─── Arithmetic expressions ──────────────────────────── */
expr : expr '+' expr  { $$ = make_node("+", $1, NULL, $3); }
     | expr '-' expr  { $$ = make_node("-", $1, NULL, $3); }
     | expr '*' expr  { $$ = make_node("*", $1, NULL, $3); }
     | expr '/' expr  { $$ = make_node("/", $1, NULL, $3); }
     | '(' expr ')'   { $$ = $2; }
     | T_ID            { $$ = make_node($1, NULL, NULL, NULL); }
     | NUM             { $$ = make_node($1, NULL, NULL, NULL); }
     ;

%%

void yyerror(const char *s) { fprintf(stderr, "Syntax Error: %s\n", s); }

int main() {
    printf("Enter statements (assignments, if-else, do-while):\n");
    printf("End input with EOF (Ctrl+D / Ctrl+Z).\n\n");
    yyparse();
    return 0;
}
