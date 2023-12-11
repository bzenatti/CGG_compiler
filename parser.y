%{
#include <stdio.h>
#include <string.h>

#define MAX 1000

int aux = 0;

// Um simbolo da tabela de simbolos é um id e seu endereço
typedef struct {
    char *id;
    int end;
} simbolo;

// Vetor de simbolos (a tabela de simbolos em si)
simbolo tabsimb[MAX];
int nsimbs = 0;

// Dado um ID, busca na tabela de simbolos o endereço respectivo
int getendereco(char *id) {
    for (int i=0;i<nsimbs;i++)
        if (!strcmp(tabsimb[i].id, id))
            return tabsimb[i].end;
    return -1;
}

typedef struct {
    int inicio;
    int fim;
} rotulo;

rotulo pilharot[MAX];
int nrots = 0;
int top = -1;

void push(rotulo rot) {
    if (top < MAX - 1)
        pilharot[++top] = rot;
}

void pop() {
    if (top == -1) return;
    else  top--;
}

%}

%union {
    char *str_val;
    int int_val;
}

/* indicação do tipo do texto/valor de um token, conforme o union. */
%token <str_val>ID <int_val>NUM INT
%token ATRIB PEV MAIS MENOS MULT DIV MOD
%token MENOR MAIOR MENORIGUAL MAIORIGUAL DIFER IGUAL
%token WHILE IF ELSE SCANF PRINTF
%token LPAR RPAR
%token LBRACE RBRACE
%token <str_val>STRING
%token REFINT VIRG END

/* resulve conflitos de ambiguidade */
%left MAIS MENOS
%left MULT DIV MOD
%left MENOR MAIOR MENORIGUAL MAIORIGUAL DIFER IGUAL

%precedence LBRACE

%%

/* o código depois de um simbolo será executado quando o simbolo for
   "encontrado" na entrada (reduce) */

programa : lista_instrucoes                         {   printf("\tSAIR\n");                         }
         ;

lista_instrucoes : instrucao
                 | lista_instrucoes instrucao
                 ;

instrucao : LPAR  condicao  RPAR desv_condicionais
          | PEV printf
          | PEV scanf
          | PEV decl 
          | PEV atrib           
          ;

decl : ID INT                                       { 
                                                        tabsimb[nsimbs] = (simbolo){$1, nsimbs}; 
                                                        nsimbs++; 
                                                    }
      | expressao ATRIB ID INT                      { 
                                                        tabsimb[nsimbs] = (simbolo){$3, nsimbs}; 
                                                        nsimbs++;
                                                        aux = getendereco($3);
                                                        if (aux == -1) {
                                                             fprintf(stderr,"ERRO SEMÂNTICO: variável \"%s\" não declarada.\n", $3);
                                                            return; 
                                                        }        
                                                        printf("\tATR %%%d\n",  aux); 
                                                    }
     ;

/* (2+2) = variavel */
atrib : expressao ATRIB ID                          {   
                                                        aux = getendereco($3);
                                                        if (aux == -1) {
                                                             fprintf(stderr,"ERRO SEMÂNTICO: variável \"%s\" não declarada.\n", $3);
                                                            return; 
                                                        }        
                                                        printf("\tATR %%%d\n",  aux);   
                                                    }
      ;

else : ELSE LBRACE lista_instrucoes RBRACE  | ;
desv_condicionais : WHILE                           {  
                                                        push((rotulo){nrots, ++nrots});  
                                                        printf("R%d: NADA\n", pilharot[top].inicio);
                                                        printf("\tGFALSE R%d\n", (pilharot[top].fim)); 
                                                    }
                    LBRACE lista_instrucoes RBRACE  { 
                                                        printf("\tGOTO R%d\n", pilharot[top].inicio); 
                                                        printf("R%d: NADA\n\n", pilharot[top].fim);
                                                        pop(); 
                                                    }
                  | IF                              {
                                                        push((rotulo){nrots, ++nrots});
                                                        printf("\tGFALSE R%d\n", (pilharot[top].inicio)); 
                                                    }
                    LBRACE lista_instrucoes RBRACE  { 
                                                        printf("\tGOTO R%d\n", pilharot[top].fim); 
                                                        printf("R%d: NADA\n", pilharot[top].inicio); 
                                                    }
                  else                              {
                                                        printf("R%d: NADA\n", pilharot[top].fim);
                                                        pop();
                                                    }
                  ;

/* )"%d", a (scanf */
printf : LPAR REFINT VIRG expressao RPAR PRINTF     {   printf("\tIMPR\n"); }
       ;

/* )"%d", &var(printf */
scanf : LPAR  REFINT  VIRG  END  ID  RPAR  SCANF    {   
                                                        printf("\tLEIA\n");
                                                        aux = getendereco($5);
                                                        if (aux == -1) {
                                                             fprintf(stderr,"ERRO SEMÂNTICO: variável \"%s\" não declarada.\n", $5);
                                                            return; 
                                                        }        
                                                        printf("\tPUSH %%%d\n", aux); 
                                                    }
      ;

condicao :  expressao MENOR expressao               {   printf("\tMENOR\n");                        }
          | expressao MENORIGUAL expressao          {   printf("\tMENOREQ\n");                      }
          | expressao MAIOR expressao               {   printf("\tMAIOR\n");                        }
          | expressao MAIORIGUAL expressao          {   printf("\tMAIOREQ\n");                      }
          | expressao IGUAL expressao               {   printf("\tIGUAL\n");                        }
          | expressao DIFER expressao               {   printf("\tDIFER\n");                        }
          | expressao
          ;

expressao : LPAR expressao RPAR
          | expressao MAIS expressao                {   printf("\tSOMA\n");                         }
          | expressao MENOS expressao               {   printf("\tSUB\n");                          }
          | expressao MULT expressao                {   printf("\tMULT\n");                         }         
          | expressao DIV expressao                 {   printf("\tDIV\n");                          }
          | expressao MOD expressao                 {   printf("\tMOD\n");                          }        
          | NUM                                     {   printf("\tPUSH %d\n", $1);                  }
          | ID                                      {   
                                                        aux = getendereco($1);
                                                        if (aux == -1) {
                                                             fprintf(stderr,"ERRO SEMÂNTICO: variável \"%s\" não declarada.\n", $1);
                                                            return; 
                                                        }
                                                        printf("\tPUSH %%%d\n",  aux);  
                                                    }
          ; 

%%

// extern FILE *yyin;                   // (*) descomente para ler de um arquivo

int main(int argc, char *argv[]) {

//    yyin = fopen(argv[1], "r");       // (*)

    yyparse();

//    fclose(yyin);                     // (*)

    return 0;
}

void yyerror(char *s) { fprintf(stderr,"ERRO: %s\n", s); }
