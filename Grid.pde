int consoleX = 610;

ArrayList<Room> _rooms = new ArrayList<Room>();

void setupMap()
{
  _rooms.add(new Room("Breakout",  1,   3,    5.5,  8));
  _rooms.add(new Room("Office",    6.5, 3,    6,    8));
  _rooms.add(new Room("Meeting 1", 14,  16.5, 5,    5));
  _rooms.add(new Room("Meeting 2", 14,  21.5, 5,    5));
  _rooms.add(new Room("Storage",   1,   15,   10,   6));
  _rooms.add(new Room("Kitchen",   1,   21,   10,   5));
  _rooms.add(new Room("Flex",      19,  16.5, 10.5, 12, false));
  _rooms.add(new Room("Studio",    12.5,1,    17,   15.5, false));
}

void drawMap()
{
  drawBackground();
  drawGrid();
  for (Area a : _areas) a.draw();
  
  //outline
  noFill();
  strokeWeight(1);
  stroke(0);
  linea(1,    1,    29.5, 1);
  linea(29.5, 1,    29.5, 28.5);
  linea(29.5, 28.5, 11, 28.5);
  linea(11,   28.5, 11, 25);
  linea(6.5,  1,    6.5,  3);
  linea( 17.5, 16.5, 29.5, 16.5);
  
  for (Room r:_rooms) r.draw();
  
  
  for(Luminaire l : _luminaires) l.draw();
  for(Scope s : _scopes) s.draw();
}

void drawBackground()
{
  fill(200,200,200);
  noStroke();
  rect(0,0,width,height);
}



void drawGrid()
{
  //draw grid
  noFill();
  strokeWeight(1);
  stroke(210,210,210);
  
  for (int y = 1; y<29; y++)
  {
    for (int x = 1; x<30; x++)
    {
      recta(x,y,1,1);
    }
  }
}

boolean detailEnabled = true;
boolean simulationEnabled = false;

class Room extends Item
{
  boolean hit = false;
  boolean selected = false;
  boolean border = true;
  
  ArrayList<Luminaire> _lamps = new ArrayList<Luminaire>();
  
  public Room(String _name, float _x, float _y, float _w, float _h)
  {
    setName(_name);
    setPosition(_x,_y);
    setWidth(_w);
    setHeight(_h);
    findLuminaires();
  }
  
  public Room(String _name, float _x, float _y, float _w, float _h, boolean _border)
  {
    setName(_name);
    setPosition(_x,_y);
    setWidth(_w);
    setHeight(_h);
    border = _border;
    findLuminaires();
  }
  
  private void findLuminaires()
  {
    for (Luminaire l : _luminaires)
    {
      PVector point = new PVector(l.getX(), l.getY());
      if (pixelInItem(point, this)) _lamps.add(l);
    }
  }
  
  public void draw()
  {
    noStroke();
    noFill();
    
    if (hit) fill(255,100);
    if (border) stroke(0);
    rect(getPosition().x, getPosition().y, getWidth(), getHeight());
    
    fill(0);
    text(getName() + " (" + _lamps.size() + ")", getPosition().x+0.5*TILE, getPosition().y+TILE);
    noFill();
  }
  
  public void toggleSelect()
  {    
    for (Luminaire l : _lamps)
    {
      l.toggleSelect();
    }
    
    selected = !selected;
  }
}

void recta(float x, float y, float w, float h)
{
  rect(TILE*x, TILE*y, TILE*w, TILE*h);
}

void linea(float x, float y, float w, float h)
{
  line(TILE*x, TILE*y, TILE*w, TILE*h);
}

public int getNumberOfLuminaires()
{
  return _luminaires.size();
}

public Luminaire getLuminaire(int i)
{
  return _luminaires.get(i);
}

public void drawRGBgrid(int x, int y, int w, int h)
{
  ///
  //  Draw a colorgrid on the screen if you like  
  colorMode(HSB,w,h,255);
  for(int i = x; i < x+w; i++){
    for(int j = y; j < y+h; j++){
      stroke(i,j,255);
      point(i,j);
    }
  }
  colorMode(RGB);
}
