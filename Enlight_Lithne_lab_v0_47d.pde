import processing.serial.*;
import ili.lithne.*;
import cc.arduino.*;
import controlP5.*;


//Picked up _JAVA_OPTIONS: -Xmx512M
//ADDED enlightLivingLabPort.clear(); to clear the buffer. could give problems...

/*TODO
  - only println OSC if osc client is selected...
  - move through XYZ colorspace (instead of RGB)
  - add a restart serial port button
  - make converter for Enlight RGB
  - make converter for perceived dimlevel/brightness (depending on ct)
*/

//setPresence() in L now also changes dim + ct... for testing...

//variables for updating
boolean updateDraw = true;
int drawInterval = 25;
long lastDraw = 0;

int sendInterval = 200;
long lastSend = 0;

int dataCheckInterval = 200;
long lastDataCheck = 0;

//interfaces
ArrayList<Interface> _interfaces = new ArrayList<Interface>();
UI ui;

boolean startOfTheDay = true;

void setup()
{
  size(800,600);
  smooth();
  fill(#FFFFFF);
  output = createWriter("log_"+year()+month()+day()+hour()+minute()+".txt");
    
  setupLogger();
  setupLithne();
  setupEnlight();
  setupLuminaires();
  setupMap();
  //setupDMX("COM8");
  //setupCoves(5);
  //setupHue("192.168.1.85","w5C1y3vjlnhOXW4YGIMokiRNxQoNtyzTQ9Z5fENN",3);
  //setupHue("192.168.1.75","rhVvX5AoZcJPOiPBfSQtI74yo4uopa3VLqx7GNWk",20);
  
  setupInterfaces();
  setupOSC();
  
  createXML(getClass().getSimpleName() + ".xml"); 
  
  //MULI STUDY
  //setupMULI();
  setupAreas();
  //loadMapXML();
  //setupSound();
  //if(lithneEnabled) setupPointers();
  
  //setupWeather();

  
  traceln("Setup completed");
  
}

void setupInterfaces()
{
  _interfaces = new ArrayList<Interface>();
  ui = new UI(this);
  _interfaces.add(ui);
  
}

void draw()
{
  //if (doOnce()) setupAxis();
  
  if (millis()-lastDraw > drawInterval)
  {
    lastDraw = millis();
    
    drawMap();
    ui.draw();
    
    for (Interface i : _interfaces) i.draw();
    
    
    if (OSCenabled) 
    {
      for (int i=0 ;i<_clientList.size(); i++) if (!_clientList.get(i).getConnected()) _clientList.remove(i);
      for (OSCclient c : _clientList) c.draw();
    }
    
    
    if (MULIenabled) 
    {
      muli.draw();
      //for (Indicator i : _indicators) i.draw();
    }
    
    for (HueLamp h:_hueLamps) h.draw();
    
    if (enlightEnabled) 
    {
      ENLIGHT.draw();
      ENLIGHT2.draw();
    }
    
    else traceln("enlight disabled..");
    
    if (millis() > 10000)
    {
      if (weatherEnabled) doWeather();
      if (discoEnabled) doDisco();
      if (chaseEnabled) doChase(500);
      if (circadianEnabled) doCircadianRhythm(FLEX);
    }
  }
    
  ///MULI
  //only for activity drawer
//  if (hour() == 22 && minute() == 15 && startOfTheDay) 
//  {
//    if (_polygons.size() > 0) removePolygon(0,1,2,3);
//    noMailSendToday = true;
//    checkDate();
//    startOfTheDay = false;
//    turnOffIndicators();
//  }
//  if (hour() > 5 && !startOfTheDay) 
//  {
//    //setup();
//    startOfTheDay = true;
//  }
}

boolean firstTime = true;

boolean doOnce()
{
  if (ENLIGHT._unfoundLuminaires.size() == 0 && firstTime)
  {
    firstTime = false;
    return true;
  }
  return false;
}


void exit()
{
  log("Server", "", "", "closed");
  //if (enlightEnabled) enlightLivingLabPort.stop();
  //if (enlightEnabled) enlightCorridorPort.stop();
}


boolean on = true;
int tempct = 0;


void mousePressed()
{  
  ui.mousePressed(mouseX, mouseY);
  
  if(ui.hitLuminaire(mouseX, mouseY) == null)
  {
    boolean hit = false;
    
    for (Area a : _areas)
    {
      if (pixelInArea(new PVector(mouseX,mouseY),a)) 
      {
        hit = true;
        a.toggleSelect();
      }
    }
    if (hit) return;
    
    for (Room r : _rooms)
    {
      if (pixelInItem(new PVector(mouseX,mouseY),r)) r.toggleSelect();
    }
  }
  //gradient("CT", new PVector(250,300), new PVector(600,300), 500, 8000);
}

void mouseReleased()
{
  //ui.mouseReleased();
}

void mouseDragged()
{
}

void mouseMoved()
{
  for (Room r:_rooms)
  {
    if (r.mouseOver()) r.hit = true;
    else if (r.hit) r.hit = false;
  }
  
  for (Area a:_areas)
  {
    if (pixelInArea(new PVector(mouseX,mouseY), a)) 
    {
      a.hit = true;
      for (Room r:_rooms) r.hit = false;
    }
    else if (a.hit) a.hit = false;
  }
}
