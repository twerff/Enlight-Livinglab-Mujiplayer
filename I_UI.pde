/*TODO
- werkt nog niet helemaal lekker omdat op stage geinit moet worden...
- geeft ook errors..
*/

ControlP5 cp5;

void CT(int d)
{
  ui.CT(d);
  Textfield txt = ((Textfield)cp5.getController("CTText"));
  txt.setValue(""+d);
}

public void CTText(String theValue) {
  Slider slid = ((Slider)cp5.getController("CT"));
  slid.setValue(int(theValue));
  ui.CT(int(theValue));
}

void DimLevel(int d)
{
  ui.DimLevel(d);
  Textfield txt = ((Textfield)cp5.getController("DimLevelText"));
  txt.setValue(""+d);
}

public void DimLevelText(String theValue) 
{
  Slider slid = ((Slider)cp5.getController("DimLevel"));
  slid.setValue(int(theValue));
  ui.DimLevel(int(theValue));
}

void selectAll(boolean theFlag)
{
  ui.selectAll(theFlag);
}

void disco(boolean d)
{
  ui.disco(d);
}

void announce()
{
  ui.announce();
}

void resend()
{
  ui.resend();
}


class UI extends Interface
{  
  public UI(PApplet p)
  {
    Luminaire l = _luminaires.get(0);
    cp5 = new ControlP5(p);
    
    cp5.addSlider("DimLevel").setPosition(600,20).setRange(0, l.getMaxDimLevel()).setCaptionLabel("");
    cp5.addSlider("CT").setPosition(600,40).setRange(l.getMinCT(), l.getMaxCT()).setCaptionLabel("");
    
    Textfield DimLevelText = cp5.addTextfield("DimLevelText").setPosition(710, 10).setSize(50, 20).setCaptionLabel("DimLevel");
    Textfield CTText = cp5.addTextfield("CTText").setPosition(710, 40).setSize(50, 20).setAutoClear(false).setCaptionLabel("CT");
    
    cp5.addToggle("selectAll")
     .setPosition(600,60)
     .setSize(20,20)
     .setCaptionLabel("Select all");
     ;
     
    cp5.addToggle("disco")
     .setPosition(650,60)
     .setSize(20,20)
     .setCaptionLabel("Disco");
     ;
    
    cp5.addBang("announce")
       .setPosition(650, 100)
       .setSize(20, 20)
       .setTriggerEvent(Bang.RELEASE)
       .setCaptionLabel("Announce");
       ;
       
    cp5.addBang("resend")
      .setPosition(700, 100)
      .setTriggerEvent(Bang.RELEASE)
      .setSize(20, 20)
      .setCaptionLabel("Resend values");
      ;
  }
  
  public void resend()
  {
    for (Luminaire l:_luminaires(STUDIO))
    {
      int ct = l.getCT();
      int dim = l.getDimLevel();
      l.saveCT(0);
      l.saveDimLevel(0);
      l.setCT(ct);
      l.setDimLevel(dim);
    }
  }
  
  public void announce()
  {
    for (Luminaire l:getSelectedLuminaires())
    {
      l.setAnnounced(false);
    }
    
    ENLIGHT.requestToAnnounce(getSelectedLuminaires());
    ENLIGHT2.requestToAnnounce(getSelectedLuminaires());
    
    //DOES NOT WORK. NOT SENDING/RECEIVING MESSAGES IN WHILE LOOP
//    int tries = 0;
//    int maxTries = 5;
//    long lastAnnounce = 0;
//    int announceDelay = 2500;
//    while(getSelectedLuminaires().size() > 0 && tries < maxTries)
//    {
//      if (millis() > lastAnnounce + announceDelay)
//      {
//        lastAnnounce = millis();
//        ENLIGHT.requestToAnnounce(getSelectedLuminaires());
//        
//        tries++;
//        traceln("tried announce stuff "+tries+" times.");
//      }
//    }
    
  }
  

  void CT(int value)
  {
    for (Luminaire l : _luminaires)
    {
      if (l.getSelected()) l.setCT(value, 20);
    }
  }
  
  void DimLevel(int value)
  {
    for (Luminaire l : _luminaires)
    {
      if (l.getSelected()) l.setDimLevel(value, 20);
    }
  }
  
  void disco(boolean b)
  {
    discoEnabled = b;
  }
  
  void selectAll(boolean b)
  {
    if (b)
    {
      for (Luminaire l : _luminaires)
      {
        l.select();
      }
    }
    else
    {
      for (Luminaire l : _luminaires)
      {
        l.deselect();
      }
    }
    
  }
  
  void mousePressed(float x, float y)
  {
    if (hitLuminaire(x,y) != null) 
    {
      hitLuminaire(x,y).toggleSelect();
    }
  }
  
  Luminaire hitLuminaire(float x, float y)
  {
    for (Luminaire l : _luminaires)
    {
      if ( x > l.getX() && x < l.getX() + l.getWidth() )
      {
        if ( y > l.getY() && y < l.getY() + l.getHeight() )
        {
          return l;
        }
      }
    }
    
    return null;
  }
}

public ArrayList<Luminaire> getSelectedLuminaires()
{
  ArrayList<Luminaire> luminaires = new ArrayList<Luminaire>();
  
  for (Luminaire l : _luminaires)
  {
    if (l.getSelected()) luminaires.add(l);
  }
  
  return luminaires;
}


