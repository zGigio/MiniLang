
%option noyywrap yylineno

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
%}

DIGITO      [0-9]
LETRA       [a-zA-Z_]
ID          {LETRA}({LETRA}|{DIGITO})*
INTEIRO     {DIGITO}+
REAL        {DIGITO}+"."{DIGITO}+
CADEIA      \"([^\\\n]|\\.)*\"

%%

"programa"      { return PROGRAMA; }
"inteiro"       { return TIPO_INTEIRO; }
"real"          { return TIPO_REAL; }
"texto"         { return TIPO_TEXTO; }
"booleano"      { return TIPO_BOOLEANO; }

"verdadeiro"    { return VERDADEIRO; }
"falso"         { return FALSO; }

"se"            { return SE; }
"senao"         { return SENAO; }
"enquanto"      { return ENQUANTO; }

"escreva"       { return ESCREVA; }
"leia"          { return LEIA; }

"=="            { return IGUAL; }
"!="            { return DIFERENTE; }
">="            { return MAIOR_IGUAL; }
"<="            { return MENOR_IGUAL; }
"&&"            { return E_LOGICO; }
"||"            { return OU_LOGICO; }

{REAL}          { return NUMERO_REAL; }
{INTEIRO}       { return NUMERO_INTEIRO; }

{CADEIA}        { return CADEIA; }

{ID}            {
                    yylval.texto = strdup(yytext);
                    return IDENTIFICADOR;
                }

[ \t\r\n]+      { /* Ignora espacos */ }

"//".*          { /* Ignora comentarios */ }

[{}();,+*/=-]   { return yytext[0]; }

">"             { return '>'; }
"<"             { return '<'; }
"!"             { return '!'; }

. {
    fprintf(stderr,
        "Erro lexico na linha %d: caractere invalido '%s'\n",
        yylineno, yytext);

    return ERRO_LEXICO;
}

%%

