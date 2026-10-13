%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();

typedef struct Node {
    char *val;
    struct Node *left;
    struct Node *right;
} Node;

Node* make_node(char *val, Node *left, Node *right) {
    Node *new_node = (Node*)malloc(sizeof(Node));
    new_node->val = strdup(val);
    new_node->left = left;
    new_node->right = right;
    return new_node;
}

void print_postorder(Node *root) {
    if (root == NULL) return;
    print_postorder(root->left);
    print_postorder(root->right);
    printf("%s ", root->val);
}
%}

%union {
    char *str;
    struct Node *node;
}

%token <str> NUM
%type <node> expr

%left '+' '-'
%left '*' '/'

%%
input: /* empty */
     | input line
     ;

line: '\n'
    | expr '\n' {
        printf("Postorder (RPN): ");
        print_postorder($1);
        printf("\n");
    }
    ;

expr: expr '+' expr { $$ = make_node("+", $1, $3); }
    | expr '-' expr { $$ = make_node("-", $1, $3); }
    | expr '*' expr { $$ = make_node("*", $1, $3); }
    | expr '/' expr { $$ = make_node("/", $1, $3); }
    | '(' expr ')'  { $$ = $2; }
    | NUM           { $$ = make_node($1, NULL, NULL); }
    ;
%%

void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }
int main() { printf("Enter arithmetic expression:\n"); yyparse(); return 0; }
