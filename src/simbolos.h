
#ifndef SIMBOLOS_H
#define SIMBOLOS_H

typedef enum {
    TIPO_SIMBOLO_INTEIRO,
    TIPO_SIMBOLO_REAL,
    TIPO_SIMBOLO_TEXTO,
    TIPO_SIMBOLO_BOOLEANO,
    TIPO_SIMBOLO_INVALIDO
} Tipo;

int adicionar_simbolo(const char *nome, Tipo tipo);

Tipo buscar_simbolo(const char *nome);

const char *nome_tipo(Tipo tipo);

void registrar_erro_semantico(const char *mensagem);

int quantidade_erros_semanticos(void);

void listar_simbolos(void);

#endif

