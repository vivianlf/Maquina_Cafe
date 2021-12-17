# 1 "main.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 288 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "C:/Program Files (x86)/Microchip/MPLABX/v5.35/packs/Microchip/PIC18Fxxxx_DFP/1.2.26/xc8\\pic\\include\\language_support.h" 1 3
# 2 "<built-in>" 2
# 1 "main.c" 2
# 1 "./lcd.h" 1


  void lcdCommand(char value);
  void lcdChar(char value);
  void lcdString(char msg[]);
  void lcdNumber(int value);
  void lcdPosition(int line, int col);
  void lcdInit(void);
# 1 "main.c" 2

# 1 "./timer.h" 1
# 23 "./timer.h"
 char timerEnded(void);
 void timerWait(void);

 void timerReset(unsigned int tempo);
 void timerInit(void);
# 2 "main.c" 2

# 1 "./ssd.h" 1
# 22 "./ssd.h"
 void ssdDigit(char val, char pos);
 void ssdUpdate(void);
 void ssdInit(void);
# 3 "main.c" 2

# 1 "./bits.h" 1
# 4 "main.c" 2

# 1 "./keypad.h" 1


 unsigned int kpRead(void);
    char kpReadKey(void);
 void kpDebounce(void);
 void kpInit(void);
# 5 "main.c" 2

# 1 "./delay.h" 1
# 10 "./delay.h"
void atraso(unsigned char);
# 6 "main.c" 2




typedef struct no{
    unsigned char nome,tempo,queima,acucar;
} cafe;
cafe caseiro,expresso,cappu,latte;
cafe escolhido;
int seg = 0;
char start = 0,escolha=0,antes=4;
void cafes(){
    caseiro.nome=1;
    caseiro.tempo=55;
    expresso.nome=2;
    expresso.tempo=40;
    cappu.nome=3;
    cappu.tempo=90;
    latte.nome=4;
    latte.tempo=120;
}

void leTeclado(void){
    unsigned int tecla = 16;
    kpDebounce();
    if(kpRead() != tecla){
        tecla = kpRead();
        if(escolha == 0){
            if(((tecla) & (1<<(0)))){
                escolhido=caseiro;
                escolha=1;
            }
            if(((tecla) & (1<<(1)))){
                escolhido=expresso;
                escolha=1;
            }
            if(((tecla) & (1<<(2)))){
                escolhido=cappu;
                escolha=1;
            }
            if(((tecla) & (1<<(3)))){
                escolhido=latte;
                escolha=1;
            }
        }
        else if(escolha == 1){
            if(((tecla) & (1<<(8)))){
                escolha=0;
            }
            if(((tecla) & (1<<(6)))){
                escolha=2;
            }
        }
        else if(escolha == 2){
            if(((tecla) & (1<<(0)))){
                escolhido.queima=1;
                escolha=3;
            }
            if(((tecla) & (1<<(1)))){
                escolhido.queima=2;
                escolha=3;
            }
            if(((tecla) & (1<<(2)))){
                escolhido.queima=3;
                escolha=3;
            }
        }
        else if(escolha == 3){
            if(((tecla) & (1<<(8)))){
                escolhido.acucar=0;
                seg=escolhido.tempo;
                escolha=4;
                start=1;
            }
            if(((tecla) & (1<<(6)))){
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
        lcdCommand(0x80);
        lcdCommand(0x01);
        lcdCommand(0xC0);
        lcdCommand(0x01);
        switch (escolha){
            case 0:
                lcdCommand(0x80);
                lcdString("Escolha 1 cafe:");
                lcdCommand(0xC0);
                break;
            case 1:
                lcdCommand(0x80);
                ImprimeCafe();
                lcdCommand(0xC0);
                lcdString("8-Nao    6-Sim");
                break;
            case 2:
                lcdCommand(0x80);
                lcdString("Normal/Forte/Extra");
                lcdCommand(0xC0);
                lcdString("0-N 1-F 2-EF");
                break;
            case 3:
                lcdCommand(0x80);
                lcdString("Quer acucar??");
                lcdCommand(0xC0);
                lcdString("8-Nao    6-Sim");
                break;
            case 4:
                lcdCommand(0x80);
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
                lcdCommand(0xC0);
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
    lcdCommand(0x80);
    lcdCommand(0x01);
    lcdCommand(0x80);
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
    lcdCommand(0xC0);
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
