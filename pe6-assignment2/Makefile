# ============================================================
#  Makefile — PE6 and Assignment 2 (PE5+PE6 extended)
#
#  Targets:
#    make all      — build pe6, a2_ast, a2_icg
#    make pe6      — PE6 only (arithmetic/assignment ICG)
#    make a2_ast   — Assignment 2 AST (if-else + do-while)
#    make a2_icg   — Assignment 2 ICG (if-else + do-while)
#    make clean    — remove generated files and binaries
# ============================================================

CC      = gcc
CFLAGS  = -Wall -g
LDFLAGS =

.PHONY: all clean pe6 a2_ast a2_icg

all: pe6 a2_ast a2_icg

# ── PE6 ──────────────────────────────────────────────────────
pe6: pe6.tab.c pe6.lex.c
	$(CC) $(CFLAGS) -o pe6 pe6.tab.c pe6.lex.c $(LDFLAGS)

pe6.tab.c pe6.tab.h: pe6.y
	bison -d -o pe6.tab.c pe6.y

pe6.lex.c: pe6.l pe6.tab.h
	flex -o pe6.lex.c pe6.l

# ── Assignment 2 – AST ───────────────────────────────────────
a2_ast: a2_ast.tab.c a2_ast.lex.c
	$(CC) $(CFLAGS) -o a2_ast a2_ast.tab.c a2_ast.lex.c $(LDFLAGS)

a2_ast.tab.c a2_ast.tab.h: a2_ast.y
	bison -d -o a2_ast.tab.c a2_ast.y

a2_ast.lex.c: a2_ast.l a2_ast.tab.h
	flex -o a2_ast.lex.c a2_ast.l

# ── Assignment 2 – ICG ───────────────────────────────────────
a2_icg: a2_icg.tab.c a2_icg.lex.c
	$(CC) $(CFLAGS) -o a2_icg a2_icg.tab.c a2_icg.lex.c $(LDFLAGS)

a2_icg.tab.c a2_icg.tab.h: a2_icg.y
	bison -d -o a2_icg.tab.c a2_icg.y

a2_icg.lex.c: a2_icg.l a2_icg.tab.h
	flex -o a2_icg.lex.c a2_icg.l

# ── Clean ────────────────────────────────────────────────────
clean:
	rm -f pe6 a2_ast a2_icg \
	      pe6.tab.c pe6.tab.h pe6.lex.c \
	      a2_ast.tab.c a2_ast.tab.h a2_ast.lex.c \
	      a2_icg.tab.c a2_icg.tab.h a2_icg.lex.c
