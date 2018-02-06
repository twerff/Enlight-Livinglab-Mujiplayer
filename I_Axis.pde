String AXISIP = "192.168.1.57";

void setupAxis()
{
  if (!OSCenabled) setupOSC();
  delay(100);
  connectAxisOverOSC();
  traceln("Axis is setup");
}

void checkAxisMessage(OscMessage message)
{
  traceln("axis message " + message);
  
  if (message.checkAddrPattern("/axis/connect"))
  {
    connectAxisOverOSC();
    traceln("Axis connected");
  }
  else
  {
    MULIaction a = new MULIaction();
    a.function = message.addrPattern().replace("/axis/", "");
    int currentValue = 0;
    
    if (message.checkAddrPattern("/axis/updateArea"))
    {
      a.areas = new int[1];
      
      PVector tokenPos = new PVector( message.get(1).intValue(), message.get(2).intValue() );
      
      a.areas[0] = message.get(0).intValue();
      a.ct  = (int) map( tokenPos.x, 0, 255, 8000, 1700 );
      a.dim = (int) map( tokenPos.y, 0, 255, _luminaires.get(0).getMaxDimLevel(), 0 );
      a.finish();
      
      int ct = a.ct;
      int dim = a.dim;
      Area area = _areas.get(message.get(0).intValue());
      Luminaire l = _luminaires.get(_luminaires.size()-4 + message.get(0).intValue());
      
      traceln("set area " + area + " to " + ct + "," + dim);
      
      if (area.getCT() != ct || area.getDimLevel() != dim)
      {
        area.setCT(ct);
        area.setDimLevel(dim);
        traceln("setting area " + area + " to " + ct + "(" + message.get(1).intValue() + "), " + dim + "(" + message.get(2).intValue() + ")");
      }
      if (l.getCT() != ct || l.getDimLevel() != dim)
      {
        //l.setCT(ct);
        //l.setDimLevel(dim);
      }
    }
    
    /*
    else 
    {
      a.areas = new int[message.get(0).intValue()];
      for (int i = 0; i<a.areas.length; i++) a.areas[i] = message.get(currentValue++).intValue();
      
      if (message.checkAddrPattern("/axis/addBoundary"))
      {        
        trace("Boundary received on areas ");
      }
      else if (message.checkAddrPattern("/axis/removeBoundary"))
      {
        trace("Boundary deleted ");
      }
      else if (message.checkAddrPattern("/axis/timeOutBoundary"))
      {
        trace("Boundary timed out ");
      }
      
      for (int i = 0; i<a.areas.length; i++) trace(a.areas[i]+",");
      endTrace();
      
      //a.finish();
    }
    */
  }
}

void connectAxisOverOSC()
{
  OscMessage message = new OscMessage("server/connect");
  NetAddress ad = new NetAddress(AXISIP, OSCPORT);
  oscP5.send(message, ad );//, AXISIP, OSCPORT);
  //oscP5.send(message);
  //Object[] args = {new Object()};
  //oscP5.send("server/connect", args, AXISIP, OSCPORT);
  traceln("sending server/connect to " + AXISIP + ":" + OSCPORT);
}

void errorAxisOverOSC(String error)
{
  OscMessage message = new OscMessage("server/error");
  message.add(1); //1 if new error. 2 if remove error
  message.add(error);
  oscP5.send(message, AXISIP, OSCPORT);
}
