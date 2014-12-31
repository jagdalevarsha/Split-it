import codeanticode.syphon.*;
import processing.serial.*;
import gifAnimation.*;

PGraphics canvas;
SyphonServer server;

Table table;
int energy;
long lastTime = 0;
int hour=0;
int x=0;

int centerX;
int centerY;
int Radius0 = 150;
int Radius2 = 160;
int Radius3 = 180;
PImage SphotoT;
PImage SphotoV;
PImage BphotoT;
PImage BphotoV;

Gif dayGif;
Gif nightGif;
Gif toShowGif;

int totalConsumptionRoom1 =0;
int totalConsumptionRoom2 =0;

Serial myPort;  // Create object from Serial class
String arduinoData = "";     // Data received from the serial port
String splitSensorData[];
boolean showDetailedData = false;
int backgroundValue = 255; //Let it be black by default

int[] Btargetsx;//=round(200+(cos(radians(y)))*Radius3-10);
int[] Btargetsy;//=round(200-(sin(radians(y)))*Radius3-10);
int[] Stargetsx;//=round(200+(cos(radians(y)))*Radius2-5);
int[] Stargetsy;//=round(200-(sin(radians(y)))*Radius2-5); 

void setup() 
{
  size(400, 400, P3D);
  smooth();
  
  dayGif= new Gif(this, "2.gif");
  dayGif.loop();
  
  nightGif = new Gif(this, "1.gif");
  nightGif.loop();

  toShowGif = dayGif;
  
  String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);

  Btargetsx = new int[12];//=round(200+(cos(radians(y)))*Radius3-10);
  Btargetsy = new int[12];//=round(200-(sin(radians(y)))*Radius3-10);
  Stargetsx = new int[12];//=round(200+(cos(radians(y)))*Radius2-5);
  Stargetsy = new int[12];//=round(200-(sin(radians(y)))*Radius2-5); 
  
  for (int i=0; i<12; i++)
  {
    int theta= 75-30*i+360*(floor((i+9)/12));
    println(theta);
    Btargetsx[i]=round(200+(cos(radians(theta)))*Radius3-10);
    Btargetsy[i]=round(200-(sin(radians(theta)))*Radius3-10);
    Stargetsx[i]=round(200+(cos(radians(theta)))*Radius2-5);
    Stargetsy[i]=round(200-(sin(radians(theta)))*Radius2-5);
  }


  background(backgroundValue);
  centerX = 200;
  centerY = 200;
  
  SphotoT = loadImage("bluedot_S.png");
  SphotoV = loadImage("purpledot_S.png");
  BphotoT = loadImage("bluedot_B.png");
  BphotoV = loadImage("purpledot_B.png");
  lastTime = millis();


  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");
  table = loadTable("data.csv", "header");

  canvas = createGraphics(400, 400, P3D);
  canvas.beginDraw();
  canvas.background(backgroundValue);
  canvas.endDraw();
}

void draw()
{
  //readDataFromArduino();
  plotGraph();
}

void plotGraph()
{

  canvas.beginDraw();
  canvas.background(backgroundValue);
  
  canvas.image(toShowGif, 0, 0, 400, 400);
  
  if (millis() - lastTime >1000) 
  {
    
    arduinoData = "";
  
    /**Read Data from Arduino starts **/
  
    if ( myPort.available() > 0) 
    {  
      // If data is available,
      arduinoData = myPort.readStringUntil('\n');         // read it and store it in val
      myPort.clear();
  
    } 
  
    print(arduinoData); //print it out in the console
    
    if(arduinoData != null)
    {
      //Splitting data based on the space
      splitSensorData = split(arduinoData,','); 
            
      //Change the view depending on the value of tilt sensor. 
      //Tilt sensor value is stored in the first element of the array
      //If Tilt sensor value is 0, show high level data, else show detailed data
      
      //Show high level data
      if(splitSensorData[0].equals("1"))
        showDetailedData = false;
        
      //Show low level data
      else
         showDetailedData = true;
      
      if(splitSensorData.length>1)
         backgroundValue = Integer.parseInt(splitSensorData[1].trim());
         
      if(backgroundValue == 0)
        toShowGif = nightGif;
        
      else
        toShowGif = dayGif;
    
      println(showDetailedData); 
      println("BACKGROUND STRING"+backgroundValue); 
      
    }
    
    lastTime = millis();
    x+=1;// angle
    hour+=2;
    //print(hour);
    if (hour>23) 
    {
      hour=0;
      x = 0;
    }
  }
 
      for (int i=0; i<x+1; i++)
      {
        if (compare(i*2))
        {
          canvas.image(BphotoT, Btargetsx[i], Btargetsy[i], 20, 20);
          canvas.image(SphotoV, Stargetsx[i], Stargetsy[i], 10, 10);
          //      x=x+5;
          //      canvas.line(x, 0, x, 100); // do something
        } else
        {
          canvas.image(BphotoV, Btargetsx[i], Btargetsy[i], 20, 20);
          canvas.image(SphotoT, Stargetsx[i], Stargetsy[i], 10, 10);
        } 
        
      if(showDetailedData)
        showDummy();
  }

  canvas.endDraw();

  image(canvas, 0, 0);

  server.sendImage(canvas);
}

void showDummy()
{
  //print("showing Dummy");
  int y = getConsumptionSpilt(hour);
  float angleForRoom1 = 0;    
  angleForRoom1 = y * 3.6;               
  
  //Draw consumption for first room       
  canvas.fill(145, 163, 232);
  canvas.arc(centerX, centerY, 100, 100, radians(270), radians(270+angleForRoom1));

  //Draw consumption for second room
  canvas.fill(110, 47, 171);
  canvas.arc(centerX, centerY, 100, 100, radians(270+angleForRoom1), radians(270+angleForRoom1+(360-angleForRoom1)));

  //Draw the exact percentage
  canvas.fill(0);
  canvas.text(y, centerX+10, centerY);
  canvas.text(100-y, centerX-20, centerY);
}

int getConsumptionSpilt(int noOfRows)
{ 
  totalConsumptionRoom1 =0;
  totalConsumptionRoom2 =0;
  for (int i=0; i<=noOfRows; i=i+2)
  {
    totalConsumptionRoom1 += table.getRow(i).getInt("Energy(Wh)");
    totalConsumptionRoom2 += table.getRow(i+1).getInt("Energy(Wh)");
  }   
  return ((100*totalConsumptionRoom1)/(totalConsumptionRoom1+totalConsumptionRoom2));
}


boolean compare(int x) 
{
  TableRow row1 = table.getRow(x);
  TableRow row2 = table.getRow(x+1);
  int myEnergy = row1.getInt("Energy(Wh)");
  int yourEnergy = row2.getInt("Energy(Wh)");
  //  println(myEnergy);
  if (myEnergy >= yourEnergy) {
    return true;
  } else {
    return false;
  }
} 
