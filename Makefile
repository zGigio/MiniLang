
CC = gcc
CFLAGS = -Wall -Wextra -Isrc

all: minilang

minilang: parser.tab.c lex.yy.c src/main.c src/simbolos.c
	$(CC) $(CFLAGS) -o minilang parser.tab.c lex.yy.c src/main.c src/simbolos.c -lfl

parser.tab.c parser.tab.h: src/parser.y src/simbolos.h
	bison -d -o parser.tab.c src/parser.y

lex.yy.c: src/lexer.l parser.tab.h
	flex -o lex.yy.c src/lexer.l

clean:
	rm -f minilang parser.tab.c parser.tab.h lex.yy.c

.PHONY: all clean
