%{
#include "pe3.tab.h"
#include <string.h>
int col_num = 1;
%}
%option yylineno

%%
"auto"|"static"|"extern"|"register" { yylval.str = strdup(yytext); col_num += yyleng; return STORAGE; }
"int"|"float"|"char"|"void"|"double" { yylval.str = strdup(yytext); col_num += yyleng; return TYPE; }
[0-9]+(\.[0-9]+)?                   { yylval.str = strdup(yytext); col_num += yyleng; return NUM; }
[a-zA-Z_][a-zA-Z0-9_]* {
                                        yylval.id_info.name = strdup(yytext);
                                        yylval.id_info.col = col_num;
                                        col_num += yyleng;
                                        return ID;
                                    }
\n                                  { col_num = 1; }
[ \t]                               { col_num += yyleng; }
.                                   { col_num++; return yytext[0]; }
%%
int yywrap() { return 1; }
