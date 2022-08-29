[...]
// main program infinite loop infinite loop
  void run()
  {
    while (true) {
      //check if reset btn is pressed 
      if (XGpio_DiscreteRead(&gpio, 1))
        {
          // IP and Zynq reset 
          [....]
        }
      else
        {
          controlFPGA();  //send controllers value to IP
          fControlUI->update(); //get new controller values
        }
    }
