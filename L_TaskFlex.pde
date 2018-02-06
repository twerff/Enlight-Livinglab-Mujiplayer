class Taskflex extends Luminaire
{
  
  private Luminaire parent;
  
  public Taskflex(String ad, float x, float y)
  {
    this.setAddress(ad);
    
    String[] n = split(ad,":");
    this.setName(n[n.length-2] + ":" + n[n.length-1]);
    
    this.setPosition(new PVector(x,y));
    this.setWidth (0.5);
    this.setHeight(0.5);
    
    this.setPreviewSize(this.getHeight());
    
    disableCT();
  }
  
  public void draw()
  {
    //draw the border
    noFill();
    stroke(#00ff00);
    if(!this.getAnnounced()) stroke(#ff0000);
    ellipse( getX(), getY(), getWidth(), getHeight() );
    noStroke();
    
    int b = int( map(getDimLevel(),getMinDimLevel(), getMaxDimLevel(), 0, 255) );
    fill(250, b);
    
    //draw the name + info
    if(detailEnabled)
    { 
      fill(0);
      text(getShortAddress(), getX(), getY()-2);
    }
  }
  
  public void setParent(Luminaire p)
  {
    parent = p;
  }
  
}
