void setup() {                
  Serial.begin(9600);

  //LED Indicador
  pinMode(13, OUTPUT);
  
  //Tomad@
  pinMode(14, OUTPUT);
}

void loop() {
  if(Serial.available()) {
    byte estado = Serial.read();
    
    if(estado == 0) {
      digitalWrite(13, LOW);   // liga o LED
      digitalWrite(14, LOW);   // liga a Tomad@
    } else if(estado == 1) {
      digitalWrite(13, HIGH);   // liga o LED
      digitalWrite(14, HIGH);   // liga a Tomad@
    }
  }
}
