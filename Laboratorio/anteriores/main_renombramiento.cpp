#include <iostream>
#include <ostream>

using namespace std;


/*  COMANDOS */
int NUM = 1;
int PORT = 2;
int dx_log = 3;
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

int ENTRADA[] = {2, 15, 1, 14, 1, 3, 1, 4, 11, 14, 1, 1, 11, 4, 255};

int ss[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int bp = 0;
int sp = -1; //tope

int uno = 1;

int PUERTO_dx_salida_DEFECTO = 0;
int PUERTO_dx_log_DEFECTO = 1;
int dx_salida = PUERTO_dx_salida_DEFECTO;
int dx_log = PUERTO_dx_log_DEFECTO;

int ax, bx, i=0;


void imprimir_en_puerto(int puerto, int numero){
    cout << "\nPuerto " << puerto << ": " << numero;
}

void dump_stack(){
    if (sp >= 0){
        int ax = sp;// tomo el puntero al tope
        int bx;
        cout << "\n{ ";
        while (sp >= bp){ // mientras no llegue al final de la pila
            bx = ss[sp];//tomo el valor del tope
            cout << " " << bx << " "; //lo devuelvo en el output_port
            sp--;//bajo el tope
        }
        sp = ax;//asigno a sp nuevamente el tope original
        cout << " }";
    }
}

int main() {
    /* STACK Y OTROS */
    int i = 0;
    ax = ENTRADA[i]; //Tomo el comando a ejecutar (asumo que es un comando)


    while(ax - MARCA_SALIDA != 0){//JZ endWhile
        if (ax == NUM){
            i = i+1; // Avanzo un paso más en la entrada
            ax = ENTRADA[i]; // lo guardo en un registro
            sp++;
            ss[sp] = ax; // y apilo el nuevo valor del registro en la pila
            // el tope avanzará un paso
        }else if (ax == PORT){
            i = i+1; //avanzo un paso más en la entrada para tomar
            ax = ENTRADA[i]; // ..el número de puerto que se
            dx_salida = ax; // ..pide para marcar como de dx_salida.
        }else if (ax == dx_log){
            i = i+1; //avanzo un paso más en la entrada para tomar
            ax = ENTRADA[i];
            dx_log = ax;// ..el dígito que se usará para la bitacora
        }else if (ax == TOP){
            ax = ss[sp];//tomo el valor del tope y lo guardo en un registro
            imprimir_en_puerto(dx_salida, ax); //lo devuelvo en el output_port
        }else if (ax == DUMP){
            bx = sp;// tomo el puntero al tope
            while (sp != bp){ // mientras no llegue al final de la pila
                ax = ss[sp];//tomo el valor del tope
                imprimir_en_puerto(dx_salida, ax); //lo devuelvo en el output_port
                sp--;//bajo el tope
            }
            sp = bx;//asigno a sp nuevamente el tope original
        }else if (ax == SWAP){
                ax = ss[sp];//tomo el valor
                ss[sp] = ss[sp-uno];
                ss[sp-uno] = ax;
        }else if (ax == NEG){
            ax = ss[sp];
            ax = ax * -1;
            ss[sp] = ax;
        }else if (ax == FACT){
            //fact(ss, bp, sp);
            ss[sp] = bx;
        }else if (ax == SUM){
            bx = sp;
            ax = 0;
            while (sp != bp){
                ax += ss[sp];
                imprimir_en_puerto(dx_salida, ax);
                sp--;
            }
            sp = bx;
        }else if (ax == CLR){
            ax = bp;
        }else if (ax == HALT){
            exit(0);
        }else if (ax == OP_SUM){ // +
            ax = ss[sp];
            sp--;
            ax += ss[sp];
            ss[sp] = ax;
            imprimir_en_puerto(dx_salida, ax);
            //dx_log = ax;
        }else if (ax == OP_RES){ // -
            ax = ss[sp];
            sp--;
            ax = ax - ss[sp];
            ss[sp] = ax;
            imprimir_en_puerto(dx_salida, ax);
            //dx_log = ax;
        }else if (ax == OP_PRO){ // *
            ax = ss[sp];
            sp--;
            ax = ax * ss[sp];
            ss[sp] = ax;
            imprimir_en_puerto(dx_salida, ax);
            //dx_log = ax;
        }else if (ax == OP_DIV){ // /
            ax = ss[sp];
            sp--;
            ax = ss[sp] / ax;
            ss[sp] = ax;
            imprimir_en_puerto(dx_salida, ax);
        }else if (ax == OP_MOD){ // %
            //pensarlo
            imprimir_en_puerto(dx_salida, ax);
        }else if (ax == OP_AND){ // &
            //pensarlo
            imprimir_en_puerto(dx_salida, ax);
        }else if (ax == OP_OR){ // |
            //pensarlo
            imprimir_en_puerto(dx_salida, ax);
        }else if (ax == OP_DIZ){ // <<
            //pensarlo
            imprimir_en_puerto(dx_salida, ax);
        }else if (ax == OP_DDE){ // >>
            //pensarlo
            imprimir_en_puerto(dx_salida, ax);
        }


        i++;
        ax = ENTRADA[i];
        dump_stack();
    };// endWhile

    return 0;
}


