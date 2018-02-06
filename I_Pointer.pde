ArrayList<Pointer>   _pointers   = new ArrayList<Pointer>();
ArrayList<Indicator> _indicators = new ArrayList<Indicator>();
ControlP5 turnOff = null;

void setupPointers()
{
  Pointer p = new Pointer(nm.getNode("PointerGreen"), 2);
  p = new Pointer(nm.getNode("PointerRed"), 1);
  p = new Pointer(nm.getNode("PointerOrange"), 8);
  p = new Pointer(nm.getNode("PointerBlue"), 4);
  
  Indicator i = new Indicator(nm.getNode("IndicatorGreen"), 0);
  i = new Indicator(nm.getNode("IndicatorRed"), 1);
  i = new Indicator(nm.getNode("IndicatorOrange"), 2);
  i = new Indicator(nm.getNode("IndicatorBlue"), 3);
  
  turnOff = new ControlP5(this);
  turnOff.addButton("indicatorsOff").setPosition(600, 100).setSize(20, 20);
}

public void indicatorsOff()
{
  turnOffIndicators();
}
  
public Pointer getPointerByID(int id)
{
  for (Pointer p : _pointers)
  {
    if (p.getID() == id) return p;
  }
  
  traceln("Pointer with id " + id + " not found.");
  return null;
}

class Pointer extends Interface
{
  private int id = 0;
  private long lastUpdate = 0;
  private int timeOut = 3000;
  private int ctValue = 0;
  private int dimValue = 0;
  
  public Pointer(Node node, int id)
  {
    this.id = id;
    setNode(node);
    _pointers.add(this);
    
    println("pointer " + log(id)/log(2) + " is set up");
  }
  
  public void update(int ct, int dim)
  {
    lastUpdate = millis();
    ctValue = ct;
    dimValue = dim;
  }
  
  public int getCT()
  {
    if (millis() - lastUpdate > timeOut) traceln("I did not receive anything new..");
    return ctValue;
  }
  
  public int getDimLevel()
  {
    if (millis() - lastUpdate > timeOut) traceln("I did not receive anything new..");
    return dimValue;
  }
  
  public int getID()
  {
    return id;
  }
  
  void draw()
  {
    rect(x,y,w,h);
  }
}

class Indicator extends Interface
{
  private Area area = null;
  private int areaNumber;
  Pointer pointer = null;
  
  public Indicator(Node node, int a)
  {
    areaNumber = a;
    area = _areas.get(a);
    setNode(node);
    _indicators.add(this);
  }
  
  public void draw()
  {
    float x = getArea().getCenter().x;
    float y = getArea().getCenter().y;
    
    noFill();
    strokeWeight(2);
    if (getNode().getName().contains("Red"))    stroke(255,0,0);
    if (getNode().getName().contains("Green"))  stroke(0,200,0);
    if (getNode().getName().contains("Blue"))   stroke(0,0,255);
    if (getNode().getName().contains("Orange")) stroke(255,150,0);
    ellipse(x,y,20,20);
    
    if(pointer!=null)
    {
      if (pointer.getNode().getName().contains("Red"))    fill(255,0,0);
      if (pointer.getNode().getName().contains("Green"))  fill(0,200,0);
      if (pointer.getNode().getName().contains("Blue"))   fill(0,0,255);
      if (pointer.getNode().getName().contains("Orange")) fill(255,150,0);
    }
    else 
    {
      fill(0);
    }
    noStroke();
    ellipse(x,y,8,8);

  }
  
  public Area getArea()
  {
    return area;
  }
  
  public void updateFromPointer(Pointer p)
  {
    pointer = p;
    int ct = int( map(p.getCT(), 0, 255, 1700, 8000));
    int dim = int ( map(p.getDimLevel(), 0, 255, 0, 65535));
    
    area.setCT(ct);
    area.setDimLevel(dim);
    
    MULIaction a = new MULIaction();
    for (int i = 0; i<_pointers.size(); i++)
    {
      if (_pointers.get(i) == p)
      {
        a.IP = i+ "";
        break;
      }
    }
    a.areas = new int[] {areaNumber};
    a.function = "setLight";
    a.ct = ct;
    a.dim = dim;
    a.finish();
  }
  
  public void off()
  {
    Message msg = new Message();
    msg.setFunction( "off" );
    msg.toXBeeAddress64( Lithne.BROADCAST );
    msg.toXBeeAddress64( getNode().getXBeeAddress64() );
    getLithne().send(msg );
    pointer = null;
  }
  
}

public void turnOffIndicators()
{
  if (lithneEnabled)
    {
      Message msg = new Message();
      msg.setFunction( "off" );
      msg.toXBeeAddress64( Lithne.BROADCAST );
      //msg.toXBeeAddress64( nm.getXBeeAddress64("IndicatorRed") );
//      msg.addArgument(int(random(255)));
//      msg.addArgument(int(random(255)));
//      msg.addArgument(int(random(255)));
      getLithne().send(msg );
      
      for(Indicator i : _indicators) i.pointer = null;
      
    }
}
