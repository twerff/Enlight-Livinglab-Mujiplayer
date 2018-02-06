import com.temboo.core.*;
import com.temboo.Library.Google.Gmail.*;
import javax.swing.*; 

//GOOGLE FORMS
String surveyFloorplan = "https://docs.google.com/forms/d/e/1FAIpQLSfPKTm0wckDRT-dEwsizG7ZMDtKSiEoFdcSTqyuOwBwbHEU1Q/viewform"; //?entry.1538791964=7940

// Create a session using your Temboo account application details


TembooSession session = new TembooSession("ili", "myFirstApp", "L1z5V38x0c8iXdJk6opBxeNun9ChQ0CS");

boolean noMailSendToday = true;

MULI muli = null;
boolean MULIenabled = false;

void setupMULI()
{
  muli = new MULI();
  MULIenabled = true;
  
  setupParticipants();
}

class MULI
{
  public MULI()
  {
  }
  
  public void draw()
  {
     //monitor("Floor Plan apps: " + getConnectedClients());
    //showMonitor();

    //FLOORPLAN EMAIL
    //send an email at 12:00 & 16:00 (and at 15:00 on friday)
//    if (hour() == 12 && getDate2().getDay()<4 && noMailSendToday) sendEmails();
//    if (hour() == 13 && !noMailSendToday) noMailSendToday = true;
//    
//    if (hour() == 16 && getDate2().getDay()<4 && noMailSendToday) sendEmails();
//    if (hour() == 17 && !noMailSendToday) noMailSendToday = true;
//    
//    else if (hour() == 15 && noMailSendToday && getDate2().getDay()==5) sendEmails();

    //POINTER EMAIL
//    if ((hour() == 17 && getDate2().getDay()<4 && noMailSendToday))
//    {
//      for (int i = 0; i<_notEmailedParticipants().size(); i++)
//      {
//        Participant p = _notEmailedParticipants().get(i);
//        
//        int x = 0;
//        int y = 0;
//        
//        fill(100);
//        rect(200, i*20, 50, 15);
//        fill(0);
//        text(p.getID(), 200, i*20);
//      }
//    }
  }
}

public ArrayList<Participant> _notEmailedParticipants()
{
  ArrayList<Participant> participants = new ArrayList<Participant>();
  
  for (Participant p : _uniqueParticipants())
  {
    if (getDifference(getDate2(), p.getLastSendEmail().getDate(), DAYS) > getDate2().getDay()) participants.add(p);
  }
  
  return participants;
}

public ArrayList<Participant> _uniqueParticipants()
{
  ArrayList<Participant> participants = new ArrayList<Participant>();
  
  for (int i = 0; i<_participants.size(); i++)
  {
    Participant p = _participants.get(i);
    boolean unique = true;
    
    //if participant is not 0
    if (p.getID() != 0)
    {
      for (int j = i+1; j<_participants.size(); j++)
      {
        Participant pp = _participants.get(j);
        if (pp.getID() == p.getID()) unique = false; 
      }
      
      if (unique) participants.add(p);
    }
  }
  
  return participants;
}


public void sendEmails()
{
  /*
  traceln("checking actions to see who to send an email");
  int nrOfEmail = 0;
  
  //if it is monday - friday
  if (getDate2().getDay() <= 5)
  {
    //check each participant
    for (Participant p : _participants)
    {
      //if participant is not 0
      if (p.getID() != 0)
      {
        long daysSinceLastEmail = 8;
        if (p.getLastSendEmail().getSubject().equals("Please fill in this survey"))
        {
          daysSinceLastEmail = getDifference(getDate2(), p.getLastSendEmail().getDate(), DAYS);
        }
        
        //check if there is another participant with the same ID
        for (Participant pp : _participants)
        {
          if (pp != p && pp.getID() == p.getID())
          {
            //if this one received an email later, then update the daysSinceLastEmail            
            if (pp.getLastSendEmail().getSubject().equals("Please fill in this survey"))
            {
              if (getDifference(getDate2(), pp.getLastSendEmail().getDate(), DAYS) < daysSinceLastEmail)
              {
                daysSinceLastEmail = getDifference(getDate2(), pp.getLastSendEmail().getDate(), DAYS);
              }
            }
          }
        }
        
        //if the participant did nog get an email yet this week
        if (daysSinceLastEmail > getDate2().getDay())
        {
          traceln("participant " + p.getID() + " received an email " + daysSinceLastEmail + " days ago");
          
          boolean interactedToday = getDate2().getDay() != 5 && getDifference(getDate2(), p.getLastAction(), DAYS) == 0;
          boolean friday = getDate2().getDay() == 5;
          
          if (interactedToday || friday)
          {
            nrOfEmail++;
            traceln("sending an email.");
            
            Email e = new Email();
            e.setRecipient( p );
            e.sendSurvey(surveyFloorplan);
          }
        }
      }
    }
  }

  traceln("Sent " + nrOfEmail + " emails today");  
//  XML xml = loadXML("/data/emails.xml").getChildren("emails")[0];
//  XML mail = xml.addChild("mail");
//  mail.setString("date", getDate());
//  mail.setInt("mails", nrOfEmail);
//  saveXML(xml, "/data/emails.xml");

  noMailSendToday = false;
  */
}
 
class Email
{
  Participant recipient;
  String subject;
  String body;
  Date date;

  public Email()
  {
    setDate(getDate2());
  }
  
  public void setRecipient(Participant p)
  {
    recipient = p;
  }
  public void setRecipient(String value)
  {
    setRecipient(getParticipantByEmailAddress(value));
  }

  public void setSubject(String value)
  {
    subject = value;
  }

  public void setBody(String value)
  {
    body = value;
  }

  public Participant getRecipient()
  {
    return recipient;
  }

  public String getSubject()
  {
    return subject;
  }

  public String getBody()
  {
    return body;
  }

  public void sendSurvey(String URL)
  {
    setSubject("Please fill in this survey");
    setBody("");
    
    String email[] = loadStrings("/data/sampling_template.txt");
    for (int i = 0; i<email.length; i++)
    {
      String url = URL + "?entry.1538791964=" + recipient.getID();
      email[i] = email[i].replaceAll("#URL#", url);

      body+= email[i] + "\n";
    }
    
    sendEmail(this);
  }
  
  public void sendWelcome()
  {
    setSubject("Thank you for participating!");
    setBody("");
    
    String email[] = loadStrings("/data/welcome_template.txt");
    
    for (String line : email)
    {
      String ID = Integer.toString(recipient.getID());
      line = line.replaceAll("#ID#", ID);
      body += line + "\n";
    }
    
    sendEmail(this);
  }
  
  public Date getDate()
  {
    return date;
  }
  
  public void setDate(Date d)
  {
    date = d;
  }
}

void sendEmail(Email mail)
{
  // Create the Choreo object using your Temboo session
  SendEmail sendEmailChoreo = new SendEmail(session);
  
  // Set inputs
  sendEmailChoreo.setUsername("intelligentlightinginstitute@gmail.com");
  sendEmailChoreo.setPassword("sbplkjgmhswoslhg");

  sendEmailChoreo.setToAddress(mail.getRecipient().getAddress());
  sendEmailChoreo.setBCC("intelligentlightinginstitute@gmail.com");
  sendEmailChoreo.setSubject(mail.getSubject());
  sendEmailChoreo.setMessageBody(mail.getBody());

  // Run the Choreo and store the results
  SendEmailResultSet sendEmailResults = sendEmailChoreo.run();
  try
  {
    // Print results
    if (sendEmailResults.getSuccess().equals("true"))
    {
      mail.getRecipient().sendMail(mail);
      traceln("email sent to " + mail.getRecipient().getAddress() + ", \"" + mail.getSubject() + "\"");
    }
  }
  catch (Exception e)
  {
    traceln("email error");
  }
}
