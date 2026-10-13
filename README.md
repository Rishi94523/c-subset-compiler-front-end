# C-Subset Compiler Front End

Compiler Design programming exercises and Assignment 2, **March-April 2026**, PES University.

This repository brings together the C, Flex/LEX, and Bison/YACC source from two coursework packets: `pe345.zip` and `pe 6 a 2.zip`. The exercises cover symbol-table construction, arithmetic-expression evaluation, abstract syntax trees, and three-address intermediate code for a limited C-like language.

## Assignment schedule

| Coursework | Original course notice | Submission/demo deadline |
| --- | --- | --- |
| PE3, PE4, PE5 | 30 March 2026 | 6 April 2026 |
| PE6 and Assignment 2 | 6 April 2026 | 13 April 2026 |

These are the original assignment dates, not Git upload dates. This repository was published later from the retained coursework packets.

## Exercises

| Exercise | Implementation | Main output |
| --- | --- | --- |
| PE3 | Symbol table for a small C subset: basic declarations, storage classes, function definitions with limited parameter support, and nested blocks | Identifier name, kind, type, size, storage class, scope level, location and initializer |
| PE4 | Integer arithmetic evaluator with assignment and single-letter variables; reports use of unassigned variables | Evaluated values and symbol updates |
| PE5 | Arithmetic AST construction with operator precedence and parentheses; numeric operands | Postorder / Reverse Polish traversal |
| PE6 | Three-address code generation for arithmetic expressions and assignments | `(op, arg1, arg2, result)` quadruples and temporary variables |
| Assignment 2: AST | AST extension for assignments, `if/else`, and `do/while` | Indented AST and postorder traversal |
| Assignment 2: ICG | Intermediate-code extension for assignments, `if/else`, and `do/while` | Quadruples with generated labels, conditional jumps and backpatching |

Each exercise is a separate executable, not one integrated compiler pipeline.

## Repository layout

```text
pe3-pe5/
  pe3.l, pe3.y              Symbol table
  pe4.l, pe4.y              Expression evaluator
  pe4_lexer.c               Alternative hand-written lexer for PE4
  pe5.l, pe5.y              Arithmetic AST
  input.c, test_clean3.c    Original sample inputs
pe6-assignment2/
  pe6.l, pe6.y              Arithmetic/assignment intermediate code
  a2_ast.l, a2_ast.y        Control-flow AST
  a2_icg.l, a2_icg.y        Control-flow intermediate code
  Makefile                 Original build targets
```

Generated parser/scanner C files, prebuilt executables, and macOS metadata/debug bundles from the ZIPs are omitted. Generate the parser/scanner files locally using Flex and Bison. Original source logic is retained.

## Build

Requires Flex, Bison, GCC (or a compatible C compiler), and Make for the supplied Makefile. Use a POSIX environment such as Linux, macOS with these tools installed, or WSL. The commands below describe the intended build; a fresh Flex/Bison rebuild has not been verified for this published snapshot.

### PE3-PE5

```sh
cd pe3-pe5
for n in 3 4 5; do
  bison -d -o pe${n}.tab.c pe${n}.y
  flex -o pe${n}.lex.c pe${n}.l
  gcc -Wall -g -o pe${n} pe${n}.tab.c pe${n}.lex.c
done
```

To use the alternative PE4 lexer, generate `pe4.tab.c`/`pe4.tab.h` with Bison and compile `pe4.tab.c` with `pe4_lexer.c` instead of the Flex-generated scanner.

### PE6 and Assignment 2

```sh
cd pe6-assignment2
make
```

This builds `pe6`, `a2_ast`, and `a2_icg`. Each scanner supplies `yywrap`, so the supplied Makefile does not require `-lfl`.

## Example inputs

Run each command from its corresponding exercise directory. These are illustrative input examples, not a claimed automated test suite.

```sh
# PE3: declarations and block scope
printf 'static int count = 10;\n{ float value; }\n' | ./pe3

# PE4: assignment and expression evaluation
printf 'a=5,b=8,c=9,d=a+b*c.\n' | ./pe4

# PE5: AST postorder traversal
printf '2+3*4\n' | ./pe5

# PE6: arithmetic quadruples (newline-terminated input)
printf 'x = a + b * c\n' | ./pe6

# Assignment 2: AST or intermediate code
printf 'if (x < y) { z = a + b; } else { z = a - b; }\n' | ./a2_ast
printf 'do { x = x + 1; } while (x < n);\n' | ./a2_icg
```

## Scope and limitations

- This is educational compiler-front-end and intermediate-representation coursework, not a complete ISO C compiler. PE2 and Assignment 1 are not included in these two packets.
- PE3 records declaration types and scope levels; it is not a complete semantic analyzer. PE4 operates on integers and single-letter variables, reports use of unassigned variables, and does not implement general type-mismatch checking.
- Assignment 2 conditions use identifier-to-identifier comparisons. Supported constructs and identifier rules differ between exercises.
- The original `input.c` and `test_clean3.c` contain constructs beyond PE3's implemented grammar; they are preserved as supplied, not advertised as passing examples.
- The code uses fixed-size tables and buffers and does not comprehensively validate capacity, arithmetic errors, or memory lifetime. Some error paths report errors without returning a nonzero process status.
- No machine-code backend, LLVM integration, optimization passes, performance measurements, or full-C compliance are claimed.

## Topics

C, compiler design, lexical analysis, syntax analysis, Flex/LEX, Bison/YACC, symbol tables, scope tracking, expression evaluation, abstract syntax trees, postorder traversal, intermediate representation, three-address code, quadruples, control flow, labels, and backpatching.
