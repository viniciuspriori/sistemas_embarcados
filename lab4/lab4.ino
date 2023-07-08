//TCNT1 > Faz a contagem
//TCCR1A Registradores de controle ===== normalmente configuramos igual a zero.
//TCCT1B determina modo de operação ====== importante 
//       determina o prescaler
          //modo normal( por estouro) após contar 65536
          //Modo CTC (Clear time on compare) Funciona como um PLC,  OCR1A/B é o registrador de comparação.
//TIMSK > Habilita modos de operação ===== importante
//TIFR > flag de interrupção

#include <avr/io.h>
#include <avr/interrupt.h>

#define LED1 8
#define LED2 9
#define LED13 13
#define LDR 3
#define BOTAO 2  

volatile int firedINT;
volatile unsigned long buttonTime ;
unsigned long timeLed13 = 0;
unsigned long timeLDRPrint = 0;
volatile bool interruptFlag = 0;
int VAL_LOW = 54;
int VAL_MEDIUM = 500;
int VAL_HIGH = 610;
           
void pin2ISR(){
  static long lastTime= 0;
  static bool state = true; 

  if ((millis() - lastTime) > 10)
  {
    state = !state;

    lastTime = millis();
    
    if (!state)
    {
      buttonTime = millis();
      firedINT++;
    }
    else
      interruptFlag = 1;
  }
}

void setup() {
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LDR, INPUT);
  pinMode(BOTAO, INPUT_PULLUP);
  EIFR = (1 << INTF1) | (1 << INTF0); 
  attachInterrupt(digitalPinToInterrupt(BOTAO), pin2ISR, CHANGE);
  Serial.begin(115200);

}

int checkLDR(int valor)
{
  int res = 0;
    
  if(valor <= VAL_LOW) {
    res = 0;
  }

  else if((valor > VAL_LOW) && (valor <= VAL_MEDIUM)) 
  {
    res = 1;
  }

  else if((valor > VAL_MEDIUM) && (valor <= VAL_HIGH))
  { 
    res = 2;
  }
  else 
  {
    res = 3;
  }
  
  return res;
}

void toggleLeds(int valor)
{
  switch(valor)
  {
     case 0:
     digitalWrite(LED1, LOW);
     digitalWrite(LED2, LOW);
    
     break;

     case 1:
     digitalWrite(LED1, HIGH);
     digitalWrite(LED2, LOW);
     
     break;

     case 2:
     digitalWrite(LED1, HIGH);
     digitalWrite(LED2, HIGH);
     
     break;

     case 3:
     digitalWrite(LED1, LOW);
     digitalWrite(LED2, HIGH);
     
     break;

     default:
     break;
  }
}

void toggleLed13(int ldrValue)
{
   if( millis() - timeLed13 > 500)
  {
      timeLed13 = millis();
     
      int ledValue = digitalRead(LED13);
     
      if(ledValue == 0)
      {
        printLDRValue(ldrValue);
      }
     
      digitalWrite(LED13, !ledValue);
  }
}

void checkInterruptFlag()
{
  if (interruptFlag)
  {
    interruptFlag = 0;
    Serial.println ("Botao pressionado por " + (String)(millis() - buttonTime) + " milissegundos.");
    Serial.println ("Entrou na INTERRUPCAO: " + (String)firedINT);
  }
}

void printLDRValue(int result)
{
    timeLDRPrint = millis();
    Serial.println("LDR value: " + (String)result);
}

void loop() 
{
    checkInterruptFlag();
    int result = analogRead(LDR);
    toggleLed13(result);     
    byte ans = checkLDR(result); 
    toggleLeds(ans);
}
