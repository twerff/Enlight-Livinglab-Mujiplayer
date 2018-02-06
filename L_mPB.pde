class mPB extends PB
{
  public mPB(String ad, float x, float y)
  {
    this.setAddress(ad);
    String[] n = split(ad,":");
    
    this.setName(n[n.length-2] + ":" + n[n.length-1]);
    
    this.setWidth (1);
    this.setHeight(1);
    
    this.setPosition(new PVector(x,y));
    
    this.setPreviewSize(this.getHeight()/2);
  }
  
//  public void draw()
//  {
//    updateTimers();
//    
//    float xPos = getX();
//    float yPos = getY();
//    float h = getHeight();
//    float w = getWidth();
//        
//    //draw the border
//    noFill();
//    stroke(#00ff00);
//    if(!getAnnounced()) stroke(#ff0000);
//    if(!getOn()) fill(000);
//    rect( getX(), getY(), getWidth(), getHeight() );
//    noStroke();
//    
//    
//    fill(getColor(), getBrightness());
//    
//    //preview color
//    if(!getOn()) rect(getX() ,getY(), getPreviewSize(), getPreviewSize() );
//    
//    //fill the luminaire
//    if(getOn())
//    {
//       //if (globalPresenceDetected && !presenceDetected) fill(getColor(), 100);
//       rect( getX(), getY(), getWidth(), getHeight() );
//    } 
//    //draw the name + info
//    if(detailEnabled)
//    { 
//      fill(0);
//      text(getName(), getX(), getY()-2);
//      
//      
//      if (presence)
//      {
//        int t = (presenceTimeOut - int(millis() - presenceTime)) / 1000;
//        text(t, getX(), getY()+15);
//      }
//    }
//  }
  
//  private IndirectLight indirectLight;
//  
//  public void addIndirectLight(String n)
//  {
//    indirectLight = new IndirectLight(n);
//    indirectLight.setCT(getCT());
//    
//    //int b = int(map(brightness,0,maxBrightness,0,255));
//    //indirectLight.setBrightness(b);
//  }
}

