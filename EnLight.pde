import processing.serial.*;

public static int ENLIGHTBAUD = 115200;
public static String ENLIGHTPORT = "COM13";
public static String CORRIDORPORT = "COM22";

Enlight ENLIGHT;
Enlight ENLIGHT2; //for the corridor...

boolean enlightEnabled = false;
int randomAnnounceDelay = 240;

void setupEnlight()
{
  try
  {
    ENLIGHT = new Enlight(this, ENLIGHTPORT);
    ENLIGHT2 = new Enlight(this, CORRIDORPORT);  //for the corridor...
    enlightEnabled = true;
  }
  catch(Exception e)
  {
    traceln("error: " + e);
  }
}


class Enlight
{
  Serial serial;
  String PORT;

  //types of events sent by the dongle
  String eventTypes[] = {
  };
  String events[] = {
  };

  long lastSend = 0;
  int sendInterval = 60;
  boolean readyToSend = true;  //change to waitingForConfirmation and inverse
  int confirmationTimeOut = 500;

  int announceInterval = 5*1000;  //increases over time
  long lastAnnounce;
  int nrOfAnnounces;

  EnlightMessage lastSentMessage;

  ArrayList<Luminaire> _unfoundLuminaires = new ArrayList<Luminaire>();
  ArrayList<EnlightMessage> outbox = new ArrayList<EnlightMessage>();

  ArrayList<Luminaire> _unfoundLuminaires(int scope)
  {
    ArrayList<Luminaire> lums = new ArrayList<Luminaire>();

    for (Luminaire l : _unfoundLuminaires)
    {
      if (l.getScope() == scope) lums.add(l);
    }
    return lums;
  }


  public Enlight(PApplet p, String port)
  {
    PORT = port;
    serial = new Serial(p, port, ENLIGHTBAUD);
    addEvents();
    traceln("ENLIGHT ready at " + PORT);
  }


  void draw()
  {
    drawRXTX();

    String s = "ENLIGHT outbox: ";
    for (int i = 0; i<outbox.size (); i++) s+=outbox.get(i).priority + " ";
    fill(0);
    text(s, 10, height-20);

    //MAYBE THIS ONLY HAS TO BE CHECKED WHEN THERE ARE MESSAGES TO SEND....
    if (millis() - lastAnnounce > announceInterval && POWERON)  
    {
      lastAnnounce = millis();
      checkAnnounced();
    }

    //if there are no messages, then you are done :)
    if (outbox.size() == 0) return;

    //if the last message is not confirmed
    if (!readyToSend)
    {
      if (millis() - lastSentMessage.getSendTime() > confirmationTimeOut ) fail(lastSentMessage);
    }

    if (millis()-lastSend > sendInterval)
    {
      lastSend = millis();
      sendMessage(outbox.get(0));
    }
  }

  void TX()
  {
    tx = true;
  }

  void RX()
  {
    rx = true;
  }

  boolean tx, rx = false;

  void drawRXTX()
  {
    int xx = 750;
    if (PORT.equals("COM22")) xx = 700;

    int yy = height-30;
    noStroke();
    fill(0);
    textSize(8);
    text(PORT, xx, yy-12);

    text("RX", xx+12, yy-2);
    text("TX", xx+12, yy+10);

    if (rx) fill(255);
    rect(xx, yy-12, 10, 10);
    fill(0);
    if (tx) fill(255);
    rect(xx, yy, 10, 10);

    rx = tx = false;
  }

  public void fail(EnlightMessage m)
  {
    m.fail++;
    m.priority++;

    if (m.fail < 5) 
    {
      addMessageToOutbox(m);
      traceln("FAIL: " + m.getEventName() + " to " + m.getRecipient() + " failed " + m.fail + " times after " + (millis() - m.getSendTime()) + "ms");
    } else 
    {
      traceln("EPIC FAIL: " + m.getEventName() + " timed out to " + m.getRecipient() + " after " + m.fail + " times.");
      requestToAnnounce(getLuminaireByAddress(m.getRecipient()));
    }
    readyToSend = true;
  }

  int announceTry = 0;

  private void checkAnnounced()
  {
    int unfoundCount = 0;
    announceTry++;
    
    for (Luminaire l : _luminaires)
    {
      if (!l.getAnnounced()) unfoundCount++;
    }
    
    if (unfoundCount == 0)
    {
      discoveryDone();
      return;
    } else if (unfoundCount > _unfoundLuminaires.size() && announceTry > 10) 
    {
      traceln("Tried to discover luminaires without success " + announceTry + " times. Are the lights off?");
      POWERON = false;
      return;
    }
    else
    {
      for (Luminaire l : _luminaires)
      {
        if (!l.getAnnounced())
        {
          boolean already = false;
          for (Luminaire ll : _unfoundLuminaires) if (ll == l) already =true;
          if (!already) _unfoundLuminaires.add(l);
        }
      }
      requestToAnnounce(_unfoundLuminaires);
    }
  }



  ///// PROCESS INCOMING MESSAGE
  public void processIncommingMessage(String message)
  {
    POWERON = true;
    RX();

    int _NARPos = message.indexOf("NAR(");
    int _64BitPos = message.indexOf("(>)");
    int _incomingMSGPos = message.indexOf("MSG(");
    int _confirmationMSGPos = message.indexOf("buffer: ");      
    int _DANPos = message.indexOf("DAN(");
    int _FAILPos = message.indexOf("FAIL");

    // NAR message (New Announce Request) 
    if ( _NARPos > -1 && _64BitPos > -1 )
    {
      String _16Bit = message.substring(_NARPos+4, _NARPos+8).toLowerCase();
      String _64Bit = message.substring(_64BitPos+3, _64BitPos+19).toLowerCase();

      for (int i = 0; i<_luminaires.size (); i++)
      {
        Luminaire l = getLuminaire(i);
        if (join(split(l.getAddress().toLowerCase(), ':'), "").equals(_64Bit))
        {
          l.setShortAddress(_16Bit);
          l.setAnnounced(true);
          l.deselect();
          _unfoundLuminaires.remove( l );
        }
      }
    }

    //DAN(BD8A) 00158D000035D361    looks like a message when lamp is turned on
    else if ( _DANPos > -1 )
    {
      String _16Bit = message.substring(_DANPos+4, _DANPos+8).toLowerCase();
      String _64Bit = message.substring(_64BitPos+3, _64BitPos+29).toLowerCase();

      Luminaire l = getLuminaireByShortAddress(_16Bit);

      traceln(l.getName() + " turned on");
      POWERON = true;
      //getScope(l)._scopeLuminaires
      requestToAnnounce(l);
    }

    //announce return
    else if (message.indexOf("Service discovery done.") > -1)
    {         
      if (_unfoundLuminaires.size() == 0)
      {
        discoveryDone();
      }
    } 
    //receiving a command/sensor thingy???
    else if ( _incomingMSGPos > -1 )
    {
      String command = message.substring(_incomingMSGPos+15, _incomingMSGPos+17).toLowerCase(); 
      String address = message.substring(_incomingMSGPos+4, _incomingMSGPos+8).toLowerCase(); 

      String commandName = "?"; 

      for (int i = 0; i < commands.length; i++)
      {
        if (commands[i][0].equals(command) )
        {
          commandName = commands[i][1];
        }
      }

      Luminaire l = getLuminaireByShortAddress(address); 

      //if presence detected, set presence
      if (command.equals("80")) l.setPresence(true); 
      if (command.equals("81")) l.setAnnounced(true); 
      traceln(commandName + " (" + command + ") from " + l.getID());
    }  

    //if a confirmation is received
    else if (_confirmationMSGPos > -1)
    {
      String lastAddress = lastSentMessage.getBody().substring(21, 21+15).toUpperCase(); 

      String[] allChars = new String[lastAddress.length()/2]; 

      for (int i = 0; i < lastAddress.length ()/2; i++) allChars[i] = lastAddress.charAt(i*2) +""+ lastAddress.charAt(i*2+1); 

      lastAddress = join(allChars, " "); 

      if (message.indexOf(lastAddress) > -1) 
      {
        //outbox.remove(lastSentMessage);
        readyToSend = true; 

        //here I should add a smart thing like: 
        //if a CT message was sent and it is now confirmed,
        //only then save the CT value to the Luminaire object
        //if (lastSentMessage.getEventName().contains("dimLevel")) println("dim confirmed");
        //if (lastSentMessage.getEventName().contains("CT"))       println("ct confirmed");
      }
    } else if (message.contains("T00000000:TX (CLI) Ucast") || message.contains("Msg: clus 0xFC30, cmd 0x80, len 27")) //part of the confirm message
    {
      //cleanMessage(message);
      //traceln(message);
    }

    //if a fail message is received
    else if (_FAILPos > -1)
    {
      String _16Bit = "0x" + message.substring(_FAILPos+5, _FAILPos+9).toLowerCase(); 
      if (!_16Bit.equals("0xfffd"))
      {
        traceln("FAIL message received, not send again: " + _16Bit + ": " + cleanMessage(message)); 

        //send the same message again...
        //fail(lastSentMessage);
      }
    } else if (message.equals(" Msg: clus 0xFC30, cmd 0x80, len 32 ")); 
    else if (message.equals(" EnlightDongle>Msg: clus 0xFC30, cmd 0x80, len 32 ")); 
    //if nothing of the above
    else 
    {
      traceln("unknown message: " + message);
    }
  }
  /////

  ////REQUEST TO ANNOUNCE MESSAGE////////////////////////////////////////////////// 

  void requestToAnnounce(ArrayList<Luminaire> luminaires)
  {
    for (int i = 0; i<luminaires.size (); i++) requestToAnnounce( luminaires.get(i) );
  }

  void requestToAnnounce(Luminaire l)
  {
    //If the luminaire is not connected to this USB, skip it
    if (l.EnlightParent != this) return;

    announceInterval = 3*1000;
    lastAnnounce = millis();

    //check if it is already being requested
    Boolean listed = false;
    for (Luminaire u : _unfoundLuminaires)
    {
      if (u == l) 
      {
        listed = true;
      }
    }

    if (!listed) _unfoundLuminaires.add(l);

    //traceln("ENLIGHT: discovering " + l.getAddress());
    //discovering = true;
    String address = join(split(l.getAddress(), ':'), "");  //remove : from the address
    String m = "zdo nwk {" + address + "}\r\n";

    EnlightMessage message = new EnlightMessage(m, this);

    message.setConfirmation(false);
    message.setRecipient(l.getAddress());
    message.setFrom("server");
    message.setEvent("requestToAnnounce");
    message.setPriority(99);                  //set the highest priority

    addMessageToOutbox(message);
  }

  public void discoveryDone()
  {
    traceln("ENLIGHT("+PORT+"): discovery done");
    announceTry = 0;
    announceInterval = 60*1000;
  }

  private void sendMessage(EnlightMessage m)
  {
    try
    {
      m.sendTime = millis();
      serial.write( m.getBody() );
      TX();
      outbox.remove(m);
      lastSentMessage = m;
      if (m.confirmationRequired()) readyToSend = false;
    }
    catch (Exception e)
    {
      traceln("ENLIGHT sending error " + e);
    }
  }

  void AddEvent(String code, String name)
  {
    eventTypes = append(eventTypes, name);
    events = append(events, code);
  }

  void addEvents()
  {
    AddEvent("0001", "Initialized");
    AddEvent("0003", "LuminaireReset");
    AddEvent("0004", "LuminaireToBeReseted");
    AddEvent("0005", "ClearZigbeeContext");
    AddEvent("000E", "CommissionLuminaire");                //uint8: LLE", bool: OnOff", uint16: dim level", uint16 Xcolor", uint16 Ycolor
    AddEvent("0020", "IamAlive");
    AddEvent("0101", "TimerExpired");
    AddEvent("0102", "FailureDetected");
    AddEvent("0103", "CounterUpdated");          //uint8: Counter_id", uint8 Counter_value
    AddEvent("0104", "TimeUpdated");             //uint32: #seconds after 1-1-2000
    AddEvent("0201", "AlarmActivated");
    AddEvent("0202", "AlarmReset");
    AddEvent("0301", "StatusUpdated");           //uint8
    AddEvent("0302", "PowerUsageUpdated");       //uint32 [milliwatts]
    AddEvent("1001", "LightlevelUpdated");      //uint16 [???] actual light level
    AddEvent("1101", "TemperatureUpdated");     //uint16 [Kelvin] actual temperature
    AddEvent("1101", "HumidityUpdated");        //uint16 [??] actual humidity level
    AddEvent("1201", "PresenceDetected");
    AddEvent("1203", "PresenceReported");       //uint8 1 ==> presence", 0 ==> absence
    AddEvent("1202", "AbsenceDetected");
    AddEvent("1301", "PersonCountChanged");     //uint8: personcount", uint8: pervious person count", uint16 person ID", uint8 zone id
    AddEvent("1302", "PersonEntered");          //uint8: personcount", uint16 person ID", uint8 zone id
    AddEvent("1303", "PersonLeft");             //uint8: personcount", uint16 person ID", uint8 zone id
    AddEvent("1304", "PersonSit");              //uint8: personcount", uint16 person ID", uint8 zone id
    AddEvent("1305", "PersonStand");            //uint8: personcount", uint16 person ID", uint8 zone id
    AddEvent("1401", "MovementDetected");       //uint16 [dm] x-position", uint16 [dm] y-position", int16 person ID", uint8 zone id
    AddEvent("1502", "ActivityDetected");       //enum8: activity", int16: personID", uint8: zone id
    AddEvent("1601", "PersonIdentified");       //int16: person id
    AddEvent("2001", "SceneSelected");          //uint16: scene id

    AddEvent("2101", "OnOffChanged");           //bool: on=true", off=false
    AddEvent("2102", "DimLevelChanged");        //uint8: dimlevel
    AddEvent("2103", "SwitchToggled");
    AddEvent("2104", "ColorChangedXY");         //uint16: XColor", uint16 YColor
    AddEvent("2105", "ColorChangedSV");        //uint8: hue", uint8 saturation
    AddEvent("2106", "ColorChangedCCT");        //uint16: [Kelvin] CCT
    AddEvent("2107", "ColorChangedRGB");        //uint8: red", uint8: green", uint8 blu


    AddEvent("2200", "Event00");  //dimlevel chanched on scope: uint16: dimlevel, uint8 scope
    AddEvent("2201", "Event01");  //ct & dimlevel changed
    AddEvent("2202", "Event02");  //ct + fadeTime
    AddEvent("2203", "Event03");  //dimlevel + fadeTime
    AddEvent("2204", "Event04");
    AddEvent("2205", "Event05");
    AddEvent("2206", "Event06");
    AddEvent("2207", "Event07");
    AddEvent("2208", "Event08");
    AddEvent("2209", "Event09");

    AddEvent("220A", "Event10");
    AddEvent("220B", "Event11");
    AddEvent("220C", "Event12");
    AddEvent("220D", "Event13");
    AddEvent("220E", "Event14");
    AddEvent("220F", "Event15");
    AddEvent("2210", "Event16");
    AddEvent("2211", "Event17");
    AddEvent("2212", "Event18");
    AddEvent("2213", "Event19");
    AddEvent("7FF0", "DebugOutput");
  }

  boolean checkIfNewMessage(EnlightMessage newMessage)
  {
    //if the outbox is empty, return true;
    if (outbox.size() == 0) return true;

    else
    {
      for (int i = 0; i<outbox.size (); i++)
      {
        EnlightMessage oldMessage = outbox.get(i);

        //if it is the same luminaire
        if ( oldMessage.getRecipient().equals( newMessage.getRecipient() ) && oldMessage.getFrom().equals( newMessage.getFrom() ) )
        {
          //replace message with same event to the same level of the same luminaire with the new one..
          if (oldMessage.getEvent().equals(newMessage.getEvent()) )
          {
            newMessage.setPriority(-1);      //set the lowest priority
            outbox.set(i, newMessage);       //add it to the outbox
            return false;
          }

          EnlightMessage m = new EnlightMessage(this);
          m.setFrom(ADDRESS_PC);
          m.setRecipient(newMessage.getRecipient());
          m.setEvent("Event01");

          //if it is ct, have a look if the same lamp has a message for dimlevel (and the other way around)
          if (newMessage.getEvent().equals("ColorChangedCCT") && oldMessage.getEvent().equals("DimLevelChanged"))
          {

            m.setArgs( concat(newMessage.getArgs(), oldMessage.getArgs()) );
            m.setBody();
            outbox.set(i, m);       //add it to the outbox
            return false;
          } else if (newMessage.getEvent().equals("DimLevelChanged") && oldMessage.getEvent().equals("ColorChangedCCT"))
          {
            m.setArgs( concat(oldMessage.getArgs(), newMessage.getArgs()) );
            m.setBody();
            outbox.set(i, m);       //add it to the outbox
            return false;
          }
        }
      }
    }
    return true;
  }

  void addMessageToOutbox(EnlightMessage message)
  {
    if (checkIfNewMessage(message)) outbox.add(message);
    //try
    //{
    Collections.sort(outbox);      //sort the outbox by priority;
    //}
    //catch (Exception e)
    //{
    //}
  }




  ////CREATE THE MESSAGE//////////////////////////////////////////////////
  //maybe change function to createMessage();

  //broadcast without any arguments
  void createMessage(String event, String sender)
  {
    createMessage(event, sender, "broadcast", null);
  }

  //unicast without any arguments
  void createMessage(String event, String sender, String receiver)
  {
    createMessage(event, sender, receiver, null);
  }

  //broadcast with arguments
  void createMessage(String event, String sender, int... args)
  {
    createMessage(event, sender, "broadcast", args);
  }

  //unicast with arguments
  void createMessage(String event, String sender, String receiver, int... args)
  {
    //if (!getLuminaireByAddress(receiver).getAnnounced()) requestToAnnounce(getLuminaireByAddress(receiver));
    EnlightMessage m = new EnlightMessage(this);
    m.setFrom(sender);
    m.setRecipient(receiver);

    m.setEvent(event);
    if (event.equals("ColorChangedCCT") && args.length>1) m.setEvent("Event02");
    if (event.equals("DimLevelChanged") && args.length>1) m.setEvent("Event03");

    m.setArgs(args);
    m.setBody();
    //set message priority///
    addMessageToOutbox(m);

    //println(m.body);
  }
}

//is het wel presence detected? is het niet announce?
String[][] commands = { 
  {
    "81", "announce"
  }
  , { 
    "80", "presenceDetected"
  }
};

void serialEvent(Serial p)
{
  String message = null;

  try 
  {
    // get message till line break (ASCII > 13)
    message = cleanMessage(p.readStringUntil(13));
  }
  catch (Exception e)
  {
    String error = e.toString(); 
    if (!error.equals("java.lang.NullPointerException")) println("Enlight read error. " + e);
  }

  if (message != null)
  {
    if (p == ENLIGHT.serial)
    {
      ENLIGHT.processIncommingMessage(message);
    } else if (p == ENLIGHT2.serial)
    {
      ENLIGHT2.processIncommingMessage(message);
    }
  }
}

public String cleanMessage(String message)
{
  message = message.replace("\n", " "); 
  message = message.replace("\r", " "); 
  message = message.replace("\b", " "); 
  return message;
}

