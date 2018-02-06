String filePath = "data/log.csv";
Table table;

int dag;
int interactionID = parseInt(year() + "" + month() + "" + day() + "" + "000");



void setupLogger()
{
  setFilePath();
  
  try
  {
    table = loadTable(filePath, "header");
    interactionID = table.getRow(table.getRowCount()-1).getInt("Interaction ID");
    
    traceln("Log file loaded");
  }
  catch(Exception e)
  {
    createNewLog();
  }
  
  log("Server", "", "", "initialized");
}

void setFilePath()
{
  filePath = "data/log " + year();
  if(month() < 10) filePath += "0";
  filePath += month();
  if(day() < 10) filePath += "0";
  filePath += day() + ".csv";
  dag = day();
}

void createNewLog()
{ 
  table = new Table();
  table.addColumn("date");              //DDMMYYYY
  table.addColumn("time");              //HHMMSS
  table.addColumn("event");             //?
  table.addColumn("sender");            //IP
  table.addColumn("recipient");         //Server
  table.addColumn("function");          //newPolygon
  
  table.addColumn("ID");                //##
  table.addColumn("duration");          //ms? kan ik deze makkelijk van de tijd afhalen? moet ik hier een begintijd van maken?
  table.addColumn("activity");          //#
  table.addColumn("CT");                //
  table.addColumn("DimLevel");          //
  table.addColumn("Number of Areas");   //#
  table.addColumn("Area1");
  table.addColumn("Area2");
  table.addColumn("Area3");
  table.addColumn("Area4");
  table.addColumn("Interaction ID");    //...how????
  
  traceln("New logfile created");
}

void checkDate()
{
  if (dag != day())
  {
    setFilePath();
    createNewLog();
  }
}

class MULIaction
{
  private Date date;
  int duration;

  private String function;
  String IP;
  int ID = 99999;
  String deviceType;
  
  int act = -1;
  int[] areas;
  int ct = -1;
  int dim = -1;
  
  public MULIaction()
  {
    init(true);
  }
  
  public MULIaction(String f)
  {
    function = f;
    init(true);
  }
  
  public MULIaction(boolean sound)
  {
    init(sound);
  }
  
  private void init(boolean sound)
  {
    date = getDate2();
    
    if (sound)
    {
    //PLAY A SOUND
    //if (millis() - lastSound > soundInterval)
    //{
      lastSound = millis();
      pop.rewind();
    //}
    
      pop.play();
    }
  }
  
  void getParticipantInfoByIP(String ip)
  {
    IP = ip;
    ID = 999;
    
    if (IP.length() < 2)
    {
      ID = int(IP);
      IP = TABLETIP;
    }
    else if (getParticipantByIP(IP)!=null)   ID = getParticipantByIP(IP).getID();
  }
  
  private int interactionID()
  {
    //update the interaction ID if not the same sender, id and too long beteen interactions
    int secondsBeforeNewID = 6;
    
    TableRow prevRow = null;
    
    if (table.getRowCount() > 0) prevRow = table.getRow(table.getRowCount()-1);
    else return interactionID++;
    
    if (IP.equals(prevRow.getString("sender")) && ID == prevRow.getInt("ID"))
    {
      Date startDateOfAction = new Date(date.getTime() - duration);
      
      if (getDifference(startDateOfAction,  getParticipantByIP(IP).getLastAction(), SECONDS) > secondsBeforeNewID)
      {
        interactionID++;
        pop.rewind();
      }
    }
    else
    {
      interactionID++;
      pop.rewind();
    }
    
    return interactionID;
  }
  
  public Date getDate()
  {
    return date;
  }
  
  public void setFunction(String f)
  {
    function = f;
  }
  
  public String getFunction()
  {
    return function;
  }
  
  public void finish()
  {    
    checkDate();
    
    int iid = 0;
    //create a new entry
    TableRow newRow = table.addRow();
    //newRow.setInt("Interaction ID", iid);
    newRow.setString("date", new SimpleDateFormat("dd/MM/yy").format(date));
    newRow.setString("time", new SimpleDateFormat("HH:mm:ss").format(date));
    newRow.setString("event", "MULI Pointer");
    newRow.setString("sender", IP);
    newRow.setString("recipient", "Server");
    newRow.setString("function", function);
    //newRow.setInt("ID", ID);
    if (duration > 0) newRow.setInt("duration", duration);
    
    if (act >= 0) newRow.setInt("activity", act);
    if (ct >= 0)  newRow.setInt("CT", ct);
    if (dim >= 0) newRow.setInt("DimLevel", dim);
    
    newRow.setInt("Number of Areas", areas.length);
    for (int i = 0; i< areas.length; i++) newRow.setInt("Area"+(i+1), areas[i]);
    
    saveTable(table, filePath);
    
    println("saved: pointer " + IP + " indicator: " + areas[0]);
  }
}

void log(String event)//, String parent, String address, String event, int... values)
{
  //log (event, "", "", "", null);
}

void log(String event, String from, String to, String function)
{
  //log (event, from, to, function, null);
}

void log(String event, String from, String to, String function, int... values)
{
  checkDate();
  
  if (function != null)
  {
    function = function.replaceAll("\r","");
    function = function.replaceAll("\b","");
    function = function.replaceAll("\n","");
  }
  
  from = from.toLowerCase().replaceAll(" ", ":");
  to   = to.toLowerCase().replaceAll(" ", ":");
  
  TableRow newRow = table.addRow();
  newRow.setString("time", getTime());
  newRow.setString("event", event);
  newRow.setString("sender", from);
  newRow.setString("recipient", to);
  newRow.setString("function", function);
  
  print("LOG: " + getTime() + ", " + event + ", " + from + ", " + to + ", " + function + ", ");
  
  if (values != null)
  {
    for (int i = 0; i<values.length; i++)
    {
      newRow.setInt("value"+i, values[i]);
      print(values[i] + ", ");
    }
  }
  
  println();
  
  saveTable(table, filePath);
}
