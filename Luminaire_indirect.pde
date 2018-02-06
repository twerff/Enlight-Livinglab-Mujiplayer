void setupIndirectLight(){}


class IndirectLight
{
  private int ct;
  private int brightness;
  private int fadeTime = 500;
  private String nodeName = "Indirect1";
  
  
  public IndirectLight(String n)
  {
    nodeName = n;
  }
  
  public void setCT(int c)
  {
    ct = c;
    sendCT(ct, fadeTime);
  }
  
  public int getCT()
  {
    return ct;
  }
  
  public void setBrightness(int i)
  {
    brightness = i;
    
    sendBrightness(brightness,fadeTime);
  }
  
  public int getBrightness()
  {
    return brightness;
  }
  
  private void sendCT(int ct, int t)
  {
    Node n = nm.getNode(nodeName);
    
    ili.lithne.Message updateMsg  =  new ili.lithne.Message();
    updateMsg.toXBeeAddress64( n.getXBeeAddress64() );
    updateMsg.toXBeeAddress16( n.getXBeeAddress16() );
    //updateMsg.setScope( breakout.getScope() );
  
    // Set the append behaviour; we wish to do so if arg 0 (lamp ID) is different from the other ili.lithne.Message.
    updateMsg.appendIfDifferent( 0 );
    // Set the overwrite behaviour - ONLY overwrite if arg 0 (lamp ID) is teh same
    updateMsg.overwriteIfEqual( 0 );
      
    updateMsg.setFunction( "ct" );
    updateMsg.addArgument( ct );
    updateMsg.addArgument( t );
      
    if( getLithne() != null )
    {
      traceln("Sending CT Message: "+updateMsg.toString() );
      getLithne().send( updateMsg );
    }
  }
  
  private void sendBrightness(int b, int t)
  {
    Node n = nm.getNode(nodeName);
    
    ili.lithne.Message updateMsg  =  new ili.lithne.Message();
    updateMsg.toXBeeAddress64( n.getXBeeAddress64() );
    updateMsg.toXBeeAddress16( n.getXBeeAddress16() );
    //updateMsg.setScope( breakout.getScope() );
  
    // Set the append behaviour; we wish to do so if arg 0 (lamp ID) is different from the other ili.lithne.Message.
    updateMsg.appendIfDifferent( 0 );
    // Set the overwrite behaviour - ONLY overwrite if arg 0 (lamp ID) is teh same
    updateMsg.overwriteIfEqual( 0 );
      
    updateMsg.setFunction( "intensity" );
    updateMsg.addArgument( b );
    updateMsg.addArgument( t );
      
    if( getLithne() != null )
    {
      traceln("Sending Brightness Message: "+updateMsg.toString() );
      getLithne().send( updateMsg );
    }
  }
}
