public static final String TABLETIP = "192.168.1.62";
public static final int LAPTOP = 1;
public static final int PHONE  = 2;
public static final int TABLET = 3;

public static final String[] DEVICETYPES = {"Unknown device","Laptop","Phone","Tablet"};

void checkFloorplanMessage(OscMessage message)
{
  traceln(""+message);
  
  if ( message.checkAddrPattern("/client/connect") )
  {
    traceln(""+message);
    /*
      1. check if new IP, if yes, add to clientlist
      2. send confirmation
      3. send current activities in areas to client
    */
        
    String IP = message.get(0).stringValue();
    int deviceType = message.get(1).intValue();
    int ID = 999;
    
    if (getParticipantByIP(IP)!=null)  ID = getParticipantByIP(IP).getID();
    
    OSCclient client = new OSCclient(IP, deviceType);
    serverConnect(client);
    
    checkIfNewClient(IP);
    
    for (OSCclient c : _clientList)
    {
      if ( c.getIP().equals(IP) )
      {
        println("found participant. updating");
        updateClient(c);
      }
    }
    
  
  }
  
  else if (message.checkAddrPattern("/client/id"))
  {
    String IP = message.get(0).stringValue();
    int id = message.get(1).intValue();
    
    addParticipant(id, IP, "");
  }
  
  else if ( message.checkAddrPattern("/client/ping") )
  {
    String IP = message.get(0).stringValue();
    checkIfNewClient(IP);
    
    for (OSCclient c : _clientList)
    {
      if ( c.getIP().equals(IP) )
      {
        String error = null;
        if (ENLIGHT._unfoundLuminaires.size() > _luminaires.size()/2) error = "No connection to the luminaires. Please check the light switches";
        //else if (ENLIGHT._unfoundLuminaires.size() > 3) error = "Please wait for the server to find all luminaires";
//        
        if (error != null) errorOverOSC(1,error);
        else errorOverOSC(0,"");
        
        pong(c);

      }
    }
  }
  
  else if ( message.checkAddrPattern("/client/update") )
  {
    String IP    = message.get(0).stringValue();
    for (OSCclient c : _clientList)
    {
      if ( c.getIP().equals(IP) )
      {
        updateClient(c);
      }
    }
  }
  /*
  else if ( message.checkAddrPattern("/client/toggleLight") )
  {
    //ENLIGHT.createMessage("OnOffChanged", ADDRESS_PC, _luminaires.get(_luminaires.size()-1).getOn()?0:1);
    
    traceln("off button pressed at tablet");
    
    if (_luminaires.get(_luminaires.size()-1).getOn())
    {
      ENLIGHT.createMessage("DimLevelChanged", ADDRESS_PC, 0);
      for (Luminaire l : _luminaires) l.setOn(false);
      removePolygon(0,1,2,3);
      for (OSCclient c : _clientList) updateClient(c);
    }
    else
    {
      //ENLIGHT.createMessage("DimLevelChanged", ADDRESS_PC, 3000);
      for (Luminaire l : _luminaires)
      {
        if (l.getScope() != STUDIO)
        {
          ENLIGHT.createMessage("DimLevelChanged", ADDRESS_PC, l.getAddress(), l.getDimLevel());
          l.setOn(true);
        }
      }
    }
  }
  */
  //THE ACTIONS
  else
  {
    traceln(""+message);
    MULIaction a = new MULIaction();
    int currentValue = 0;
    
    a.IP = message.get(currentValue++).stringValue();      //set the IP address
    
    
    if (a.IP.length() < 3)                                 //if you receive an ID, then it is the tablet
    {
      a.ID = int(a.IP);
      a.IP = TABLETIP;
    }
    else if (getParticipantByIP(a.IP)!=null)   a.ID = getParticipantByIP(a.IP).getID();
    
    traceln("new action found from IP " + a.IP + ", id: " + a.ID);
    
    a.duration = message.get(currentValue++).intValue();   //set the duration
    
    int numAreas = message.get(currentValue++).intValue(); //set the areas
    a.areas = new int[numAreas];
    for (int i = 0; i < numAreas; i++) a.areas[i] = message.get(currentValue++).intValue();
    
    a.function = message.addrPattern().replace("/client/", "");
    
    if ( message.checkAddrPattern("/client/previewDrawing") )
    {
      a.act = message.get(currentValue++).intValue();
      a.ct  = message.get(currentValue++).intValue();
      a.dim = message.get(currentValue++).intValue();
      
      a.finish();
      
      newPolygon(a.act, a.ct, a.dim, a.areas);
    }
    else if ( message.checkAddrPattern("/client/applyDrawing") )
    {
      int act = message.get(currentValue++).intValue();  //dont save the act yet, as none is chosen yet
      a.ct    = message.get(currentValue++).intValue();
      a.dim   = message.get(currentValue++).intValue();
      
      println("this is too much");
      
      a.finish();
      
      newPolygon(act, a.ct, a.dim, a.areas);
    }
    
    else if ( message.checkAddrPattern("/client/removeDrawing") )
    {
      a.finish();
      
      turnOff(a.areas);
      removePolygon(a.areas);
    }
    
    else if ( message.checkAddrPattern("/client/setActivity") )
    {
      a.act = message.get(currentValue++).intValue();
      a.finish();
      
      int ct  = message.get(currentValue++).intValue();
      int dim = message.get(currentValue++).intValue();
      
      newPolygon(a.act, ct, dim, a.areas);
    }
    else if ( message.checkAddrPattern("/client/removeActivity") )
    {
      traceln("remove activity received. This is not used in the program!");
    }
    
    if (getParticipantByIP(a.IP) != null) getParticipantByIP(a.IP).addAction(a);
    println(getParticipantByIP(a.IP).IP);
    
    traceln(a.function + " received from " + a.IP);
    
    //update all clients except the sender
    updateClientsExcept(a.IP);
  }
}
