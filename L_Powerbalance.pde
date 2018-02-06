class PB extends Luminaire
{
  private IndirectLight indirectLight;
  
  public PB()
  {
  }
  
  public PB(String ad, float x, float y)
  {
    this.setAddress(ad);
    setID(_luminaires.size());
    String[] n = split(ad,":");
    
    this.setName(n[n.length-2] + ":" + n[n.length-1]);
    
    this.setWidth (0.5);
    this.setHeight(2);
    
    this.setPosition(new PVector(x,y));
    
    this.setPreviewSize(this.getWidth());
  }
  
  
  
  public void draw()
  {
    strokeWeight(3);
    stroke(255);
    if (!this.getSelected()) noStroke();
    updateTimers();
    
    //draw the border
    if(!getPresence()) fill(0);
    if(!getAnnounced()) fill(255,0,0);  //if not announce yet..
    rect( getX(), getY(), getWidth(), getHeight() );
    
    //fill the luminaire
    noStroke();
    int b = int( map(getDimLevel(), getMinDimLevel(), getMaxDimLevel(), 0, 255) );
    fill( CTtoHEX(getCT()), b);
    
    if(getPresence()) rect( getX(), getY(), getWidth(), getHeight() );
    //preview color
    else
    {
      fill(CTtoHEX(getCT()));
      rect(getX() ,getY(), getPreviewSize(), getPreviewSize() );
    }
    
    textAlign(CENTER,CENTER);
    outlineText(""+getID(), getX()+getWidth()/2, getY()+getHeight()/2, 0);
    
    //draw the name + info
    if(mouseOver())
    {
      textAlign(LEFT,CENTER);
      fill(0);
      text(getAddress().substring(18, 23)+"\n"+getShortAddress(), getX()+getWidth()+5, getCenter().y);
    }
    
    textAlign(LEFT,BOTTOM);
  }
  
  public void addIndirectLight(String n)
  {
    indirectLight = new IndirectLight(n);
    indirectLight.setCT(getCT());

    //int b = int(map(brightness,0,maxBrightness,0,255));
    //indirectLight.setBrightness(b);
  }
}

