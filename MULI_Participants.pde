ArrayList<Participant> _participants;
XML participants;

void setupParticipants()
{
  _participants = new ArrayList<Participant>();
  loadParticipants();
  
  //send a welcome email if this is not done yet  
  for (Participant p : _participants)
  {
    boolean notWelcomed = true;
    for (Email e : p._emails)
    {
      if (e.getSubject().equals("Thank you for participating!")) notWelcomed = false;
    }
    
    if (notWelcomed)
    {
       Email e = new Email();
       e.setRecipient( p );
       e.sendWelcome();
    }
    
  }
}

void loadParticipants()
{
  try
  {
    participants = loadXML("/data/participants.xml");
    traceln("participants loaded");
  }
  catch (Exception e)
  {
    println("participant XML file not found! Creating a new one..");
    participants = parseXML("<participants><participant></participant></participants>");
    
    //if it did not work out, make a new XML
    addParticipant(0, "192.168.1.95", "twerff@gmail.com");
    addParticipant(0, "192.168.1.62", "TABLET");
  }
  
  for (XML participant: participants.getChildren("participant"))
  {
    int ID = participant.getInt("ID");
    String IP = participant.getString("IP");
    String email = participant.getString("email");
    
    Participant p = new Participant(ID, IP, email);
    
    //for (XML mail : participant.getChildren("email"))
//    {
//      Email e = new Email();
//      
//      Date date = new Date();
//      try { 
//        date = new SimpleDateFormat("dd-MM-yy HH:mm:ss").parse(mail.getString("date"));
//      } 
//      catch (Exception ex) { };
//      e.setDate( date );
//      e.setSubject(mail.getString("subject"));
//      
//      p.addMail(e);
    //}

    _participants.add(p);
  }
  
  traceln("loaded " + _participants.size() + " participants");
}

void addParticipant(int ID, String IP, String email)
{
  Participant p = new Participant(ID, IP, email);
  _participants.add(p);
  
  XML xml = participants.addChild("participant");
  xml.setInt("ID", p.getID());
  xml.setString("IP", p.getIP());
  xml.setString("email", p.getEmailAddress());
  updateParticipantXML();
    //send a welcome email
    //Email e = new Email();
    //e.setRecipient(p);
    //e.sendWelcome();
}

class Participant
{
  int ID;
  String IP, EMAILADDRESS;
  public ArrayList<Email> _emails = new ArrayList<Email>();
  XML xml;
  
  public Participant()
  {
  }
  
  public Participant(int id, String ip, String emailaddress)
  {
    ID = id;
    IP = ip;
    EMAILADDRESS = emailaddress;
    
    for (XML participant: participants.getChildren("participant"))
    {
      if (id == participant.getInt("ID")) 
      {
        xml = participant;
        
        for (XML mail : participant.getChildren("email"))
        {
          Email email = new Email();
          email.setSubject(mail.getString("subject"));
          
          Date newDate = new Date();
          try
          {
            newDate = new SimpleDateFormat("dd-MM-yy HH:mm:ss").parse(mail.getString("date"));
            email.setDate(newDate);
          } 
          catch (Exception e){};
          
          _emails.add(email);
        }
        break;
      }
    }
  }
  
  public int getID()
  {
    return ID;
  }
  
  public String getIP()
  {
    return IP;
  }
  
  public String getEmailAddress()
  {
    return EMAILADDRESS;
  }
  
  public String getAddress()
  {
    return EMAILADDRESS;
  }
  
  public Email getLastSendEmail()
  {
    if (_emails.size() > 0) return _emails.get(_emails.size()-1);
 
    traceln("no emails sent to participant " + ID);
    return null;
  }
  
  public void addMail(Email e)
  {
    _emails.add(e);
  }
  
  public void sendMail(Email e)
  {
    addMail(e);
    
    //save it to the XML
    XML mail = xml.addChild("email");
    mail.setString("subject", e.getSubject());
    mail.setString("date", new SimpleDateFormat("dd-MM-YY HH:mm:ss").format( e.getDate() ) );
    updateParticipantXML();
  }
  
  public void addAction(MULIaction a)
  {
    //save it to the XML
    XML action = xml.addChild("action");
    action.setString("function", a.getFunction());
    action.setString("date", new SimpleDateFormat("dd-MM-YY HH:mm:ss").format( a.getDate() ) );
    updateParticipantXML();
  }
  
  public Date getLastAction()
  {
    Date lastAction = new Date();
    try
    {
      lastAction = new SimpleDateFormat("dd-MM-yy HH:mm:ss").parse(xml.getChildren("action")[xml.getChildren("action").length-1].getString("date"));
      return lastAction;
    } 
    catch (Exception e){};
    
    traceln("no last action found for participant " + ID);
    return null;
  }
}

public void updateParticipantXML()
{
  saveXML(participants, "/data/participants.xml");
}

//GETTERS
public Participant getParticipantByIP(String ip)
{
  for (Participant p : _participants)
  {
    if (p.getIP().equals(ip) ) return p;
  }
  //addParticipant(666, ip, "");
  //OscMessage message = new OscMessage("/server/setup");
  //oscP5.send(message, ip, OSCPORT);
  
  traceln("participant with IP " + ip + " not found");
  return null;
}

public Participant getParticipantByID(int id)
{
  for (Participant p : _participants)
  {
    if (p.getID() == id) return p;
  }
  
  traceln("participant with ID " + id + " not found");
  return null;
}

public Participant getParticipantByEmailAddress(String email)
{
  email = email.toLowerCase();
  
  for (Participant p : _participants)
  {
    if (p.getEmailAddress().toLowerCase().equals(email) ) return p;
  }
  
  traceln("participant with email address " + email + " not found");
  return null;
}

//public int newParticipantID()
//{
//  int i = 0;
//  
//  for (Participant p : _participants)
//  {
//    if (p.getID() > i) i = p.getID()+1;
//  }
//  
//  return i;
//}
