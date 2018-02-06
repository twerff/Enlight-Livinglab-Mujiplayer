public class Item extends Polygon
{
  private boolean selected = false;
  
  private PVector position;
  private float width,height;
  
  private String name = "";
  
  ArrayList<Luminaire> neighbours = new ArrayList<Luminaire>();
  
  public Item()
  { 
  }
  
  public void setName(String n)
  {
    name = n;
  }
  
  public String getName()
  {
    return this.name;
  }
  
  public void setWidth(float w)
  {
    width = w * TILE;
  }
  
  public void setHeight(float h)
  {
    height = h * TILE;
  }
  
  public void setRawPosition( float xx, float yy)
  {
    position = new PVector(xx,yy);
  }
  
  public void setPosition( float xx, float yy)
  {
    float x = xx * TILE;
    float y = yy * TILE;
    position = new PVector(x,y);
  }
  
  public void setPosition( PVector p )
  {
    float x = p.x * TILE;
    float y = p.y * TILE;
    position = new PVector(x,y);
  }
  
  public float getWidth()
  {
    return width;
  }
  
  public float getHeight()
  {
    return height;
  }
  
  public int getX()
  {
    return int(position.x);
  }
  
  public int getY()
  {
    return int(position.y);
  }
  
  public PVector getPosition()
  {
    return position;
  }
  
  public PVector getCenter()
  {
    return new PVector(position.x+width/2, position.y+height/2);
  }
  
  public boolean getSelected()
  {
    return selected;
  }
  
  public void deselect()
  {
    selected = false;
  }
  
  public void select()
  {
    selected = true;
  }
  
  public void toggleSelect()
  {
    selected = !selected;
  }
  
  public boolean mouseOver()
  {
    boolean mouseover = mouseX > position.x && mouseX < position.x+width && mouseY > position.y && mouseY < position.y+height;
    return mouseover;
  }
}
