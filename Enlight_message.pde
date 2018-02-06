import java.util.Arrays; 
import java.util.Comparator; 
import java.util.Collections;

class EnlightMessage implements Comparable<EnlightMessage>
{
  private String body;
  public String from;
  public String recipient;
  private boolean confirmation = true;
  private long sendTime;
  private String event = "";
  private int[] args;
  int fail = 0;
  int priority = 0;
  private boolean broadcast = false;
  Enlight parentEnlight = ENLIGHT;
  
  public EnlightMessage()
  {
    sendTime = millis();
  }
  
  public EnlightMessage(Enlight e)
  {
    parentEnlight = e;
    sendTime = millis();
  }
  
  public EnlightMessage(String m)
  {
    body = m;
    sendTime = millis();
  }
  
  public EnlightMessage(String m, Enlight e)
  {
    parentEnlight = e;
    body = m;
    sendTime = millis();
  }
  
  public void setFrom(String value)
  {
    from = value;
  }
  
  public String getFrom()
  {
    return from;
  }
  
  public void setEvent(String value)
  {
    event = value;
  }
  
  public String getEvent()
  {
    return event;
  }
  
  public String getEventName()
  {
    String eventName = event;
    if (event.equals("Event01")) eventName = "CT + dimLevel";
    if (event.equals("Event02")) eventName = "CT + fadeTime";
    if (event.equals("Event03")) eventName = "dimLevel + fadeTime";
    return eventName;
  }
  
  public void setRecipient(String value)
  {
    recipient = value;
  }
  
  public String getRecipient()
  {
    return recipient;
  }
  
  public void setConfirmation(boolean b)
  {
    confirmation = b;
  }
  
  public boolean confirmationRequired()
  {
    return confirmation;
  }
  
  public String getBody()
  {
    return body;
  }
  
  public long getSendTime()
  {
    return sendTime;
  }
  
  public void setArgs(int... args)
  {
    this.args = args;
  }
  
  public int[] getArgs()
  {
    return args;
  }
  
  public String getArgValues()
  {
    String argValues = ""+args[0];
    for (int i = 1; i<args.length;i++) argValues += ","+args[i];
    return argValues;
  }
  
  public void setBody()
  {
    String message = "raw 0xfc30 {01 00 80 ";
    
    String rawSender = from;
    String rawRecipient = recipient;
    
    if (from.indexOf(":") != -1) rawSender = join(split(from, ':'),"");
     if(recipient.indexOf(":") != -1) rawRecipient = join(split(recipient, ':'),"");
    if (rawRecipient.equals("broadcast")) message += "0000000000000000";
    
    else message += rawRecipient;
    
    message += rawSender;
    
    //set function      
    for (int i = 0; i<parentEnlight.events.length; i++)
    {
      if ( event.toUpperCase().equals( parentEnlight.eventTypes[i].toUpperCase() ) )
      {
        message += parentEnlight.events[i];
        i = parentEnlight.events.length;  //break from the loop
      }
    }
    
    //set args
    if (args != null)
    {
      if (args.length < 10) message += "0";
      message += str(args.length);
      
      for (int i = 0; i< args.length; i++)
      {
        message += "06";  //argument type? UINT16?
        message += hex(args[i]);
      }
    }
    else
    {
      message += "00";
    }
    
    message += "}\r\nsend ";
    if (rawRecipient.equals("broadcast")) message += "0xFFFD";
    else message += getLuminaireByAddress(recipient).getShortAddress();
    message += " 1 1\r\n";
    
    body = message;
  }
  
  public void setPriority(int i)
  {
    priority = i;
  }
  
  @Override
    public int compareTo(EnlightMessage another) {
        // price fields should be Float instead of float
        String a = "" + this.priority;
        String b = "" + another.priority;
        return b.compareTo(a);
    }
}
