%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();
extern int yylineno;

int scope_level = 0; // 0=Global, 1=Function, 2+=Nested Blocks

struct Symbol {
    char name[30];
    char kind[20];
    char type[20];
    char storage[20];
    int size;
    int scope;
    int line, col;
    char file[20];
    char init_val[20];
} sym_table[100];

int sym_count = 0;

void add_sym(char *name, char *kind, char *type, char *storage, int col, char *init) {
    strcpy(sym_table[sym_count].name, name);
    strcpy(sym_table[sym_count].kind, kind);
    strcpy(sym_table[sym_count].type, type);
    strcpy(sym_table[sym_count].storage, (storage && strlen(storage) > 0) ? storage : "auto");

    if(strcmp(type, "int") == 0 || strcmp(type, "float") == 0) sym_table[sym_count].size = 4;
    else if(strcmp(type, "double") == 0) sym_table[sym_count].size = 8;
    else if(strcmp(type, "char") == 0) sym_table[sym_count].size = 1;
    else sym_table[sym_count].size = 0; // void

    sym_table[sym_count].scope = scope_level;
    sym_table[sym_count].line = yylineno;
    sym_table[sym_count].col = col;
    strcpy(sym_table[sym_count].file, "main.c");
    strcpy(sym_table[sym_count].init_val, init ? init : "null");

    sym_count++;
}
%}

%union {
    char* str;
    struct { char* name; int col; } id_info;
}

%token <str> STORAGE TYPE NUM
%token <id_info> ID
%type <str> opt_storage

%%
program: list {
            printf("\n%-10s %-10s %-10s %-10s %-5s %-10s %-15s %-10s\n",
                "Name", "Kind", "Type", "Storage", "Size", "Scope(Lvl)", "Loc(L:C:File)", "InitVal");
            printf("----------------------------------------------------------------------------------------\n");
            for(int i=0; i<sym_count; i++)
                printf("%-10s %-10s %-10s %-10s %-5d %-10d %d:%d:%-8s %-10s\n",
                    sym_table[i].name, sym_table[i].kind, sym_table[i].type,
                    sym_table[i].storage, sym_table[i].size, sym_table[i].scope,
                    sym_table[i].line, sym_table[i].col, sym_table[i].file, sym_table[i].init_val);
         };

list: item list | /* empty */ ;

item: opt_storage TYPE ID ';'
        { add_sym($3.name, "variable", $2, $1, $3.col, NULL); }
    | opt_storage TYPE ID '=' NUM ';'
        { add_sym($3.name, "variable", $2, $1, $3.col, $5); }
    | opt_storage TYPE ID '=' ID ';'
        { add_sym($3.name, "variable", $2, $1, $3.col, $5.name); }
    | opt_storage TYPE ID '(' ')'
        { add_sym($3.name, "function", $2, $1, $3.col, NULL); scope_level++; } '{' list '}' { scope_level--; }
    | opt_storage TYPE ID '(' TYPE ID ')'
        { add_sym($3.name, "function", $2, $1, $3.col, NULL); scope_level++;
          add_sym($6.name, "parameter", $5, "auto", $6.col, NULL); } '{' list '}' { scope_level--; }
    | '{'
        { scope_level++; } list '}' { scope_level--; }
    ;

opt_storage: STORAGE { $$ = $1; } | /* empty */ { $$ = ""; } ;

%%

void yyerror(const char *s) { fprintf(stderr, "Error at line %d: %s\n", yylineno, s); }
int main() { printf("Enter C code (Ctrl+D to finish):\n"); yyparse(); return 0; }
