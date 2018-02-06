boolean chaseEnabled = false;
boolean discoEnabled = false;
boolean circadianEnabled = false;
boolean runOnce = true;

ArrayList<Luminaire> newLum = new ArrayList<Luminaire>();
int[] newCT = {8000, 1500};
int oldCT = 4000;

//run after a red light
void smartGoals(int scope)
{
  if (millis()-lastChase > chaseInterval)
  {
    lastChase = millis();

    if (runOnce)
    {
      runOnce = false;   
      newLum.add( _luminaires(scope).get(2) );
      newLum.add( _luminaires(scope).get(1) );
      newLum.get(0).setCT(newCT[0]);
      newLum.get(1).setCT(newCT[1]);
      traceln("smart goals game starts!");
    }

    for (int i = 0; i<2; i++) 
    {
      Luminaire l = newLum.get(i);
      
      if (l.getPresenceDetected()) 
      {
        l.setCT(oldCT, 10);
        Luminaire newL = randomLuminaire(scope);
        newLum.set(i, newL);
        //if (newLum == newLum2) newLum = randomLuminaire(STUDIO);
        newL.setDimLevel(65535, 5);
        newL.setCT(newCT[i], 5);
      }
    }
  }
}

//public void newLum()
//{
//  if (newLum!=null) 
//  {
//    newLum2.setCT(oldCT);
//    newLum.setDimLevel(1000,10);
//  }
//  newLum = randomLuminaire(STUDIO);
//  if (newLum == newLum2) newLum = randomLuminaire(STUDIO);
//  newLum.setDimLevel(65535,1);
//}
//
//public void newLum2()
//{
//  if (newLum2!=null) newLum2.setCT(oldCT);
//  newLum2 = randomLuminaire(STUDIO);
//  if (newLum2 == newLum) newLum2 = randomLuminaire(STUDIO);
//  newLum2.setCT(newCT2);
//}

long lastChase = 0;
int chaseInterval = 10;
int minLoc = 200;
int maxLoc = 700;
int loc = minLoc;
int direction = 1;

void doChase(int i)
{
  chaseInterval = i;
  if (millis()-lastChase > chaseInterval)
  {     
    lastChase = millis();
    if (loc < maxLoc) loc += 5;
    else loc = minLoc;

    for (Luminaire l : _luminaires)
    {
      if (l.getScope() == STUDIO)// && l.getY() < 200)
      {
        if ( l.getX() - loc == 10)      l.setDimLevel(l.getMaxDimLevel(), 1);//l.setCT(2700);
        else if ( loc - l.getX() == 30) l.setDimLevel(39000, 1);//l.setCT(6500);
      }
    }
  }

  strokeWeight(10);
  stroke(0);
  line(loc, 0, loc, height);
}

void doDisco()
{
  for (Luminaire l : _luminaires)
  {
    if (l.getSelected())
    {
      if (millis()-l.lastUpdate > l.randomUpdate+5000)
      {
        l.lastUpdate = millis();
        println("disco");
        int r = (int) random(255);
        int g = (int) random(255);
        int b = (int) random(255);

        int br = (int) random(65535);
        int ct = (int) random(15000);

        int time = (int) random(2000);

        //l.setCT(ct,time);
        //l.setDimLevel(br,time);

        l.setRGB(r, g, b);

        l.randomUpdate = int ( random(3000) );
      }
    }
  }
}

//cts from 8am - 6 pm
int cts[] = {  3500,  6000,  5000,  4000,  4000,  3700,  4000,  4500,  5000,  4000,  3700, 3700};

int prevHour[] = {0,0,0,0,0,0,0};

void doCircadianRhythm(int scope)
{
  if (prevHour[scope] != hour())
  {
    prevHour[scope] = hour();
    int currentCT = 0;
    if (hour() < 8)  currentCT = cts[0];
    else if (hour() > 18) currentCT = cts[cts.length-1];
    else currentCT = cts[hour() - 8];
    traceln("CIRC " + currentCT);
    
    traceln("circadian, yeey: " + currentCT);
    
    int currentDim = 65535;
    if (hour() == 10) currentDim = 65535;
    if (hour() == 12) currentDim = 45000;
    if (hour() == 13) currentDim = 65535;
    if (hour() == 17) currentDim = 45000;
    if (hour() == 19) currentDim = 30000;
    
    int oldCT = _luminaires(scope).get(0).getCT();
    int oldDim = _luminaires(scope).get(0).getDimLevel();
    int transitionTime = abs(oldCT - currentCT) * 10;
    
    for (Luminaire l : _luminaires(scope))
    {
      l.saveCT(currentCT);
      l.saveDimLevel(currentDim);
      l.EnlightParent.createMessage("ColorChangedCCT", ADDRESS_PC, l.getAddress(), currentCT);//, transitionTime);
      //l.EnlightParent.createMessage("DimLevelChanged", ADDRESS_PC, l.getAddress(), currentDim, transitionTime);
    }
  }
}



///IBOOD HUNT
String lastiBood = "";
int iBoodInterval = 1000;
long lastiBoodCheck = 0;
long lastnewiBood;

public boolean newiBood()
{
  if (millis() - lastiBoodCheck > iBoodInterval)
  {
    lastiBoodCheck = millis();

    String lines[] = loadStrings("http://www.ibood.com/nl/nl/");

    if (!lines[7].equals(lastiBood))
    {
      println(lines[7]);
      lastiBood = lines[7];
      lastnewiBood = millis();
      return true;
    } else
    {
      return false;
    }
  }

  return false;
}

public void checkiBood()
{
  if (newiBood())
  {
    println("NEW!");

    for (Luminaire l : _luminaires (FLEX))
    {
      l.setDimLevel(l.getMaxDimLevel());
      l.setCT(l.getMaxCT());
    }
  } else if (millis() - lastnewiBood >= 1500 && millis() - lastnewiBood <= 2000)
  {
    for (Luminaire l : _luminaires (FLEX))
    {
      l.setDimLevel(40000);
      l.setCT(4000);
    }
  }
}

///////////////

