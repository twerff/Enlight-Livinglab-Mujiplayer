//scopes
int NROFSCOPES = 7;
public static final int STUDIO   = 0;
public static final int MEETING1 = 1;
public static final int MEETING2 = 2;
public static final int MEETING3 = 3;
public static final int OFFICE   = 4;
public static final int FLEX     = 5;
public static final int CORRIDOR = 6;

public String getScopeName(int value)
{
  if (value == 0) return "STUDIO";
  if (value >=1 && value <= 3) return "MEETING"+value;
  if (value == 4) return "OFFICE";
  if (value == 5) return "FLEX";
  if (value == 6) return "CORRIDOR";
  
  return "NO_SCOPE";
}


ArrayList<Scope> _scopes = new ArrayList<Scope>();

void setupScopes()
{
  for (int i = 0; i<NROFSCOPES; i++) _scopes.add(new Scope(i));
}


public void setGlobalPresence(int scope)
{
  getScope(scope).setPresence(true);
}

public boolean getGlobalPresence(int scope)
{
  return getScope(scope).getPresence();
}


public Scope getScope(int i)
{
  return _scopes.get(i);
}

public Scope getScope(Luminaire l)
{
  return _scopes.get(l.getScope());
}

class Scope
{
  //ArrayList<Luminaire> _scopeLuminaires = new ArrayList<Luminaire>();
  int scope;
  boolean reactToPresence = false;
  ArrayList<Integer> _lastDimLevels = new ArrayList<Integer>();
  
  public Scope(int i)
  {
    scope = i;
  }
  
  private boolean presenceDetected = false;
  private int presenceTimeOut = 30 * 60 * 1000;
  private long presenceDetectedTime = -presenceTimeOut;
  
  public void draw()
  {
    if (getPresence() && millis() > presenceDetectedTime + presenceTimeOut)  setPresence(false);
    
    fill(150);
    String text = getScopeName(scope);
    
    if (presenceDetected) 
    {
      fill(0);
      text += " (" + ((presenceTimeOut-(millis()-presenceDetectedTime))/1000) +"s )";
    }
    text(text, consoleX, height - 100 + (15*scope));
  }
  
  public void setPresence(boolean present)
  {
    if (present) presenceDetectedTime = millis();
    
    if (scope == FLEX)
    {
      if (!present && getPresence()) 
      {
        traceln("FLEX go absence!");
        _lastDimLevels.clear();
        
        for (Luminaire l : _luminaires(scope)) 
        {
          println("set " + l.getName() + " off");
          _lastDimLevels.add(l.getDimLevel());
          l.setDimLevel(25000);
        }
      }
      else if (present && !getPresence()) 
      {
        traceln("FLEX go presence!");
        
        for (int i = 0; i<_luminaires(scope).size(); i++) 
        {
          Luminaire l = _luminaires(scope).get(i);
          try
          {
            l.setDimLevel(_lastDimLevels.get(i));
          }
          catch(Exception e)
          {
            l.setDimLevel(45000);
          }
        }
      }
    }
    
    presenceDetected = present;
  }
  
  public boolean getPresence()
  {
    return presenceDetected;
  }
}
