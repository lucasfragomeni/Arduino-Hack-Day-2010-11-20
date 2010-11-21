#include <Servo.h> 

//LDRs
const int S_ESQ = A5;
const int S_CEN = A4;
const int S_DIR = A3;

//LUZ GUIA
const int L_GUIA = 13;

//INDICATIVO DE FAIXA
const int DIFF = 20;

int avgLdrEsq;
int avgLdrCen;
int avgLdrDir;

//Servo

//O servo vai de 0 a 90. Nesse caso, deve ser calibrado para parar nos 45,
//e assim ele irá rodar para trás abaixo dos 45 e para frente acima dos 45.
const int VEL_MAX = 45;
const int VEL_MIN = 5;
const int STOP = 45;

//Constantes da direçao
const int ESQUERDA = 3;
const int DIREITA = 1;
const int CENTRO = 2;

int ultmov;

Servo rodaDir;
Servo rodaEsq;

void setup() {
  Serial.begin(9600);

  //Inicialização dos LDRs
  pinMode(S_ESQ, INPUT);
  pinMode(S_CEN, INPUT);
  pinMode(S_DIR, INPUT);
  
  pinMode(L_GUIA, OUTPUT);
  
  rodaDir.attach(8);
  rodaEsq.attach(9);
  delay(10);
  parar();

  calibrar();
}

void calibrar() {
  delay(2000);
  digitalWrite(L_GUIA, HIGH);
  
  //Fazendo a leitura da iluminação média padrão
  for(int i = 0; i < 10; i++) {
    avgLdrEsq += analogRead(S_ESQ);
    avgLdrCen += analogRead(S_CEN);
    avgLdrDir += analogRead(S_DIR);
    delay(25);
  }
  avgLdrEsq = avgLdrEsq / 10;
  avgLdrCen = avgLdrCen / 10;
  avgLdrDir = avgLdrDir / 10;
  
  Serial.print("Padrão: esq: "); Serial.print(avgLdrEsq);
  Serial.print(" - cen: "); Serial.print(avgLdrCen);
  Serial.print(" - dir: "); Serial.println(avgLdrDir);
}

void loop() {
  int ldrEsq = analogRead(S_ESQ);
  int ldrCen = analogRead(S_CEN);
  int ldrDir = analogRead(S_DIR);
  
  Serial.print("esq: "); Serial.print(ldrEsq);
  Serial.print(" - cen: "); Serial.print(ldrCen);
  Serial.print(" - dir: "); Serial.println(ldrDir);

  andar(ldrEsq, ldrCen, ldrDir);
  
  delay(30);
}

void andar(int ldrEsq, int ldrCen, int ldrDir) {
  if(avgLdrEsq - ldrEsq > DIFF) {
    Serial.println("esquerda");
    esquerda (VEL_MAX);
    ultmov = ESQUERDA;
  }
  else if(avgLdrDir - ldrDir > DIFF) {
    Serial.println("direita");
    direita(VEL_MAX);
    ultmov = DIREITA;
  }
  else if(avgLdrCen - ldrCen > DIFF) {
    Serial.println("frente");
    frente(VEL_MAX);
    ultmov = CENTRO;
  }
  else {
    Serial.println("parar");
    parar();
  }
}

void parar() {
  rodaDir.write(STOP);
  rodaEsq.write(STOP);
  delay(200);
  if(ultmov == DIREITA)
    esquerda (45-VEL_MIN);
  else
    if(ultmov == ESQUERDA)
      direita (45+VEL_MIN);
  else
    if(ultmov == CENTRO)
    {
      direita (VEL_MIN);
      esquerda (2*VEL_MIN);
    }
}

void frente(int vel) {
  if(vel > VEL_MAX) {
    vel = VEL_MAX;
  } else if(vel < VEL_MIN) {
    vel = VEL_MIN;
  }
  
  rodaDir.write(45 - vel);
  rodaEsq.write(vel + 45);

}

void recuar(int vel) {
  if(vel > VEL_MAX) {
    vel = VEL_MAX;
  } else if(vel < VEL_MIN) {
    vel = VEL_MIN;
  }
  
  rodaDir.write(vel + 45);
  rodaEsq.write(45 - vel);
}

void direita(int vel) {
  rodaDir.write(VEL_MIN + 45);
  rodaEsq.write(STOP - 1);
}

void esquerda(int vel) {
  rodaDir.write(STOP +1);
  rodaEsq.write(45 - VEL_MIN);
}
