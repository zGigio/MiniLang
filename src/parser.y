
%code requires {
    #include "simbolos.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "simbolos.h"

int yylex(void);
void yyerror(const char *s);
extern int yylineno;

static Tipo verificar_operacao_numerica(Tipo a, Tipo b);
static Tipo verificar_comparacao(Tipo a, Tipo b);
%}

%union {
    char *texto;
    Tipo tipo;
}

%token PROGRAMA

%token TIPO_INTEIRO
%token TIPO_REAL
%token TIPO_TEXTO
%token TIPO_BOOLEANO

%token VERDADEIRO
%token FALSO

%token SE
%token SENAO
%token ENQUANTO

%token ESCREVA
%token LEIA

%token <texto> IDENTIFICADOR

%token NUMERO_INTEIRO
%token NUMERO_REAL
%token CADEIA

%token IGUAL
%token DIFERENTE
%token MAIOR_IGUAL
%token MENOR_IGUAL
%token E_LOGICO
%token OU_LOGICO

%token ERRO_LEXICO

%type <tipo> tipo expressao

%left OU_LOGICO
%left E_LOGICO
%left IGUAL DIFERENTE
%left '>' '<' MAIOR_IGUAL MENOR_IGUAL
%left '+' '-'
%left '*' '/'
%right '!' UMINUS

%precedence SE_SEM_SENAO
%precedence SENAO

%start programa

%%

programa:
    PROGRAMA '{' lista_comandos '}'
    {
        printf("\nPrograma MiniLang reconhecido!\n");
    }
    ;

lista_comandos:
    %empty
    | lista_comandos comando
    ;

comando:
    declaracao
    | atribuicao
    | entrada
    | saida
    | condicional
    | repeticao
    ;

declaracao:
    tipo IDENTIFICADOR ';'
    {
        adicionar_simbolo($2, $1);
        free($2);
    }
    ;

tipo:
    TIPO_INTEIRO
    {
        $$ = TIPO_SIMBOLO_INTEIRO;
    }
    | TIPO_REAL
    {
        $$ = TIPO_SIMBOLO_REAL;
    }
    | TIPO_TEXTO
    {
        $$ = TIPO_SIMBOLO_TEXTO;
    }
    | TIPO_BOOLEANO
    {
        $$ = TIPO_SIMBOLO_BOOLEANO;
    }
    ;

atribuicao:
    IDENTIFICADOR '=' expressao ';'
    {
        Tipo destino = buscar_simbolo($1);

        if (destino == TIPO_SIMBOLO_INVALIDO) {
            char mensagem[200];

            snprintf(mensagem, sizeof(mensagem),
                     "Variavel '%s' nao foi declarada.", $1);

            registrar_erro_semantico(mensagem);
        }
        else if (destino != $3 &&
                 !(destino == TIPO_SIMBOLO_REAL &&
                   $3 == TIPO_SIMBOLO_INTEIRO)) {

            char mensagem[250];

            snprintf(mensagem, sizeof(mensagem),
                     "Tipo incompativel na atribuicao de '%s': esperado %s, recebido %s.",
                     $1, nome_tipo(destino), nome_tipo($3));

            registrar_erro_semantico(mensagem);
        }

        free($1);
    }
    ;

entrada:
    LEIA '(' IDENTIFICADOR ')' ';'
    {
        if (buscar_simbolo($3) == TIPO_SIMBOLO_INVALIDO) {
            char mensagem[200];

            snprintf(mensagem, sizeof(mensagem),
                     "Variavel '%s' nao foi declarada.", $3);

            registrar_erro_semantico(mensagem);
        }

        free($3);
    }
    ;

saida:
    ESCREVA '(' expressao ')' ';'
    ;

condicional:
    SE '(' expressao ')' bloco %prec SE_SEM_SENAO
    {
        if ($3 != TIPO_SIMBOLO_BOOLEANO &&
            $3 != TIPO_SIMBOLO_INVALIDO) {
            registrar_erro_semantico(
                "A condicao do 'se' deve ser booleana."
            );
        }
    }
    | SE '(' expressao ')' bloco SENAO bloco
    {
        if ($3 != TIPO_SIMBOLO_BOOLEANO &&
            $3 != TIPO_SIMBOLO_INVALIDO) {
            registrar_erro_semantico(
                "A condicao do 'se' deve ser booleana."
            );
        }
    }
    ;

repeticao:
    ENQUANTO '(' expressao ')' bloco
    {
        if ($3 != TIPO_SIMBOLO_BOOLEANO &&
            $3 != TIPO_SIMBOLO_INVALIDO) {
            registrar_erro_semantico(
                "A condicao do 'enquanto' deve ser booleana."
            );
        }
    }
    ;

bloco:
    '{' lista_comandos '}'
    ;

expressao:
    NUMERO_INTEIRO
    {
        $$ = TIPO_SIMBOLO_INTEIRO;
    }
    | NUMERO_REAL
    {
        $$ = TIPO_SIMBOLO_REAL;
    }
    | CADEIA
    {
        $$ = TIPO_SIMBOLO_TEXTO;
    }
    | VERDADEIRO
    {
        $$ = TIPO_SIMBOLO_BOOLEANO;
    }
    | FALSO
    {
        $$ = TIPO_SIMBOLO_BOOLEANO;
    }
    | IDENTIFICADOR
    {
        $$ = buscar_simbolo($1);

        if ($$ == TIPO_SIMBOLO_INVALIDO) {
            char mensagem[200];

            snprintf(mensagem, sizeof(mensagem),
                     "Variavel '%s' nao foi declarada.", $1);

            registrar_erro_semantico(mensagem);
        }

        free($1);
    }
    | '(' expressao ')'
    {
        $$ = $2;
    }
    | expressao '+' expressao
    {
        $$ = verificar_operacao_numerica($1, $3);
    }
    | expressao '-' expressao
    {
        $$ = verificar_operacao_numerica($1, $3);
    }
    | expressao '*' expressao
    {
        $$ = verificar_operacao_numerica($1, $3);
    }
    | expressao '/' expressao
    {
        $$ = verificar_operacao_numerica($1, $3);
    }
    | expressao IGUAL expressao
    {
        $$ = verificar_comparacao($1, $3);
    }
    | expressao DIFERENTE expressao
    {
        $$ = verificar_comparacao($1, $3);
    }
    | expressao '>' expressao
    {
        $$ = verificar_comparacao($1, $3);
    }
    | expressao '<' expressao
    {
        $$ = verificar_comparacao($1, $3);
    }
    | expressao MAIOR_IGUAL expressao
    {
        $$ = verificar_comparacao($1, $3);
    }
    | expressao MENOR_IGUAL expressao
    {
        $$ = verificar_comparacao($1, $3);
    }
    | expressao E_LOGICO expressao
    {
        if ($1 != TIPO_SIMBOLO_BOOLEANO ||
            $3 != TIPO_SIMBOLO_BOOLEANO) {
            registrar_erro_semantico(
                "Operador '&&' exige valores booleanos."
            );
            $$ = TIPO_SIMBOLO_INVALIDO;
        } else {
            $$ = TIPO_SIMBOLO_BOOLEANO;
        }
    }
    | expressao OU_LOGICO expressao
    {
        if ($1 != TIPO_SIMBOLO_BOOLEANO ||
            $3 != TIPO_SIMBOLO_BOOLEANO) {
            registrar_erro_semantico(
                "Operador '||' exige valores booleanos."
            );
            $$ = TIPO_SIMBOLO_INVALIDO;
        } else {
            $$ = TIPO_SIMBOLO_BOOLEANO;
        }
    }
    | '!' expressao
    {
        if ($2 != TIPO_SIMBOLO_BOOLEANO) {
            registrar_erro_semantico(
                "Operador '!' exige valor booleano."
            );
            $$ = TIPO_SIMBOLO_INVALIDO;
        } else {
            $$ = TIPO_SIMBOLO_BOOLEANO;
        }
    }
    | '-' expressao %prec UMINUS
    {
        if ($2 != TIPO_SIMBOLO_INTEIRO &&
            $2 != TIPO_SIMBOLO_REAL) {
            registrar_erro_semantico(
                "Sinal negativo exige valor numerico."
            );
            $$ = TIPO_SIMBOLO_INVALIDO;
        } else {
            $$ = $2;
        }
    }
    ;

%%

static Tipo verificar_operacao_numerica(Tipo a, Tipo b) {
    if (a == TIPO_SIMBOLO_INVALIDO ||
        b == TIPO_SIMBOLO_INVALIDO) {
        return TIPO_SIMBOLO_INVALIDO;
    }

    if ((a != TIPO_SIMBOLO_INTEIRO &&
         a != TIPO_SIMBOLO_REAL) ||
        (b != TIPO_SIMBOLO_INTEIRO &&
         b != TIPO_SIMBOLO_REAL)) {

        registrar_erro_semantico(
            "Operacao matematica exige valores numericos."
        );

        return TIPO_SIMBOLO_INVALIDO;
    }

    if (a == TIPO_SIMBOLO_REAL ||
        b == TIPO_SIMBOLO_REAL) {
        return TIPO_SIMBOLO_REAL;
    }

    return TIPO_SIMBOLO_INTEIRO;
}

static Tipo verificar_comparacao(Tipo a, Tipo b) {
    if (a == TIPO_SIMBOLO_INVALIDO ||
        b == TIPO_SIMBOLO_INVALIDO) {
        return TIPO_SIMBOLO_INVALIDO;
    }

    if (a == b ||
        ((a == TIPO_SIMBOLO_INTEIRO ||
          a == TIPO_SIMBOLO_REAL) &&
         (b == TIPO_SIMBOLO_INTEIRO ||
          b == TIPO_SIMBOLO_REAL))) {
        return TIPO_SIMBOLO_BOOLEANO;
    }

    registrar_erro_semantico(
        "Comparacao entre tipos incompativeis."
    );

    return TIPO_SIMBOLO_INVALIDO;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintatico na linha %d: %s\n",
            yylineno, s);
}

