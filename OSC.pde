import oscP5.*;
import netP5.*;

OscP5 oscP5;
int X, Y;
boolean OSCenabled = false;

final static int OSCPORT = 12000;

ArrayList<OSCclient> _clientList = new ArrayList<OSCclient>();

void setupOSC()
{
  oscP5 = new OscP5(this, OSCPORT);
  oscP5.properties().setRemoteAddress("127.0.0.1", OSCPORT );
  OSCenabled = true;
}

void updateClient(OSCclient client)
{
  OscMessage m = new OscMessage("/server/update");

  traceln("updateing client " + client.getNetAddress());

  m.add(_polygons.size());

  for (Poly p : _polygons)
  {
    //print("polygon with ");
    m.add(p.areas.size());
    //print(p.areas.size() + " areas:");

    for (int i : p.areas)
    {
      m.add(i);
    }

    traceln(p.ct + " " + p.dimLevel + " " + p.activity);
    m.add(p.ct );
    m.add(p.dimLevel );
    m.add(p.activity );
  }

  oscP5.send(m, client.getNetAddress());
}

public void updateClientsExcept(OSCclient client)
{
  for (OSCclient c : _clientList)
  {
    if (c != client)
    {
      updateClient(c);
    }
  }
}

public void updateClientsExcept(String ip)
{
  for (OSCclient c : _clientList)
  {
    if (!c.getIP().equals(ip))
    {
      updateClient(c);
    }
  }
}

public int getConnectedClients()
{
  int nr = 0;
  for (OSCclient c : _clientList) if (c.getConnected()) nr++;
  return nr;
}

void errorOverOSC(int error, String value)
{
  OscMessage m = new OscMessage("/server/error");
  m.add(error);
  m.add(value);
  for (OSCclient c : _clientList) oscP5.send(m, c.getNetAddress());
}

void serverConnect(OSCclient client)
{
  OscMessage m = new OscMessage("/server/connect");
  m.add(TILE);
  oscP5.send(m, client.getNetAddress());
  updateClient(client);
}

void pong(OSCclient client)
{
  OscMessage message = new OscMessage("/server/pong");
  oscP5.send(message, client.getNetAddress());
}

void newParticipantOverOSC(OSCclient client)
{
  OscMessage message = new OscMessage("/server/setup");
  oscP5.send(message, client.getNetAddress());
}

void newParticipantOverOSC(String ip)
{
  OscMessage message = new OscMessage("/server/setup");
  oscP5.send(message, ip, OSCPORT);
}

public boolean checkIfNewClient(String IP)
{
  for (OSCclient c : _clientList)
  {
    if ( c.getIP().equals(IP) )
    {
      c.newMessage();
      return false;
    }
  }  

  
  OSCclient OSCclient = new OSCclient(IP, 0);//doet t bneit goed...
  _clientList.add(OSCclient);

  //if (getParticipantByIP(IP) == null) newParticipantOverOSC(IP);

  return true;
}

OSCclient getOSCclient(String IP)
{
  for(OSCclient c : _clientList)
  {
    if ( c.getIP().equals(IP) ) return c;
  }
  
  OSCclient OSCclient = new OSCclient(IP, 0);//doet t bneit goed...
  _clientList.add(OSCclient);
  return OSCclient;
}


void oscEvent(OscMessage message)
{
  // CHECK IF IT IS A NEW OSCclient AND ADD IT!!!!
  String ipaddress = message.netAddress().address();
  //checkIfNewOSCclient(ipaddresOSCclientOSCclient OSCclient = getOSCclient(ipaddress);

  OSCclient OSCclient = getOSCclient(ipaddress);
  
  if (message.addrPattern().contains("OSCclient"))    checkFloorplanMessage(message);
  else if (message.addrPattern().contains("axis")) checkAxisMessage(message);
  
  //OPEN LIBRARY
  else 
  {
    if (message.checkAddrPattern("/Enlight/connect"))
    {
      traceln("OSCclient connected");
    }
    else
    {
      int lampID = message.get(0).intValue() + 0;
      int numValues = message.get(1).intValue();
      
      //COVE
      if (lampID > 199)
      {
        lampID = int( lampID-200 );

        Cove l = getCove(lampID);

        if (message.checkAddrPattern("/Enlight/setOn"))
        {
          if (message.get(2).intValue() == 0) l.turnOff();
          else l.turnOn();
        } else if (message.checkAddrPattern("/Enlight/setDimLevel"))
        {
          int value = int( map(message.get(2).intValue(), 0, 65535, 0, 255) );
          l.setBrightness(value);
        } else if (message.checkAddrPattern("/Enlight/setCT"))
        {
          int value = message.get(2).intValue();
          color c = CTtoHEX(value);

          if (numValues > 1) l.setFadetimeInMS(message.get(3).intValue());
          l.setRGB(red(c), green(c), blue(c));
        } else if (message.checkAddrPattern("/Enlight/setRGB"))
        {
          int r = message.get(2).intValue();
          int g = message.get(3).intValue();
          int b = message.get(4).intValue();

          if (numValues > 3) l.setFadetimeInMS(message.get(5).intValue());
          l.setRGB(r, g, b);
        }
      }
      //HUE
      else if (lampID > 99) 
      {
        HueLamp l = _hueLamps.get(lampID-100);

        if (message.checkAddrPattern("/Enlight/setOn"))
        {
          if (message.get(2).intValue() == 0) l.turnOff();
          else l.turnOn();
        } else if (message.checkAddrPattern("/Enlight/setDimLevel"))
        {
          int value = int( map(message.get(2).intValue(), 0, 65535, 0, 255) );
          if (numValues > 1) l.setFadetimeInMS(message.get(3).intValue());
          l.setBrightness(value);
        } else if (message.checkAddrPattern("/Enlight/setBrightness"))
        {
          int value = message.get(2).intValue();
          if (numValues > 1) l.setFadetimeInMS(message.get(3).intValue());
          l.setBrightness(value);
        } else if (message.checkAddrPattern("/Enlight/setCT"))
        {
          int value = message.get(2).intValue();
          value = constrain(value, 2000, 6500);
          int ct = (int) map(value, 2000, 6500, 500, 154);

          if (numValues > 1) l.setFadetimeInMS(message.get(3).intValue());
          l.setCT(ct);
        } else if (message.checkAddrPattern("/Enlight/setRGB"))
        {
          int r = message.get(2).intValue();
          int g = message.get(3).intValue();
          int b = message.get(4).intValue();

          if (numValues > 3) l.setFadetimeInMS(message.get(5).intValue());
          l.setRGB(r, g, b);
        }
      } 
      //ENGLIGH LUMINAIRE
      else
      {
        Luminaire l = _luminaires.get(lampID);
        
        OSCclient.newMessage(l);
        
        if (message.checkAddrPattern("/Enlight/setOn"))
        {
          boolean onState = true;
          if (message.get(2).intValue() == 0) onState = false;
          l.setOn(onState);

          //if (onState) traceln("turn on lamp " + lampID);
          //else traceln("turn off lamp " + lampID);
        } else if (message.checkAddrPattern("/Enlight/setCT"))
        {
          if (numValues == 1) l.setCT(message.get(2).intValue());
          else l.setCT(message.get(2).intValue(), message.get(3).intValue()/100);

          //traceln("set "+ lampID + " to ct " + message.get(2).intValue());
        } else if (message.checkAddrPattern("/Enlight/setDimLevel"))
        {
          if (numValues == 1) l.setDimLevel(message.get(2).intValue());
          else l.setDimLevel(message.get(2).intValue(), message.get(3).intValue()/100);

          //traceln("set "+ lampID + " to dimLevel " + message.get(2).intValue());
        } else if (message.checkAddrPattern("/Enlight/setRGB"))
        {
          if (numValues > 2)
          {
            int r = message.get(2).intValue();
            int g = message.get(3).intValue();
            int b = message.get(4).intValue();

            if (numValues == 3) l.setRGB(r, g, b);
            else l.setRGB(r, g, b, message.get(5).intValue());
          }
        } else traceln("unknown OSC message: " + message);
      }
    }
  }
}


class OSCclient
{
  float x,y,width,height;
  private String name; //should be name
  public int deviceType = 0;
  private int connectionTimeout = 5*60*1000;
  long lastMessage;
  private int messageTimeout = 5000;
  boolean rx = true;
  
  ArrayList<LuminaireMessage> _messages = new ArrayList<LuminaireMessage>();
  
  public OSCclient()
  {
    init();
  }
  
  public OSCclient(String _name)
  {
    name = _name;
    init();
  }
  
  public OSCclient(String _name, int d)
  {
    name = _name;
    deviceType = d;
    init();
  }
  
  public NetAddress getNetAddress()
  {
    return new NetAddress(name, OSCPORT);
  }
  
  private void init()
  {
    width = 10;
    height = 10;
    x = consoleX;
    y = 250+_clientList.size()*height*2;
    lastMessage = millis();
  }
  
  public void newMessage()
  {
    lastMessage = millis();
    rx = true;
  }
  
  
  public void newMessage(Luminaire l)
  {
    newMessage();
    _messages.add(new LuminaireMessage(this,l));
    
    for (Luminaire ll : _luminaires) if (ll == l) return;
    _luminaires.add(l);
  }

  public String getIP() //should be name
  {
    return name;
  }
  
  public String getName()
  {
    return name;
  }
  
  public boolean getConnected()
  {
    return (millis() < lastMessage + connectionTimeout);
  }
  
  

  public String getDeviceType()
  {
    return DEVICETYPES[deviceType];
  }


  public void draw()
  {
    if (!getConnected()) return;
    else
    {
      drawMessages();
      
      //draw the square
      fill(0);
      if (rx) fill(255);
      rect(x,y,width,height);
      fill(0);
      text(name, x + width+5, y+height);
      rx = false;
    }
  }
  
  void drawMessages()
  {
    for (int i = 0; i<_messages.size(); i++)
    {
      LuminaireMessage m = _messages.get(i);
      if (m!= null) m.draw();
      if (m.finished()) _messages.remove(i);
    }
   
  }
  
  public PVector getCenter()
  {
    return new PVector(x+width/2,y+height/2);
  }
}

class LuminaireMessage
{
  Luminaire l;
  OSCclient c;
  long receiveTime;
  int messageTimeOut = 1000;
  
  public LuminaireMessage(OSCclient _c, Luminaire _l)
  {
    l = _l;
    c = _c;
    receiveTime = millis();
  }
  
  public void draw()
  {
    int strokeOpacity = (int) map((millis() - receiveTime), messageTimeOut,0, 0,255);
    stroke(0,strokeOpacity);
    strokeWeight(0.5);
    
    line(c.getCenter().x, c.getCenter().y, l.getCenter().x, l.getCenter().y);
  }
  
  public boolean finished()
  {
    return (millis() > receiveTime + messageTimeOut);
  }
}



void dashedLine(float x1, float y1, float x2, float y2)
{
  dashedLine(x1,y1,x2,y2,3,6);
}

void dashedLine(float x1, float y1, float x2, float y2, int l, int g) 
{
    float pc = dist(x1, y1, x2, y2) / 100;
    float pcCount = 1;
    float lPercent = 0;
    float gPercent = 0;
    float currentPos = 0;
    float xx1 = 0;
    float yy1 = 0;
    float xx2 = 0;
    float yy2 = 0;
 
    while (int(pcCount * pc) < l) pcCount++;
    lPercent = pcCount;
    pcCount = 1;
    while (int(pcCount * pc) < g) pcCount++;
    gPercent = pcCount;
 
    lPercent = lPercent / 100;
    gPercent = gPercent / 100;
    
    while (currentPos < 1) 
    {
        xx1 = lerp(x1, x2, currentPos);
        yy1 = lerp(y1, y2, currentPos);
        xx2 = lerp(x1, x2, currentPos + lPercent);
        yy2 = lerp(y1, y2, currentPos + lPercent);
        
        if (x1 > x2 && xx2 < x2) xx2 = x2;
        if (x1 < x2 && xx2 > x2) xx2 = x2;
        if (y1 > y2 && yy2 < y2) yy2 = y2;
        if (y1 < y2 && yy2 > y2) yy2 = y2;
 
        line(xx1, yy1, xx2, yy2);
        currentPos = currentPos + lPercent + gPercent;
    }
}

