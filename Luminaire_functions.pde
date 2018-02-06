ArrayList<Luminaire> _luminaires;

ArrayList<Luminaire> _luminaires(int scope)
{
  ArrayList<Luminaire> lums = new ArrayList<Luminaire>();
  
  for (Luminaire l : _luminaires)
  {
    if (l.getScope() == scope) lums.add(l);
  }
  
  return lums;
}

void setupLuminaires()
{
  _luminaires = new ArrayList<Luminaire>();
  setupScopes();
  
  //MUST USE SMALL CAPS FOR ADDRESS
  int row = 13;
  addPB("00:15:8d:00:00:35:ce:66", "be70", row, 2);
  addPB("00:15:8d:00:00:35:d2:c7", "cda7", row, 6);
  addPB("00:15:8d:00:00:35:ce:89", "3fd0", row, 10);
  
  row = 16;
  addPB("00:15:8d:00:00:35:ce:a3", "5442", row, 2);
  //addPB("00:15:8d:00:00:35:cf:17", "9114", row, 6); KAPOT
  addPB("00:15:8d:00:00:35:ce:94", "add1", row, 6);
  addPB("00:15:8d:00:00:35:ce:7d", "af37", row, 10);
  
  row = 19;
  addPB("00:15:8d:00:00:35:d2:2a", "502f", row, 2);
  addPB("00:15:8d:00:00:35:ce:98", "1769", row, 6);
  addPB("00:15:8d:00:00:35:d2:e8", "0e58", row, 10);
  addPB("00:15:8d:00:00:35:ce:51", "7a30", row, 14);
  
  row = 22;
  addPB("00:15:8d:00:00:35:d2:5f", "2a61", row, 2);
  addPB("00:15:8d:00:00:35:d3:1c", "a507", row, 6);
  addPB("00:15:8d:00:00:35:d3:31", "109e", row, 10);
  addPB("00:15:8d:00:00:35:d2:c9", "3f29", row, 14);
  
  row = 25;  
  addPB("00:15:8d:00:00:35:ce:8c", "b28a", row, 2);
  addPB("00:15:8d:00:00:35:ce:a1", "b2eb", row, 6);
  addPB("00:15:8d:00:00:35:d2:59", "a083", row, 10);
  addPB("00:15:8d:00:00:35:cf:45", "89ab", row, 14);
  
  row=28;
  addPB("00:15:8d:00:00:35:d3:b3", "4ebf", row, 2);
  addPB("00:15:8d:00:00:35:ce:79", "c0d7", row, 6);
  addPB("00:15:8d:00:00:35:d2:10", "c940", row, 10);
  thisLuminaire().setName("Exit 1");
  addPB("00:15:8d:00:00:35:d2:89", "9ba4", row, 14); //"d289"
  thisLuminaire().setName("Exit 2");
  
  //meetingrooms
  //addPB("00:15:8d:00:00:35:ce:94", "add1", 15.5, 18, MEETING1); NAAR 6 gegaan
  addPB("00:15:8d:00:00:35:d3:08", "", 15.5, 18, MEETING1);
  addPB("00:15:8d:00:00:35:d3:a6", "", 15.5, 23, MEETING2);
  //addLuminaire("00:15:8d:00:00:35: : ", 15.5, 21.5, MEETING2, true);
  //addLuminaire("00:15:8d:00:00:35: : ", 7,    16.5, MEETING3);
  
  //office
  addPB      ("00:15:8d:00:00:35:d2:6b", "2cba", 8.5, 4, OFFICE);
  thisLuminaire().setName("PB Harm");
  addPB      ("00:15:8d:00:00:35:d3:61", "bd8a", 8.5, 8, OFFICE);
  thisLuminaire().setName("PB Saskia");
  addTaskFlex("00:15:8d:00:00:35:d3:16", "8835", 8, 4.5, OFFICE);
  thisLuminaire().setName("TX Harm");
 //addTaskFlex("00:15:8d:00:00:35:d2:08", 8,   9.5, OFFICE);
  //thisLuminaire().setName("TX Saskia");

  //flex
  addPB("00:15:8d:00:00:35:d3:58", "982d", 21, 17.5, FLEX);
  thisLuminaire().setDwars();
  addPB("00:15:8d:00:00:35:ce:76", "9364", 25, 17.5, FLEX);
  thisLuminaire().setDwars();
  addPB("00:15:8d:00:00:35:d3:64", "a820", 21, 25.5, FLEX);
  thisLuminaire().setDwars();
  addPB("00:15:8d:00:00:35:d3:b4", "42b2", 25, 25.5, FLEX);
  thisLuminaire().setDwars();
  //addLuminaire("00:15:8d:00:00:35:", 27.5, 23.5, FLEX, true);
  
  
  //corridor
  //addMPB("00:15:8d:00:00:35:d2:bd", 5,  12);
  addMPB("00:15:8d:00:00:35:d2:e7", "3f8e", 8,  12);
  addMPB("00:15:8d:00:00:35:ce:86", "d9d4", 11, 12);
  addMPB("00:15:8d:00:00:35:d2:85", "2292", 12, 15);
  addMPB("00:15:8d:00:00:35:ce:78", "d85b", 12, 18);
  addMPB("00:15:8d:00:00:35:d2:0a", "06c0", 12, 21);
  addMPB("00:15:8d:00:00:35:d3:38", "cdbc", 12, 24);
  addMPB("00:15:8d:00:00:35:d3:bf", "bf64", 12, 27);
  addMPB("00:15:8d:00:00:35:ce:8f", "5992", 15, 27);
  addMPB("00:15:8d:00:00:35:ce:77", "8360", 18, 27);

  
  //SETUP THE NEIGHBOURS
  //for(int i = 0; i < getNumberOfLuminaires(); i++)
  //{
    //getLuminaire(i).setNeighbours(7*TILE);//int = size of radius around it that should be added to the neighbours
  //}

}

//public Luminaire pb()
//{
//  return _luminaires.get(0);
//}

void addMPB(String _64Bit, float x, float y)
{
  addMPB(_64Bit, x, y, CORRIDOR);
}

void addMPB(String _64Bit, float x, float y, int scope)
{
  Luminaire l = new mPB(_64Bit,x,y);
  l.setScope(scope);
  l.setName(getScopeName(scope) + " " + int(x) + "," + int(y));
  _luminaires.add(l);
}

void addMPB(String _64Bit, String _16Bit, float x, float y)
{
  addMPB(_64Bit, x, y);
  thisLuminaire().setShortAddress("0x"+_16Bit);
}



void addTaskFlex(String _64Bit, String _16Bit, float x, float y, int scope)
{
  Luminaire l = new Taskflex(_64Bit,x,y);
  l.setScope(scope);
  l.setShortAddress(_16Bit);
  _luminaires.add(l);
  
  //getScope(scope).addLuminaire(l);
}

void addPB(String _64Bit, float x, float y)
{
  addPB(_64Bit, x, y, 0);
}

void addPB(String _64Bit, float x, float y, boolean dwars)
{
  addPB(_64Bit,x,y,0);
  if(dwars) thisLuminaire().setDwars();
}

void addPB(String _64Bit, String _16Bit, float x, float y)
{
  addPB(_64Bit,_16Bit,x,y,0);
}

void addPB(String _64Bit, String _16Bit, float x, float y, int scope)
{
  addPB(_64Bit,x,y,scope);
  thisLuminaire().setShortAddress("0x"+_16Bit);
}


void addPB(String _64Bit, float x, float y, int scope)
{
  Luminaire l = new PB(_64Bit,x,y);
  l.setScope(scope);
  l.setName(getScopeName(scope) + " " + int(x) + "," + int(y));
  _luminaires.add(l);
}

Luminaire thisLuminaire()
{
  return getLuminaire(getNumberOfLuminaires()-1);
}

public Luminaire getLuminaireByAddress(String value)
{
  //remove the :
  value = join(split(value, ':'),"");  
  value = value.toLowerCase();
  
  for (Luminaire l : _luminaires)
  {
    String address = join(split(l.getAddress(), ':'),"").toLowerCase();
    if (address.equals(value) ) return l;
  }
  traceln("luminaire " + value + " not found..");
  return null;
}

public Luminaire getLuminaireByShortAddress(String value)
{
  //add the 0x if not already in there.
  if ( !value.contains("0x") ) value = "0x"+value;
  value = value.toLowerCase();
  
  for (Luminaire l : _luminaires)
  {
    String address = l.getShortAddress().toLowerCase();
    if ( !address.contains("0x") ) address = "0x"+address;
    if (address.equals(value) ) return l;
  }
  traceln("luminaire " + value + " not found..");
  return null;
}

public Luminaire randomLuminaire()
{
  int random = int( random(_luminaires.size()-1) );
  traceln("random luminaire "+_luminaires.get(random).getShortAddress());
  
  return _luminaires.get(random);
}

public Luminaire randomLuminaire(int scope)
{
  int random = int( random(_luminaires(scope).size()-1) );
  traceln("random luminaire "+_luminaires(scope).get(random).getShortAddress());
  
  return _luminaires.get(random);
}
