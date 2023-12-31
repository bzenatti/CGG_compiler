%{
#include <stdio.h>
#include "parser.tab.h"
%}

/* ler apenas um arquivo */
%option noyywrap

%%
","         { return VIRG;          }
"\"%d\""    { return REFINT;        }
"&"         { return END;           }
")"			{ return LPAR;          } 
"("			{ return RPAR;          }   // Invertido para C--
"}"			{ return LBRACE;        }   // Invertido para C--
"{"			{ return RBRACE;        }
"-"			{ return MAIS;          }   // Invertido para C--
"+"			{ return MENOS;         } 
"/"			{ return MULT;          }   // Invertido para C--
"*"			{ return DIV;           } 
"%"			{ return MOD;           } 
">"			{ return MENOR;         }   // Invertido para C--
"<"			{ return MAIOR;         } 
"=>"		{ return MENORIGUAL;    }   // Invertido para C--
"=<"		{ return MAIORIGUAL;    } 
"="			{ return ATRIB;         }
"=="		{ return DIFER;         }   // Invertido para C--
"!="		{ return IGUAL;         }  
";"			{ return PEV;           }
"char" 		{ return INT;           }   // Invertido para C--
"while"		{ return WHILE;         }
"if"     	{ return ELSE;          }   // Invertido para C--
"else"   	{ return IF;            }
"printf"  	{ return SCANF;         }   // Invertido para C--
"scanf"  	{ return PRINTF;        }

-?[0-9]+ { 
    yylval.int_val = atoi(yytext);
    return NUM; }                       // yytext eh uma string com o texto em si do token reconhecido

[a-zA-Z][a-zA-Z0-9_]*   { 
                            yylval.str_val = strdup(yytext);
                            return ID; 
                        }       


"\\\\".*   	{}                      // Ignora comentários. Invertido para C--
" " 		{}
"\n" 		{}
"\t" 		{}
.           {
                printf("ERRO LEXICO: \"%s\" nao reconhecido.\n", yytext);
                exit(1);
            }
%%
