import netP5.*;
import oscP5.*;

OscP5 oscP5;
NetAddress targetIp;

int nCircles = 4;
int circleDiam = 40;
int circleRay = circleDiam/2;
int circlePos[][] = {{100,100},{400,100},{600,100},{900,100}};
boolean circleSelect[] = {false,false,false,false};
boolean select = false;
String roles[] = {"Singer","Keyboard","Drum/Bass","Guitar"};

PShape speak;

void setup () {
  size(1000,1000,P3D);
  oscP5 = new OscP5(this,6666);
  targetIp = new NetAddress("192.168.0.2",5510);
  
  speak = loadShape("speaker.svg");
  speak.scale(0.5);
  
  for(int i=0; i<nCircles; i++){
    float xPos = circlePos[i][0]/float(width)*5.02-2.51;
    float yPos = (float(height)-circlePos[i][0])/float(height)*8+1;
    OscMessage xMessage = new OscMessage("/wfs/source" + i + "/x");
    OscMessage yMessage = new OscMessage("/wfs/source" + i + "/y");
    xMessage.add(xPos);
    yMessage.add(yPos);
    oscP5.send(xMessage, targetIp);
    oscP5.send(yMessage, targetIp);
  }
}

void draw() {
  background(0);
  
  for(int i=0; i<nCircles; i++){
    if (mousePressed){
      if(!select && !circleSelect[i] && mouseX >= (circlePos[i][0]-circleRay) && mouseX <= (circlePos[i][0]+circleRay) && mouseY >= (circlePos[i][1]-circleRay) && mouseY <= (circlePos[i][1]+circleRay)){
        circleSelect[i] = true;
        select = true;
      }
    }
    else{
      circleSelect[i] = false;
      select = false;
    }
  }
  
  float xPos = mouseX/float(width)*5.02-2.51;
  float yPos = (float(height)-mouseY)/float(height)*8+1;
  
  for(int i=0; i<nCircles; i++){
    if(circleSelect[i]){
      circlePos[i][0] = mouseX;
      circlePos[i][1] = mouseY;
      OscMessage xMessage = new OscMessage("/wfs/source" + i + "/x");
      OscMessage yMessage = new OscMessage("/wfs/source" + i + "/y");
      xMessage.add(xPos);
      yMessage.add(yPos);
      oscP5.send(xMessage, targetIp);
      oscP5.send(yMessage, targetIp);
    }
    circle(circlePos[i][0],circlePos[i][1],circleDiam);
    textSize(22);
    text(roles[i],circlePos[i][0]+circleRay+5,circlePos[i][1]+10);
  }
  
  shape(speak,258,971);
}
