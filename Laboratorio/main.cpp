#include <iostream>
#include <ostream>

using namespace std;

/*  COMANDOS */
const short C_NUM = 1;
const short C_PORT = 2;
const short C_LOG = 3;
const short C_TOP = 4;
const short C_DUMP = 5;
const short C_DUP = 6;
const short C_SWAP = 7;
const short C_NEG = 8;
const short C_FACT = 9;
const short C_SUM = 10;
const short C_CLS = 254;
const short C_HALT = 255;

/*  ARITMETICAS */
const short C_SUMA = 11;
const short C_RESTA = 12;
const short C_MULT = 13;
const short C_DIV = 14;
const short C_MOD = 15;
const short C_AND = 16;
const short C_OR = 17;
const short C_SAL = 18;
const short C_SAR = 19;

short PILA_LLENA = 31;
short COMIENZO_STACK = 0;
short OPERACION_EXITOSA = 16;
short FALTAN_OPERANDOS = 8;
short DESBORDAMIENTO_DE_PILA = 4;
short COMANDO_INVALIDO = 2;

short ENTRADA[] = {0, 2, 15, 1, 14, 1, 3, 1, 4, 11, 14, 1, 1, 11, 4, 255};

short pila[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

short ax = 0;
short bx = 0;
short cx = 0;
short dx = 0;
short si = 0;
short mod = 0;

int hayError = 0; //si no hay error se debe mantener en 0

short PUERTO_SALIDA_DEFECTO = 0;
short PUERTO_LOG_DEFECTO = 1;

short salida = PUERTO_SALIDA_DEFECTO;
short log = PUERTO_LOG_DEFECTO;

void poner_siguiente_operando_en_ax(short index){
    ax = ENTRADA[index];
}

void check_si_habra_desbordamiento(){
    if (si >= 31){
        hayError = 4;
    }
}

void check_falta_operando(){
    if (si == 0){
        hayError = 8;
    }
}

void apilar_bx(){
    if (hayError == 0){
        check_si_habra_desbordamiento();
        if (hayError == 0){
            si++;
            pila[si] = bx;
        }
    }
}

void apilar_ax(){
    if (hayError == 0){
        check_si_habra_desbordamiento();
        if (hayError == 0){
            si++;
            pila[si] = ax;
        }
    }
}

void copiar_tope_a_ax(){
    check_falta_operando();
    if (hayError==0){
        ax = pila[si];
    }
}

void desapilar_hacia_bx(){
    check_falta_operando();
    if (hayError==0){
        bx = pila[si];
        si--;
    }
}

void desapilar_hacia_ax(){
    check_falta_operando();
    if (hayError==0){
        ax = pila[si];
        si--;
    }
}

void log_preprocesamiento(){
    cout << "\nPuerto " << dx << ": 0 " << ax << " ";
}
void log_parametro(){
    cout << "\nPuerto " << dx << ": " << ax << " ";
}
void log_exitoso(){
    cout << "\nPuerto " << dx << ": 16 ";
}

void log_desbordamiento_de_pila(){
    cout << "\nPuerto " << dx << ": 4 ";
}

void log_comando_invalido(){
    cout << "\nPuerto " << dx << ": 2 ";
}
void log_falta_operando(){
    cout << "\nPuerto " << dx << ": 8 ";
}

void imprimir_en_puerto(){
    cout << "\nPuerto " << cx << ": " << ax << " ";
}

short dividir_ax_con_bx(short n){
    mod = ax % n;
    return ax/n;
}


short factorial_de_ax_dejarlo_en_bx(short n){
    if (n == 0){
        return 1;
    }else{
        return factorial_de_ax_dejarlo_en_bx(n-1)*n;
    }
}


int main() {
    /* STACK Y OTROS */
    si = 0;
    dx = PUERTO_LOG_DEFECTO;
    cx = PUERTO_SALIDA_DEFECTO;
    short index = 0;

    while (index < sizeof(ENTRADA)){
        index++;
        poner_siguiente_operando_en_ax(index);
        if (ax == C_LOG){
            short comando = ax;
            index++;
            poner_siguiente_operando_en_ax(index);
            cout << "\nPuerto " << dx << ": 0 " << comando << " " << ax << " 16 ";
        }else{
            log_preprocesamiento();
            if (ax == C_NUM){
                index++;
                poner_siguiente_operando_en_ax(index);
                log_parametro();
                apilar_ax();
            }else if(ax == C_PORT){
                index++;
                poner_siguiente_operando_en_ax(index);
                log_parametro();
                cx = ax;
            }else if(ax == C_LOG){
                index++;
                poner_siguiente_operando_en_ax(index);
                log_parametro();
                dx = ax;
            }else if(ax == C_TOP){
                copiar_tope_a_ax();
                imprimir_en_puerto();
            }else if(ax == C_DUP){
                desapilar_hacia_ax();
                apilar_ax();
                apilar_ax();
            }else if(ax == C_DUMP){
                short temp = si;
                while (si > 0){
                    desapilar_hacia_ax();
                    imprimir_en_puerto();
                }
                si = temp;
            }else if(ax == C_SWAP){
                desapilar_hacia_ax();
                desapilar_hacia_bx();
                apilar_ax();
                apilar_bx();
            }else if(ax == C_NEG){
                desapilar_hacia_ax();
                ax = -ax;
                apilar_ax();
            }else if(ax == C_FACT){
                desapilar_hacia_ax();
                if (hayError==0){
                    bx = factorial_de_ax_dejarlo_en_bx(ax);
                    apilar_bx();
                }
            }else if(ax == C_SUM){
                ax = 0;
                while (si > 0){
                    desapilar_hacia_bx();
                    ax += bx;
                }
                apilar_ax();
            }else if(ax == C_CLS){
                si = 0;
            }else if(ax == C_HALT){
                return 0;
            }else if(ax == C_SUMA){
                desapilar_hacia_ax();
                desapilar_hacia_bx();
                ax += bx ;
                apilar_ax();
            }else if(ax == C_RESTA){
                desapilar_hacia_bx();
                desapilar_hacia_ax();
                bx = -bx;
                ax += bx;
                apilar_ax();
            }else if(ax == C_MULT){
                desapilar_hacia_bx();
                desapilar_hacia_ax();
                ax = ax * bx;
                apilar_ax();
            }else if(ax == C_DIV){
                desapilar_hacia_bx();
                desapilar_hacia_ax();
                ax = dividir_ax_con_bx(bx);
                apilar_ax();
            }else if(ax == C_MOD){
                desapilar_hacia_bx();
                desapilar_hacia_ax();
                dividir_ax_con_bx(bx);
                ax = mod;
                apilar_ax();
            }else if(ax == C_AND){
                desapilar_hacia_bx();
                desapilar_hacia_ax();
                ax = ax & bx;
                apilar_ax();
            }else if(ax == C_OR){
                desapilar_hacia_bx();
                desapilar_hacia_ax();
                ax = ax | bx;
                apilar_ax();
            }else if(ax == C_SAL){
                desapilar_hacia_bx();
                desapilar_hacia_ax();
                ax = ax << cx;
                apilar_ax();
            }else if(ax == C_SAR){
                desapilar_hacia_bx();
                desapilar_hacia_ax();
                ax = ax >> cx;
                apilar_ax();
            }else{
                log_comando_invalido();
                continue;
            }
            if (hayError == 4){
                log_desbordamiento_de_pila();
                hayError = 0;
                continue;
            }else if (hayError == 8){
                log_falta_operando();
                hayError = 0;
                continue;
            }else{
                log_exitoso();
            }
        }
    }// endWhile

    return 0;
}


