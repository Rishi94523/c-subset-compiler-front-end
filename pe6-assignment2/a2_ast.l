/* ============================================================
   a2_ast.l  —  Lexer for Assignment 2 (Extended PE5):
                AST construction for if-else and do-while

   Compile:
       flex  -o a2_ast.lex.c  a2_ast.l
       bison -d -o a2_ast.tab.c a2_ast.y
       gcc   -o a2_ast  a2_ast.tab.c a2_ast.lex.c -lfl
   ============================================================ */
%{
#include "a2_ast.tab.h"
#include <string.h>
%}

%%
"if"                    { return IF;   }
"else"                  { return ELSE; }
"do"                    { return DO;   }
"while"                 { return WHILE;}

"<="                    { yylval.str = strdup(yytext); return REL; }
">="                    { yylval.str = strdup(yytext); return REL; }
"=="                    { yylval.str = strdup(yytext); return REL; }
"!="                    { yylval.str = strdup(yytext); return REL; }
"<"                     { yylval.str = strdup(yytext); return REL; }
">"                     { yylval.str = strdup(yytext); return REL; }

[a-zA-Z][a-zA-Z0-9]*   { yylval.str = strdup(yytext); return T_ID; }
[0-9]+                  { yylval.str = strdup(yytext); return NUM;  }

"="                     { return '='; }
"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"("                     { return '('; }
")"                     { return ')'; }
"{"                     { return '{'; }
"}"                     { return '}'; }
";"                     { return ';'; }
[ \t\n]                 ;       /* ignore whitespace */
.                       { return yytext[0]; }
%%

int yywrap() { return 1; }
