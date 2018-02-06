import java.awt.Polygon;

ArrayList<Area> _areas;

void setupAreas()
{
  _areas = new ArrayList<Area>();
  _areas.add( new Area( new PVector(250,25), new PVector(410,25), new PVector(410,170), new PVector(350, 170), new PVector(350,250), new PVector(250,250) ) );
  _areas.add( new Area( new PVector(420,25), new PVector(580,25), new PVector(580,170), new PVector(420,170) ) );
  _areas.add( new Area( new PVector(360,180), new PVector(470,180), new PVector(470,325), new PVector(360,325) ) );
  _areas.add( new Area( new PVector(480,180), new PVector(580,180), new PVector(580,325), new PVector(480,325) ) );
  
  //CORRIDOR area?
}

class Area extends Polygon
{
  String name = "";
  boolean hit = false;
  
  ArrayList<PVector> _points = new ArrayList<PVector>();
  ArrayList<Luminaire> _lamps = new ArrayList<Luminaire>();
  
  float x = width;
  float y = height;
  float w = 0;
  float h = 0;
  
  private int ct;
  private int dimLevel;
  private int activity = 0;
  private boolean selected = false;
  
  public Area(PVector... p)
  {
    name = "area " + str( _areas.size() );
    
    for (int i = 0; i<p.length; i++)
    {
      _points.add( p[i] );
    }
    
    float x2 = 0, y2 = 0;
    
    for (PVector pp : _points)
    {
      if (pp.x < x)   x = pp.x;
      if (pp.y < y)   y = pp.y;
      if (pp.x > x2) x2 = pp.x;
      if (pp.y > y2) y2 = pp.y;
    }
    
    w = x2 - x;
    h = y2 - y;
    
    findLuminaires();
  }
  
  private void findLuminaires()
  {
    for (Luminaire l : _luminaires)
    {
      PVector point = new PVector(l.getX(), l.getY());
      
      if (pixelInArea(point, this)) _lamps.add(l);

    }
  }
  
  public PVector getCenter()
  {
    float x = 1000;
    float xw = 0;
    float y = 1000;
    float yh = 0;
    PVector center = new PVector(0,0);
    
    for (Luminaire l : _lamps)
    {
      if (l.getX()               < x)  x = l.getX();
      if (l.getX()+l.getWidth()  > xw) xw = l.getX()+l.getWidth();
      if (l.getY()               < y)  y = l.getY();
      if (l.getY()+l.getHeight() > yh) yh = l.getY()+l.getHeight();
    }
    
    return new PVector(x + (xw-x)/2 , y + (yh-y)/2);
  }
  
  public void draw()
  {
    ct = _lamps.get(0).getCT();
    dimLevel = _lamps.get(0).getDimLevel();
    
    noFill();
    noStroke();
    if (hit)
    {
      fill(255,50);
      strokeWeight(1);
      stroke(255);
    }

    beginShape();
    for (PVector p : _points)
    {
     vertex(p.x, p.y);
    }
    
    vertex(_points.get(0).x, _points.get(0).y);
    endShape();
  }
  
  public void toggleSelect()
  {    
    for (Luminaire l : _lamps)
    {
      l.toggleSelect();
    }
    
    selected = !selected;
  }
  
  public void select()
  {
    traceln("Area selected");
    
    for (Luminaire l : _lamps)
    {
      l.select();
    }
    
    selected = true;
  }
  
  public void deselect()
  {
    for (Luminaire l : _lamps)
    {
      l.deselect();
    }
    
    selected = false;
  }
  
  public void setCT(int value)
  {
    //traceln(name + " update ct to " + value);
    ct = value;
    
    for (Luminaire l : _lamps)
    {
      l.setCT(value);
    }
  }
  
  public int getCT()
  {
    return ct;
  }
  
  public int getDimLevel()
  {
    return dimLevel;
  }
  
  public void setActivity(int value)
  {
    activity = value;
  }
  
  public int getActivity()
  {
    return activity;
  }
  
  public boolean getSelected()
  {
    return selected;
  }
  
  public void setDimLevel(int value)
  {
    //traceln(name + " update dimlevel to " + value);
    dimLevel = value;
    
    for (Luminaire l : _lamps)
    {
      l.setDimLevel(value);
    }
  }
  
}
