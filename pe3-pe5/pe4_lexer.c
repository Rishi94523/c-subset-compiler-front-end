#include <ctype.h>
#include <stdio.h>
#include "pe4.tab.h"

int yylex(void) {
    int c;

    while ((c = getchar()) != EOF) {
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
            continue;
        }

        if (isdigit(c)) {
            int val = c - '0';
            while ((c = getchar()) != EOF && isdigit(c)) {
                val = val * 10 + (c - '0');
            }
            yylval.val = val;
            if (c != EOF) {
                ungetc(c, stdin);
            }
            return NUM;
        }

        if (c >= 'a' && c <= 'z') {
            yylval.idx = c - 'a';
            return VAR;
        }

        return c;
    }

    return 0;
}
