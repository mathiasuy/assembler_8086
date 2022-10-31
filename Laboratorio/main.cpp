#include <iostream>
#include <ostream>

using namespace std;


/*  COMANDOS */
int NUM = 1;
int PORT = 2;
int LOG = 3;
int TOP = 4;
int DUMP = 5;
int DUP = 6;
int SWAP = 7;
int NEG = 8;
int FACT = 9;
int SUM = 10;
int CLR = 254;
int HALT = 255;

/*  OPERACIONES ARITMETICAS */
int OP_SUM = 11;
int OP_RES = 12;
int OP_PRO = 13;
int OP_DIV = 14;
int OP_MOD = 15;
int OP_AND = 16;
int OP_OR = 17;
int OP_DIZ = 18;
int OP_DDE = 19;
int MARCA_SALIDA = 255;

int OPERACION_EXITOSA = 16;
int FALTAN_OPERANDOS = 8;
int DESBORDAMIENTO_DE_PILA = 4;
int COMANDO_INVALIDO = 2;

int ENTRADA[] = {2, 15, 1, 14, 1, 3, 1, 4, 11, 14, 1, 1, 11, 4, 255};

int ss[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int bp = 0;
int sp = -1; //tope

int uno = 1;
int dos = 1;

int PUERTO_SALIDA_DEFECTO = 0;
int PUERTO_LOG_DEFECTO = 1;

int salida = PUERTO_SALIDA_DEFECTO;
int log = PUERTO_LOG_DEFECTO;

int ax, bx, cx, dx, si;

///////// FUNCIONES PARA ENTRADA ////////////////

void poner_siguiente_operando_en_bx(){
    si++;
    ax = ENTRADA[si];
    bx = ax;
}

void siguiente_comando(){
    si++;
    ax = ENTRADA[si];
    bx = ax;
}

///////// FUNCIONES PARA PILA ////////////////

void apilar_bx(){
    sp++;
    ss[sp] = bx;
}

void apilar_cx(){
    sp++;
    ss[sp] = cx;
}

void desapilar(){
    sp--;
}

bool pila_no_esta_vacia(){
    return sp != bp;
}

void copiar_tope_a_bx(){
    bx = ss[sp];
}

/***
    Si no hay segundo operando retorna false
**/
bool copiar_el_segundo_de_la_pila_a_cx_y_retornar_true_si_no_se_pudo(){
    sp--;
    if (sp == bp){
        return true;
    }
    cx = ss[sp];
    sp++;
    return false;
}


///////// FUNCIONES PARA IMPRESION EN PUERTOS ///////


/**
    se tomará para imprimir siempre bx
**/
void imprimir_en_puerto(){
    dx = salida;
    ax = bx;
    cout << "\nPuerto " << dx << ": " << ax;
}

void log_exitoso(){
    dx = log;
    ax = OPERACION_EXITOSA;
    cout << "\nBitacora " << dx << ": " << ax;
}

bool log_desbordamiento_de_pila(){
    dx = log;
    ax = DESBORDAMIENTO_DE_PILA;
    cout << "\nBitacora " << dx << ": " << ax;
    return true;
}

bool log_comando_invalido(){
    dx = log;
    ax = COMANDO_INVALIDO;
    cout << "\nBitacora " << dx << ": " << ax;
    return true;
}

void dump_stack(){
    if (sp >= 0){
        int bx = sp;// tomo el puntero al tope
        int ax;
        cout << "\n{ ";
        while (sp > bp){ // mientras no llegue al final de la pila
            ax = ss[sp];//tomo el valor del tope
            cout << " " << ax << " "; //lo devuelvo en el output_port
            sp--;//bajo el tope
        }
        sp = bx;//asigno a sp nuevamente el tope original
        cout << " }";
    }
}

int main() {
    /* STACK Y OTROS */
    si = -1;
    sp = 0;
    siguiente_comando();//bx <- entrada[si+1]


    while(bx - MARCA_SALIDA != 0){//JZ endWhile
        if (bx == NUM){
            poner_siguiente_operando_en_bx();
            apilar_bx();
            log_exitoso();
        }else if (bx == PORT){
            poner_siguiente_operando_en_bx();
            salida = bx;
            log_exitoso();
        }else if (bx == LOG){
            poner_siguiente_operando_en_bx();
            log = bx;
            log_exitoso();
        }else if (bx == TOP){
            copiar_tope_a_bx();//tomo el valor del tope y lo guardo en un registro
            imprimir_en_puerto();
            log_exitoso();
        }else if (bx == DUMP){
            cx = sp;// tomo el puntero al tope
            while (pila_no_esta_vacia()){ // mientras no llegue al final de la pila
                copiar_tope_a_bx();//tomo el valor del tope
                imprimir_en_puerto(); //lo devuelvo en el output_port
                desapilar();//bajo el tope
            }
            sp = cx;//asigno a sp nuevamente el tope original
            log_exitoso();
        }else if (bx == SWAP){
            copiar_tope_a_bx();//tomo el valor
            if (copiar_el_segundo_de_la_pila_a_cx_y_retornar_true_si_no_se_pudo()){
                continue;
            }
            desapilar();
            desapilar();
            apilar_bx();
            apilar_cx();
            log_exitoso();
        }else if (bx == NEG){
            copiar_tope_a_bx();
            desapilar();
            bx = bx * -1;
            apilar_bx();
            log_exitoso();
        }else if (bx == FACT){
            //fact(ss, bp, sp);
            ss[sp] = ax;
            log_exitoso();
        }else if (bx == SUM){
            cx = sp;
            ax = 0;
            while (pila_no_esta_vacia()){
                copiar_tope_a_bx();
                ax = bx + ax;
                bx = ax;
                imprimir_en_puerto();
                desapilar();
            }
            sp = cx;
            log_exitoso();
        }else if (bx == CLR){
            bx = bp;
            log_exitoso();
        }else if (bx == HALT){
            log_exitoso();
            exit(0);
        }else if (bx == OP_SUM){ // +
            copiar_tope_a_bx();
            if (copiar_el_segundo_de_la_pila_a_cx_y_retornar_true_si_no_se_pudo()){
                continue;
            }
            bx = cx + bx;
            desapilar();
            desapilar();
            apilar_bx();
            imprimir_en_puerto();
            log_exitoso();
            //log = bx;
        }else if (bx == OP_RES){ // -
            copiar_tope_a_bx();
            if (copiar_el_segundo_de_la_pila_a_cx_y_retornar_true_si_no_se_pudo()){
                continue;
            }
            bx = cx - bx;
            desapilar();
            desapilar();
            apilar_bx();
            imprimir_en_puerto();
            log_exitoso();
            //log = bx;
        }else if (bx == OP_PRO){ // *
            copiar_tope_a_bx();
            if (copiar_el_segundo_de_la_pila_a_cx_y_retornar_true_si_no_se_pudo()){
                continue;
            }
            bx = cx * bx;
            desapilar();
            desapilar();
            apilar_bx();
            imprimir_en_puerto();
            log_exitoso();
            //log = bx;
        }else if (bx == OP_DIV){ // /
            copiar_tope_a_bx();
            if (copiar_el_segundo_de_la_pila_a_cx_y_retornar_true_si_no_se_pudo()){
                continue;
            }
            bx = cx / bx;
            desapilar();
            desapilar();
            apilar_bx();
            imprimir_en_puerto();
            log_exitoso();
        }else if (bx == OP_MOD){ // %
            //pensarlo
            imprimir_en_puerto();
            log_exitoso();
        }else if (bx == OP_AND){ // &
            //pensarlo
            imprimir_en_puerto();
            log_exitoso();
        }else if (bx == OP_OR){ // |
            //pensarlo
            imprimir_en_puerto();
            log_exitoso();
        }else if (bx == OP_DIZ){ // <<
            //pensarlo
            imprimir_en_puerto();
            log_exitoso();
        }else if (bx == OP_DDE){ // >>
            //pensarlo
            imprimir_en_puerto();
            log_exitoso();
        }else{
            log_comando_invalido();
        }

        siguiente_comando();
        dump_stack();
    };// endWhile

    return 0;
}


