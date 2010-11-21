
void setup() {
  //Inicializando conexão com PC via FT232 - cabo
  Serial.begin(9600);
}

void loop() {
  int luz = analogRead(5); //LDR ligado na 5
  //envia informações para o PC
  Serial.println(luz < 600 ? "Acesa" : "Apagada");
  delay(500);
}

