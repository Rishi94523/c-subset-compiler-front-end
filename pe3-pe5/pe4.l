%{
#include "pe4.tab.h"
%}

%%
[0-9]+      { yylval.val = atoi(yytext); return NUM; }
[a-z]       { yylval.idx = yytext[0] - 'a'; return VAR; }
[ \t\n]     ; /* Ignore */
.           { return yytext[0]; }
%%
int yywrap() { return 1; }
