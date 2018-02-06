public class Luminaire extends Item
{
  public long lastUpdate;
  public long randomUpdate;
  
  private String address      = "";
  private String shortAddress = "";
  private boolean dwars       = false;
  private int scope           = STUDIO;
  private String localAddress = "";
  private int luminaireID = 0;
  
  private int dimLevel      = 35000;
  private int maxDimLevel   = 65535;
  private int minDimLevel   = 0;
  private boolean on = true;
  
  private boolean ctEnabled = true;
  private int ct            = 4000;
  private int minCT         = 1500;
  private int maxCT         = 10000;
  
  private int fadeTime      = 20;
  private int colorFadeTime = 20;
  
  public boolean presence         = false;
  public boolean presenceDetected = false;
  public int presenceTimeOut      = ABSENCETIME * 2 * 1000;
  public long presenceTime        = -presenceTimeOut;
  
  private boolean announced   = false;
  private long announceTime   = 0;
  private long annouceTimeOut = randomAnnounceDelay * 2000;
    
  private float previewSize = 0.5;
  private color c = color(CTtoHEX(ct));
  
  ArrayList<LVL> _levels = new ArrayList<LVL>();
  Enlight EnlightParent;
  
  //filter out to many messages
  long lastDimMessage = 0;
  long lastCTMessage = 0;
  long lastRGBMessage = 0;
  int interval = 1000;
  
  public Luminaire()
  {
    //lowest level first (the last created level overrules all)
    addLevel("lvl_absence", getCT(), 35000);
    addLevel("lvl_work", getCT(), 35000);
    EnlightParent = ENLIGHT;
  }
  
  public void addLevel(String name, int c, int dim)
  {
    LVL l = new LVL(this, _levels.size()+1, name);
    l.saveCT(c);
    l.saveDimLevel(dim);
    _levels.add(l);
  }
  
  public int getNrOfLevels()
  {
    return _levels.size();
  }
  
  public int[] getLevels()
  {
    int[] lvl = {};
    
    for (int i = 0; i<getNrOfLevels(); i++)
    {
      lvl = append(lvl, i+1);
    }
    
    return lvl;
  }
  
  public LVL getLevel(int i)
  {
    if (i!=0) i--;
    return _levels.get(i);
  }
  
  public LVL getLevel(String i)
  {
    for (LVL l : _levels)
    {
      if (i.toUpperCase().equals( l.getName().toUpperCase() ) ) return l;
    }
    
    traceln("cant find level, returning the first");
    return _levels.get(0);
  }
  
  public void activateLevel(int level)
  {
    getLevel(level).activate(true);
  }
  
  public void deactivateLevel(int level)
  {
    getLevel(level).activate(false);
  }
  
  public void draw()
  {
  }
  
  public float getPreviewSize()
  {
    return previewSize;
  }
  
  public void setLocalAddress(String s)
  {
    localAddress = s;
  }
  
  public String getLocalAddress()
  {
    return localAddress;
  }
  
  public void setPreviewSize(float s)
  {
    previewSize = s;
  }
  
  public void updateTimers()
  {
    //presenceDetected = false;
    if (presence && millis() - presenceTime > presenceTimeOut) setPresence(false);
    if (announced && millis() - announceTime > annouceTimeOut) setAnnounced(false);
  }
  
  public void setID(int i)
  {
    luminaireID = i;
  }
  
  public int getID()
  {
    return luminaireID;
  }
  
  public void setScope(int s)
  {
    scope = s;
    if (scope == CORRIDOR) EnlightParent = ENLIGHT2;
  }
  
  public int getScope()
  {
    return scope;
  }
  
  boolean isCollidingCircleRectangle(
    float circleX,
    float circleY,
    float radius,
    float rectangleX,
    float rectangleY,
    float rectangleWidth,
    float rectangleHeight)
  {
    float circleDistanceX = abs(circleX - rectangleX - rectangleWidth/2);
    float circleDistanceY = abs(circleY - rectangleY - rectangleHeight/2);
 
    if (circleDistanceX > (rectangleWidth/2 + radius)) { return false; }
    if (circleDistanceY > (rectangleHeight/2 + radius)) { return false; }
 
    if (circleDistanceX <= (rectangleWidth/2)) { return true; }
    if (circleDistanceY <= (rectangleHeight/2)) { return true; }
 
    float cornerDistance_sq = pow(circleDistanceX - rectangleWidth/2, 2) + pow(circleDistanceY - rectangleHeight/2, 2);
 
    return (cornerDistance_sq <= pow(radius,2));
  }

  
  public void setNeighbours(int radius)
  {
    //draw a circle, everyone in the cirkel is a neighbour.
    fill(255,255,255,20);
    float circleX = this.getX() + this.getWidth()/2;
    float circleY = this.getY() + this.getHeight()/2;
    
    ellipse(circleX, circleY, radius*2, radius*2);
    
    for (Luminaire l : _luminaires(this.getScope()))
    {
      if (l != this)
      {
        float rectangleWidth = l.getWidth();
        float rectangleHeight = l.getHeight();
        float rectangleX = l.getX() + rectangleWidth/2;
        float rectangleY = l.getY() + rectangleHeight/2;
        
        if (isCollidingCircleRectangle(circleX, circleY, radius, rectangleX, rectangleY, rectangleWidth, rectangleHeight)) neighbours.add(l);
      }
    }
    //
//    for(int i = 0; i < getNumberOfLuminaires(); i++)
//    {
//      if (getLuminaire(i) != this && getLuminaire(i).getScope() == this.getScope())
//      {
//        float rectangleWidth = getLuminaire(i).getWidth();
//        float rectangleHeight = getLuminaire(i).getHeight();
//        float rectangleX = getLuminaire(i).getX() + rectangleWidth/2;
//        float rectangleY = getLuminaire(i).getY() + rectangleHeight/2;
//        
//        if (isCollidingCircleRectangle(circleX, circleY, radius, rectangleX, rectangleY, rectangleWidth, rectangleHeight)) neighbours.add(getLuminaire(i));
//      }
//    }
  }
  
  public Luminaire getNeighbour(int i)
  {
    return neighbours.get(i);
  }
  
  public void setDwars()
  {
    dwars = true;
    
    float w = getWidth() / TILE;
    float h = getHeight() / TILE;
    
    this.setHeight(w);
    this.setWidth(h);
  }
  
  public int getDwars()
  {
    if(dwars) return 1;
    return 0;
  }
  
  public long getLastAnnounce()
  {
    return announceTime;
  }
  
  public void setAnnounced(boolean a)
  {
    announced = a;
    if (a) announceTime = millis();
  }
  
  public boolean getAnnounced()
  {
    return announced;
  }
  
  public int getNrOfNeighbours()
  {
    return neighbours.size();
  }
  
  public void setPresence(boolean p)
  {
    if (presenceDetected != p)
    {
      presence = presenceDetected = p;
    }
    
    if (presence) 
    {
      presenceTime = millis();
      setGlobalPresence(getScope());
    }
    else traceln ("absence for "+ getID());
  }
  
  public boolean getGlobelPresence()
  {
    return getGlobalPresence(getScope());
  }
  
  public boolean getPresence()
  {
    return presence;
  }
  
  public boolean getPresenceDetected()
  {
    return presenceDetected;
  }
  
  //////ADDRESSS//////////////////////////
  public void setAddress(String ad)
  {
    address = ad;
  }
  
  public String getAddress()
  {
    return address;
  }
  
  public void setShortAddress(String ad)
  {
    if ( !ad.contains("0x") ) shortAddress = "0x";
    shortAddress += ad;
    announced = true;
  }
  
  public String getShortAddress()
  {
    //if (shortAddress.equals("") ) return "0xFFFD";
    return shortAddress;
  }
  
  
  //////////////
  public void update()
  {
    traceln("applying settings on lamp " + getAddress() + "only in log, not really");
    
    for (LVL l : _levels)
    {
      //update dimlevel & brightness
      //l.sendDimLevel(getDimLevel());
      //l.sendCT(getCT());
    }
    
    int c = getCT();
    
    saveCT(0);
    setCT(c);
    
    //lastMessage = millis();
  }
  ////////////
  
  //////DIMLEVEL////////////////////////////////////////////////////////////
  public float getBrightness()
  {
    float b = map(dimLevel, minDimLevel, maxDimLevel, 0, 1);
    b = constrain(b, 0, 1);
    return b;
    
  }
  
  public void setBrightness(float value)
  {
    value = constrain(value, 0, 1);
    int v = int( map(value, 0, 1, minDimLevel, maxDimLevel) );
    setDimLevel(v);
  }
  
  public boolean saveDimLevel(int value)
  {
    if (value == getDimLevel()) return true; //should be false, but than you can not update the lamp when it is stuck or something...

    if (value < getMinDimLevel() && getDimLevel() < getMinDimLevel() || value > getMaxDimLevel() && getDimLevel() > getMaxDimLevel())
    {
      traceln("A dimLevel of "+ value + " on luminaire " + getName() + " is not possible. Choose between " + getMinDimLevel() + " and " + getMaxDimLevel());
      dimLevel = value;
      return false;
    }
    
    dimLevel = value;
    return true;
  }
  
  public void updateDimLevel(int value)
  {
    value += getDimLevel();
    setDimLevel(value);
  }
  
  public void setDimLevel(int value)
  {
    if(saveDimLevel(value) ) //returns false if the the value is not new, or if the value is higher then max if it is already higher then max (or min)
    {
      if( millis() - lastDimMessage > interval)
      {
        lastDimMessage = millis();
        //saveDimLevel(value);
        
        value = constrain(value, getMinDimLevel(), getMaxDimLevel());
        EnlightParent.createMessage("DimLevelChanged", ADDRESS_PC, getAddress(), getDimLevel());
      }
    }
  }
  
  public void setDimLevel(int value, int time)
  {
    //if (fadeTime == time) 
    //{
      setDimLevel(value);
      //return;
    //}
    
    //if( saveDimLevel(value) ) //returns false if the the value is not new, or if the value is higher then max if it is already higher then max (or min)
    //{
      //saveDimLevel(value);
      //fadeTime = time;
      //EnlightParent.createMessage("Event03", ADDRESS_PC, getAddress(), getDimLevel(), fadeTime);
    //}
  }
    
  public int getDimLevel()
  {
    return dimLevel;
  }
  
  public int getMaxDimLevel()
  {
    return maxDimLevel;
  }
  
  public int getMinDimLevel()
  {
    return minDimLevel;
  }
  
  //////CT////////////////////////////////////////////////////////////
  public void disableCT()
  {
    ctEnabled = false;
  }

  public void saveCT(int value)
  { 
    if (value < getMinCT() || value > getMaxCT())  traceln("A CT of "+ value + " Kelvin on luminaire " + getName() + " is not possible. Choose between " + getMinCT() + " and " + getMaxCT());
    ct = value;
    ct = constrain(value, minCT, maxCT);
  }
  
  public void updateCT(int value)
  {
    if(!ctEnabled) traceln("CT not possible for " + getName());
    
    int newCT = getCT() + value;
    setCT(newCT);
  }
  
  public int getCT()
  {
    if(!ctEnabled) return 0;
    return ct;
  }
  
  public void setCT(int value)
  {
    //if (getCT() != value) 
    //{
    if( millis() - lastCTMessage > interval)
    {
      lastCTMessage = millis();;
      saveCT(value);
      EnlightParent.createMessage("ColorChangedCCT", ADDRESS_PC, getAddress(), value);
    }
    //}
  }
  
  public void setCT(int value, int time)
  {
//    if (colorFadeTime == time) 
//    {
      setCT(value);
//      return;
//    }
    
    //saveCT(value);
    //colorFadeTime = time;
    //EnlightParent.createMessage("Event02", ADDRESS_PC, getAddress(), getCT(), colorFadeTime);
  }
  
  public int getMaxCT()
  {
    return maxCT;
  }
  
  public int getMinCT()
  {
    return minCT;
  }
  
//////RGB/////////////////////////////////////////  
  
  public void setRGB(int r, int g, int b)
  {
    if( millis() - lastRGBMessage > interval)
    {
      lastRGBMessage = millis();
      EnlightParent.createMessage("ColorChangedRGB", ADDRESS_PC, getAddress(), r,g,b);
    }
  }
  
  public void setRGB(float r, float g, float b)
  {
    setRGB(int(r), int(g), int(b));
  }
  
  public void setRGB(float r, float g, float b, int time)
  {
    setRGB(int(r), int(g), int(b), time);
  }
  
  public void setRGB(int r, int g, int b, int time)
  {
    if (colorFadeTime == time) 
    {
      setRGB(r,g,b);
      return;
    }
    
    colorFadeTime = time;
    EnlightParent.createMessage("Event04", ADDRESS_PC, getAddress(), r,g,b, time);
  }
    
  public color getColor()
  {
    return c;
  }
  
  void toggle()
  {
    if (getOn()) setOn(false);
    else setOn(true);
  }
  
  public boolean getOn()
  {
    return on;
  }
  
  public void setOn(Boolean value)
  {
    on = value;
    int condition = value?1:0;
    
    EnlightParent.createMessage("OnOffChanged", ADDRESS_PC, getAddress(), condition);
  }
  
  public void addIndirectLight(String n)
  {
  }
}
