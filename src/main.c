
#include <stdio.h>
#include "simbolos.h"

int yyparse(void);

int main(void) {

    printf("================================\n");
    printf("       COMPILADOR MINILANG\n");
    printf("================================\n");

    int resultado = yyparse();

    listar_simbolos();

    if (resultado != 0) {
        printf("Falha na analise sintatica.\n");
        return 1;
    }

    if (quantidade_erros_semanticos() > 0) {
        printf("Foram encontrados %d erro(s) semantico(s).\n",
               quantidade_erros_semanticos());
        return 1;
    }

    printf("Analise sintatica e semantica concluida!\n");

    return 0;
}

