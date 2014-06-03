#include <WProgram.h>



extern "C" 

void myprog();



int main(void) 
{
  
  init();

  
  Serial.begin(9600);

  
  myprog();

  
  return 0;

}
