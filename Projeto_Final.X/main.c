#include "lcd.h"
#include "timer.h"
#include "ssd.h"
#include "bits.h"
#include "keypad.h"
#include "delay.h"
#define L_CLR 0x01
#define L_L1 0x80
#define L_L2 0xC0
typedef struct no{
    unsigned char nome,tempo,queima,acucar;
} cafe;
cafe caseiro,expresso,cappu,latte;
cafe escolhido;
int seg = 0;
char start = 0,escolha=0,antes=4;
void cafes(){
    caseiro.nome=1;//caseiro.nome="Cafe caseiro";
    caseiro.tempo=55;
    expresso.nome=2;//expresso.nome="Cafe Expresso";
    expresso.tempo=40;
    cappu.nome=3;//cappu.nome="Cappuccino";
    cappu.tempo=90;
    latte.nome=4;//latte.nome="Latte Macchiato";
    latte.tempo=120;
}

void leTeclado(void){ 
    unsigned int tecla = 16;
    kpDebounce();
    if(kpRead() != tecla){
        tecla = kpRead();        
        if(escolha == 0){
            if(bitTst(tecla, 0)){
                escolhido=caseiro;
                escolha=1;
            }//
            if(bitTst(tecla, 1)){
                escolhido=expresso;
                escolha=1;
            }//
            if(bitTst(tecla, 2)){
                escolhido=cappu;
                escolha=1;
            }//
            if(bitTst(tecla, 3)){
                escolhido=latte;
                escolha=1;
            }//
        }
        else if(escolha == 1){
            if(bitTst(tecla, 8)){
                escolha=0; 
            }
            if(bitTst(tecla, 6)){
                escolha=2;
            }
        } 
        else if(escolha == 2){
            if(bitTst(tecla, 0)){
                escolhido.queima=1;
                escolha=3;
            }//
            if(bitTst(tecla, 1)){
                escolhido.queima=2;
                escolha=3;
            }//
            if(bitTst(tecla, 2)){
                escolhido.queima=3;
                escolha=3;
            }//
        }
        else if(escolha == 3){
            if(bitTst(tecla, 8)){
                escolhido.acucar=0;
                seg=escolhido.tempo;
                escolha=4;
                start=1;
            }
            if(bitTst(tecla, 6)){
                escolhido.acucar=1;
                seg=escolhido.tempo;
                escolha=4;
                start=1;
            }
        } 
    }
}

void ImprimeCafe(){
    if(escolhido.nome==1){
        lcdString("Cafe caseiro");
    }
    else if(escolhido.nome==2){
        lcdString("Cafe Expresso");
    }
    else if(escolhido.nome==3){
        lcdString("Cappuccino");
    }
    else if(escolhido.nome==4){
        lcdString("Latte Macchiato");
    }
    if(escolha!=1)
        if(escolhido.acucar==0){
            lcdString("S/A");
        }
        else if(escolhido.acucar==1){
            lcdString("C/A");
        }
}

void lcd(){
    if(escolha!=antes){
        lcdCommand(L_L1);
        lcdCommand(L_CLR);
        lcdCommand(L_L2);
        lcdCommand(L_CLR);
        switch (escolha){
            case 0:
                lcdCommand(L_L1);
                lcdString("Escolha 1 cafe:");
                lcdCommand(L_L2);
                break;
            case 1:
                lcdCommand(L_L1);
                ImprimeCafe();
                lcdCommand(L_L2);
                lcdString("8-Nao    6-Sim");
                break;
            case 2:
                lcdCommand(L_L1);
                lcdString("Normal/Forte/Extra");
                lcdCommand(L_L2);
                lcdString("0-N 1-F 2-EF");
                break;
            case 3:
                lcdCommand(L_L1);
                lcdString("Quer acucar??");
                lcdCommand(L_L2);
                lcdString("8-Nao    6-Sim");
                break;
            case 4:
                lcdCommand(L_L1);
                lcdString("Fazendo:");
                if(escolhido.queima==1){
                    lcdString("Normal");
                }
                else if(escolhido.queima==2){
                    lcdString("Forte");
                }
                else if(escolhido.queima==3){
                    lcdString("Ex.Forte");
                }
                lcdCommand(L_L2);
                ImprimeCafe();
                break;
            default:
                break;
        }
    }
    antes=escolha;
}

void termina(){
    escolha=0;
    lcdCommand(L_L1);
    lcdCommand(L_CLR);
    lcdCommand(L_L1);
    lcdString("Pegue : ");
    if(escolhido.queima==1){
        lcdString("Normal");
    }
    else if(escolhido.queima==2){
        lcdString("Forte");
    }
    else if(escolhido.queima==3){
        lcdString("Ex.Forte");
    }
    lcdCommand(L_L2);
    ImprimeCafe();
    atraso(300);
}

void main(void) {
    lcdInit();
    ssdInit();
    kpInit();
    timerInit();
    cafes();
    unsigned char slot,tempo;
    while(1){
        timerReset(10); 
        switch(slot){
            case 0: 
                leTeclado();               
                slot = 1;
                break;
            case 1:
                lcd();
                slot = 2;
                break;
            case 2: 
                if(tempo>100){
                    tempo=0;
                    if(start!=0){
                        seg--;
                        if((seg<0)){
                            start=0;
                            seg=0;
                            termina();
                        }
                    }
                }
                ssdDigit(((seg/600) %6), 0);
                ssdDigit(((seg/60) %10), 1);
                ssdDigit(((seg/10) %6), 2);
                ssdDigit(((seg/1) %10), 3);              
                slot = 0;
                break;
            default:
                slot = 0;
                break;
        }
        if(start!=0){tempo++;}
        ssdUpdate();
        timerWait();
    }  
}