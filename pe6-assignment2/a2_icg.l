/* ============================================================
   a2_icg.l  —  Lexer for Assignment 2 (Extended PE6):
                ICG for if-else and do-while statements

   Compile:
       flex  -o a2_icg.lex.c  a2_icg.l
       bison -d -o a2_icg.tab.c a2_icg.y
       gcc   -o a2_icg  a2_icg.tab.c a2_icg.lex.c -lfl
   ============================================================ */
%{
#include "a2_icg.tab.h"
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
