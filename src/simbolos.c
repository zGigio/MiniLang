
#include <stdio.h>
#include <string.h>
#include "simbolos.h"

#define MAX_SIMBOLOS 100
#define MAX_NOME 100

typedef struct {
    char nome[MAX_NOME];
    Tipo tipo;
} Simbolo;

static Simbolo tabela[MAX_SIMBOLOS];
static int total_simbolos = 0;
static int erros_semanticos = 0;

const char *nome_tipo(Tipo tipo) {
    switch (tipo) {
        case TIPO_SIMBOLO_INTEIRO: return "inteiro";
        case TIPO_SIMBOLO_REAL: return "real";
        case TIPO_SIMBOLO_TEXTO: return "texto";
        case TIPO_SIMBOLO_BOOLEANO: return "booleano";
        default: return "invalido";
    }
}

void registrar_erro_semantico(const char *mensagem) {
    fprintf(stderr, "Erro semantico: %s\n", mensagem);
    erros_semanticos++;
}

int quantidade_erros_semanticos(void) {
    return erros_semanticos;
}

Tipo buscar_simbolo(const char *nome) {
    for (int i = 0; i < total_simbolos; i++) {
        if (strcmp(tabela[i].nome, nome) == 0) {
            return tabela[i].tipo;
        }
    }

    return TIPO_SIMBOLO_INVALIDO;
}

int adicionar_simbolo(const char *nome, Tipo tipo) {
    if (buscar_simbolo(nome) != TIPO_SIMBOLO_INVALIDO) {
        char mensagem[200];

        snprintf(mensagem, sizeof(mensagem),
                 "Variavel '%s' ja foi declarada.", nome);

        registrar_erro_semantico(mensagem);
        return 0;
    }

    if (total_simbolos >= MAX_SIMBOLOS) {
        registrar_erro_semantico(
            "Limite maximo de variaveis atingido."
        );
        return 0;
    }

    snprintf(tabela[total_simbolos].nome,
             MAX_NOME, "%s", nome);

    tabela[total_simbolos].tipo = tipo;
    total_simbolos++;

    return 1;
}

void listar_simbolos(void) {
    printf("\n===== TABELA DE SIMBOLOS =====\n");

    for (int i = 0; i < total_simbolos; i++) {
        printf("Variavel: %-20s Tipo: %s\n",
               tabela[i].nome,
               nome_tipo(tabela[i].tipo));
    }

    printf("==============================\n");
}

