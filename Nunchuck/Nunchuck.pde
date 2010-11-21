#include <Wire.h>
#include <string.h>

boolean data_available = false;

int joy_x_axis = 0;
int joy_y_axis = 0;
int accel_x_axis = 0;
int accel_y_axis = 0;
int accel_z_axis = 0;
boolean z_button = 0;
boolean c_button = 0;

//Indicativo do acelerometro (on/off)
int acelerometro_led_pin = 13;
boolean acelerometro_ligado = false;

int ctrl_direcao;
int ctrl_sentido;

const int DIREITA = 1;
const int ESQUERDA = -1;
const int CENTRO = 0;
const int FRENTE = 1;
const int TRAS = -1;
const int PARADO = 0;

const int JOY_RESOLUCAO_MIN = 25;
const int JOY_X_ZERO = 123;
const int JOY_Y_ZERO = 126;

const int ACCEL_RESOLUCAO_MIN = 50;
const int ACCEL_X_ZERO = 500;
const int ACCEL_Y_ZERO = 500;

void setup()
{
  Serial.begin(9600);
  Serial.println("setup()");

  // send the initilization handshake
  nunchuck_init();

  // luz indicativa do acelerometro
  pinMode(acelerometro_led_pin, OUTPUT);

  delay(1000);
}

void loop()
{
  nunchuck_read();

  if(data_available) {
    //debug
//    nunchuck_print();
    delay(15);

    //Liga/desliga o acelerômetro
    verificar_acelerometro();
    
    //Lê o controle
    if(acelerometro_ligado) {
      ler_acelerometro();
    }
    else {
      ler_joystick();
    }
  }
}

/**
 * Liga/desliga o controle via acelerometro
 */ 
void verificar_acelerometro() {
  //Se um dos botões estiver ativo, muda o estado on/off ou vice-versa
  if(c_button || z_button) {
    acelerometro_ligado = !acelerometro_ligado;
    digitalWrite(acelerometro_led_pin, acelerometro_ligado ? HIGH : LOW);

    //Fica bloqueado enquanto um dos botões continuar apertado
    while(c_button || z_button) {
      nunchuck_read();    
    }

    //debug
    Serial.print("acelerometro ligado: "); Serial.println(acelerometro_ligado ? HIGH : LOW);
  }
}

/**
 * Lê a direção e o sentido do acelerometro
 */
void ler_acelerometro() {
  //direcional joystick
  if(accel_x_axis > ACCEL_X_ZERO && (accel_x_axis - ACCEL_X_ZERO) > ACCEL_RESOLUCAO_MIN) {
    ctrl_direcao = DIREITA;
  }
  else if(accel_x_axis < ACCEL_X_ZERO && (ACCEL_X_ZERO - accel_x_axis) > ACCEL_RESOLUCAO_MIN) {
    ctrl_direcao = ESQUERDA;
  }
  else {
    ctrl_direcao = CENTRO;
  }

  //sentido joystick
  if(accel_y_axis > ACCEL_Y_ZERO && (accel_y_axis - ACCEL_Y_ZERO) > ACCEL_RESOLUCAO_MIN) {
    ctrl_sentido = FRENTE;
  }
  else if(accel_y_axis < ACCEL_Y_ZERO && (ACCEL_Y_ZERO - accel_y_axis) > ACCEL_RESOLUCAO_MIN) {
    ctrl_sentido = TRAS;
  }
  else {
    ctrl_sentido = PARADO;
  }

  Serial.print("Acelerometro: ");Serial.print(ctrl_sentido);Serial.print(";");Serial.println(ctrl_direcao);
}

/**
 * Lê a direção e o sentido do joystick
 */
void ler_joystick() {
  //direcional joystick
  if(joy_x_axis > JOY_X_ZERO && (joy_x_axis - JOY_X_ZERO) > JOY_RESOLUCAO_MIN) {
    ctrl_direcao = DIREITA;
  }
  else if(joy_x_axis < JOY_X_ZERO && (JOY_X_ZERO - joy_x_axis) > JOY_RESOLUCAO_MIN) {
    ctrl_direcao = ESQUERDA;
  }
  else {
    ctrl_direcao = CENTRO;
  }

  //sentido joystick
  if(joy_y_axis > JOY_Y_ZERO && (joy_y_axis - JOY_Y_ZERO) > JOY_RESOLUCAO_MIN) {
    ctrl_sentido = FRENTE;
  }
  else if(joy_y_axis < JOY_Y_ZERO && (JOY_Y_ZERO - joy_y_axis) > JOY_RESOLUCAO_MIN) {
    ctrl_sentido = TRAS;
  }
  else {
    ctrl_sentido = PARADO;
  }

  Serial.print("Joystick: ");Serial.print(ctrl_sentido);Serial.print(";");Serial.println(ctrl_direcao);
}

///////////////////////////////////
// CODIGO DE LEITURA DO NUNCHUCK //
///////////////////////////////////

uint8_t outbuf[6];		// array to store arduino output
int cnt = 0;

void nunchuck_init()
{
  // join i2c bus with address 0x52
  Wire.begin ();
  
  Wire.beginTransmission (0x52);	// transmit to device 0x52
  Wire.send (0x40);		// sends memory address
  Wire.send (0x00);		// sends sent a zero.  
  Wire.endTransmission ();	// stop transmitting
}

void nunchuck_read()
{
  cnt = 0;
  nunchuck_send_zero (); // send the request for next bytes  
  delay(1);

  Wire.requestFrom (0x52, 6);	// request data from nunchuck
  while (Wire.available ()) {
    outbuf[cnt] = nunchuck_decode_byte (Wire.receive ());	// receive byte as an integer
    cnt++;
  }

  // If we recieved the 6 bytes, then go print them
  if (cnt >= 5) {
    data_available = true;

    joy_x_axis = outbuf[0];
    joy_y_axis = outbuf[1];
    accel_x_axis = outbuf[2] * 2 * 2; 
    accel_y_axis = outbuf[3] * 2 * 2;
    accel_z_axis = outbuf[4] * 2 * 2;
    z_button = true;
    c_button = true;
  
   // byte outbuf[5] contains bits for z and c buttons
   // it also contains the least significant bits for the accelerometer data
   // so we have to check each bit of byte outbuf[5]
    if ((outbuf[5] >> 0) & 1) {
      z_button = false;
    }
    if ((outbuf[5] >> 1) & 1) {
      c_button = false;
    }
  
    if ((outbuf[5] >> 2) & 1) {
      accel_x_axis += 2;
    }
    if ((outbuf[5] >> 3) & 1) {
      accel_x_axis += 1;
    }
  
    if ((outbuf[5] >> 4) & 1) {
      accel_y_axis += 2;
    }
    if ((outbuf[5] >> 5) & 1) {
      accel_y_axis += 1;
    }
  
    if ((outbuf[5] >> 6) & 1) {
      accel_z_axis += 2;
    }
    if ((outbuf[5] >> 7) & 1) {
      accel_z_axis += 1;
    }
  } else {
    data_available = false;
  }
}

// Print the input data we have recieved
// accel data is 10 bits long
// so we read 8 bits, then we have to add
// on the last 2 bits.  That is why I
// multiply them by 2 * 2
void nunchuck_print()
{
  Serial.print (joy_x_axis, DEC);
  Serial.print ("\t");

  Serial.print (joy_y_axis, DEC);
  Serial.print ("\t");

  Serial.print (accel_x_axis, DEC);
  Serial.print ("\t");

  Serial.print (accel_y_axis, DEC);
  Serial.print ("\t");

  Serial.print (accel_z_axis, DEC);
  Serial.print ("\t");

  Serial.print (z_button, DEC);
  Serial.print ("\t");

  Serial.print (c_button, DEC);
  Serial.print ("\t");

  Serial.print ("\r\n");
}

void nunchuck_send_zero ()
{
  Wire.beginTransmission (0x52);	// transmit to device 0x52
  Wire.send (0x00);		// sends one byte
  Wire.endTransmission ();	// stop transmitting
}

// Encode data to format that most wiimote drivers except
// only needed if you use one of the regular wiimote drivers
char nunchuck_decode_byte (char x)
{
  x = (x ^ 0x17) + 0x17;
  return x;
}
