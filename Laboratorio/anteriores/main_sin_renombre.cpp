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

int ENTRADA[] = {2, 15, 1, 14, 1, 3, 1, 4, 11, 14, 1, 1, 11, 4, 255};

int ss[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int bp = 0;
int sp = -1; //tope

int uno = 1;
int temp;
int temp2;

int PUERTO_dx_salida_DEFECTO = 0;
int PUERTO_LOG_DEFECTO = 1;
int dx_salida = PUERTO_dx_salida_DEFECTO;
int log = PUERTO_LOG_DEFECTO;

int bx, i=0;


void imprimir_en_puerto(int puerto, int numero){
    cout << "\nPuerto " << puerto << ": " << numero;
}

void dump_stack(){
    if (sp >= 0){
        int temp = sp;// tomo el puntero al tope
        int temp2;
        cout << "\n{ ";
        while (sp >= bp){ // mientras no llegue al final de la pila
            temp2 = ss[sp];//tomo el valor del tope
            cout << " " << temp2 << " "; //lo devuelvo en el output_port
            sp--;//bajo el tope
        }
        sp = temp;//asigno a sp nuevamente el tope original
        cout << " }";
    }
}

int main() {
    /* STACK Y OTROS */
    int i = 0;
    temp = ENTRADA[i]; //Tomo el comando a ejecutar (asumo que es un comando)


    while(temp - MARCA_SALIDA != 0){//JZ endWhile
        if (temp == NUM){
            i = i+1; // Avanzo un paso más en la entrada
            temp = ENTRADA[i]; // lo guardo en un registro
            sp++;
            ss[sp] = temp; // y apilo el nuevo valor del registro en la pila
            // el tope avanzará un paso
        }else if (temp == PORT){
            i = i+1; //avanzo un paso más en la entrada para tomar
            temp = ENTRADA[i]; // ..el número de puerto que se
            dx_salida = temp; // ..pide para marcar como de dx_salida.
        }else if (temp == LOG){
            i = i+1; //avanzo un paso más en la entrada para tomar
            temp = ENTRADA[i];
            log = temp;// ..el dígito que se usará para la bitacora
        }else if (temp == TOP){
            temp = ss[sp];//tomo el valor del tope y lo guardo en un registro
            imprimir_en_puerto(dx_salida, temp); //lo devuelvo en el output_port
        }else if (temp == DUMP){
            temp = sp;// tomo el puntero al tope
            while (sp != bp){ // mientras no llegue al final de la pila
                temp2 = ss[sp];//tomo el valor del tope
                imprimir_en_puerto(dx_salida, temp); //lo devuelvo en el output_port
                sp--;//bajo el tope
            }
            sp = temp;//asigno a sp nuevamente el tope original
        }else if (temp == SWAP){
                temp = ss[sp];//tomo el valor
                ss[sp] = ss[sp-uno];
                ss[sp-uno] = temp;
        }else if (temp == NEG){
            temp = ss[sp];
            temp = temp * -1;
            ss[sp] = temp;
        }else if (temp == FACT){
            //fact(ss, bp, sp);
            ss[sp] = temp2;
        }else if (temp == SUM){
            temp = sp;
            temp2 = 0;
            while (sp != bp){
                temp2 += ss[sp];
                imprimir_en_puerto(dx_salida, temp2);
                sp--;
            }
            sp = temp;
        }else if (temp == CLR){
            temp = bp;
        }else if (temp == HALT){
            exit(0);
        }else if (temp == OP_SUM){ // +
            temp = ss[sp];
            sp--;
            temp += ss[sp];
            ss[sp] = temp;
            imprimir_en_puerto(dx_salida, temp);
            //log = temp;
        }else if (temp == OP_RES){ // -
            temp = ss[sp];
            sp--;
            temp = temp - ss[sp];
            ss[sp] = temp;
            imprimir_en_puerto(dx_salida, temp);
            //log = temp;
        }else if (temp == OP_PRO){ // *
            temp = ss[sp];
            sp--;
            temp = temp * ss[sp];
            ss[sp] = temp;
            imprimir_en_puerto(dx_salida, temp);
            //log = temp;
        }else if (temp == OP_DIV){ // /
            temp = ss[sp];
            sp--;
            temp = ss[sp] / temp;
            ss[sp] = temp;
            imprimir_en_puerto(dx_salida, temp);
        }else if (temp == OP_MOD){ // %
            //pensarlo
            imprimir_en_puerto(dx_salida, temp);
        }else if (temp == OP_AND){ // &
            //pensarlo
            imprimir_en_puerto(dx_salida, temp);
        }else if (temp == OP_OR){ // |
            //pensarlo
            imprimir_en_puerto(dx_salida, temp);
        }else if (temp == OP_DIZ){ // <<
            //pensarlo
            imprimir_en_puerto(dx_salida, temp);
        }else if (temp == OP_DDE){ // >>
            //pensarlo
            imprimir_en_puerto(dx_salida, temp);
        }


        i++;
        temp = ENTRADA[i];
        dump_stack();
    };// endWhile

    return 0;
}


