/* ============================================================
   pe6.l  —  Lexer for PE6: ICG for arithmetic expressions
                             and assignment statements
   Compile:
       flex  -o pe6.lex.c  pe6.l
       bison -d -o pe6.tab.c pe6.y
       gcc   -o pe6  pe6.tab.c pe6.lex.c -lfl
   ============================================================ */
%{
#include "pe6.tab.h"
#include <string.h>
%}

%%
[a-zA-Z][a-zA-Z0-9]*   { yylval.str = strdup(yytext); return T_ID; }
[0-9]+                  { yylval.str = strdup(yytext); return NUM;  }
"="                     { return '='; }
"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"("                     { return '('; }
")"                     { return ')'; }
[ \t]                   ;       /* ignore whitespace */
\n                      { return '\n'; }
.                       { return yytext[0]; }
%%

int yywrap() { return 1; }
