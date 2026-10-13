%{
#include "pe5.tab.h"
#include <string.h>
%}

%%
[0-9]+      { yylval.str = strdup(yytext); return NUM; }
[ \t]       ; /* Ignore */
\n          { return '\n'; }
.           { return yytext[0]; }
%%
int yywrap() { return 1; }
