import java.text.SimpleDateFormat;
import java.util.Date;

///GEOMETRY///

boolean pixelInArea(PVector p, Area a)
{
  float[] vertX = new float[a._points.size()];
  float[] vertY = new float[a._points.size()];

  for (int i = 0; i<a._points.size(); i++)
  {
    PVector pp = a._points.get(i);
    vertX[i] = pp.x;
    vertY[i] = pp.y;
  }

  if (pixelInPolygon(a._points.size(), vertX, vertY, p.x, p.y)) return true;

  return false;
}

boolean pixelInPolygon(int numVertices, float[] vertX, float[] vertY, float px, float py)
{
  boolean collision = false;
  
  //check if the point is in one of the polygons
  for (int i=0, j=numVertices-1; i < numVertices; j = i++) {
    if ( ((vertY[i]>py) != (vertY[j]>py)) && (px < (vertX[j]-vertX[i]) * (py-vertY[i]) / (vertY[j]-vertY[i]) + vertX[i]) ) {
      collision = !collision;
    }
  }
  
  return collision;
}

boolean pixelInItem(PVector p, Item i)
{
  return p.x > i.getPosition().x &&
    p.x < i.getPosition().x+i.getWidth()&&
    p.y > i.getPosition().y &&
    p.y < i.getPosition().y+i.getHeight()
  ;
}

public boolean circleRect(float cx, float cy, float radius, float rx, float ry, float rw, float rh) {
  
  // temporary variables to set edges for testing
  float testX = cx;
  float testY = cy;
  
  // which edge is closest?
  if (cx < rx)         testX = rx;        // compare to left edge
  else if (cx > rx+rw) testX = rx+rw;     // right edge
  if (cy < ry)         testY = ry;        // top edge
  else if (cy > ry+rh) testY = ry+rh;     // bottom edge
  
  // get distance from closest edges
  float distX = cx-testX;
  float distY = cy-testY;
  float distance = sqrt( (distX*distX) + (distY*distY) );
  
  // if the distance is less than the radius, collision!
  if (distance <= radius) {
    return true;
  }
  return false;
}

/// TIME ///
int hour, minute, day;

int getTimeAsInt(String time)
{
  int h = parseInt( time.substring(0,2) );
  int m = parseInt( time.substring(3,5) );
  int s = parseInt( time.substring(6,8) );
  return h*60*60 + m*60 + s;
}

String getTime()
{
  hour = hour();
  minute = minute();
  int sec = second();
  
  String time = "";
  
  if (hour < 10) time += "0";
  time += hour+":";
  
  if (minute < 10) time+="0";
  time += minute+":";
   
  if (sec < 10) time+="0";
  time += sec;
  
  return time;
}

String getDate()
{
  String date = "";
  
  if (day() < 10) date+= "0";
  date+=day();
  date+="/";
  if (month() < 10) date+= "0";
  date+=month();
  date+="/";
  date+=year();
  return date;
}

boolean newMinute()
{  
  if (minute != minute())
  {
    minute = minute();
    return true;
  }
  return false;
}

boolean newHour()
{  
  if (hour != hour())
  {
    hour = hour();
    return true;
  }
  return false;
}

boolean newDay()
{  
  if (day != day())
  {
    day = day();
    return true;
  }
  return false;
}


/// COLOR ////

public color CTtoHEX(int ct)
{
  ct = ct/100 + 10;
  
  float r = 0;
  float g = 0;
  float b = 0;
  
  //red
  if (ct <= 66) {
    r = 255;
  } else {
    r = ct - 60;
    r = 329.698727446 * pow(r,-0.1332047592);
  }
  
  //green
  if (ct <= 66 ) {
    g = ct;
    g = 99.4708025861 * log(g) - 161.1195681661;
  } else {
    g = ct - 60;
    g = 288.1221695283 * pow(g, -0.0755148492);
  }
  
  //blue
  if (ct >= 66 ) {
    b = 255;
  } else {
    if (ct <= 19) {
      b = 0;
    } else {
      b = ct - 10;
      b = 138.5177312231 * log(b) - 305.0447927307; 
    }
  }
  
  //
  if (r < 0) r = 0;
  if (r > 255) r = 255;
  
  if (g < 0) g = 0;
  if (g > 255) g = 255;
  
  if (b < 0) b = 0;
  if (b > 255) b = 255;
  
  return color(r,g,b);
}



//DEBUG FUNCTIONS
String monitor = "";

public void showMonitor()
{
  text(monitor, 10, height-10);
  monitor = getTime() + " " + getDate2() + " ";
}

public void monitor(String s)
{
  monitor += " " + s;
}

boolean traceStarted = false;
PrintWriter output;

void trace(String ln)
{
  if (!traceStarted)
  {
    print("[" + getTime() + "] \t");
    traceStarted = true;
  }
  
  print(ln);  
}

void endTrace()
{
  println();
  traceStarted = false;
}

void traceln(String ln)
{
  trace(ln);
  //log it!
  output.print(ln);
  output.flush();
  output.close();
  endTrace();
}

void traceln(int i) 
{
  traceln(""+i);
}

void traceln(boolean i)
{
  traceln(""+i);
}

void traceln(String[] ln)
{
  print("[" + getTime() + "] \t");
  
  for (int i=0;i<ln.length;i++)
  {
    print(ln[i]+"\t");
  }
  println();
}


///NEW TIMES
float MILLIS  = 0;
float SECONDS = 1000;
float MINUTES = SECONDS*60;
float HOURS   = MINUTES*60;
float DAYS    = HOURS*24;
float WEEKS   = DAYS*7;
float MONTHS  = DAYS * (30 + 5/12);
float YEARS   = DAYS* 365.25;

public Date getDate2()
{
  Date pdate = new Date();
 
  String date = "";
  
  date += day();
  date += month();
  date += year();
  date += hour();
  date += minute();
  date += second();
    
  try { pdate = new SimpleDateFormat("dd-mm-yy HH:mm:ss").parse(date); }
  catch (Exception e) {};
  
  return pdate;
}

public long getDifference(Date d1, Date d2, float time)
{
  if (d1 != null && d2 != null)
  {
    long difference = d1.getTime() - d2.getTime();
    return int(difference / time);
  }
  
  else return 9999999;
}

public void outlineText(String text, float x, float y, int fill)
{
  outlineText(text, x, y, fill, 1);
}

public void outlineText(String text, float x, float y, int fill, int weight)
{
  fill(0);
  if (fill < 125) fill(255);
  
  for (int xx = -weight; xx<weight+1; xx++)
  {
    for (int yy = -weight; yy<weight+1; yy++)
    {
      text(text, x+xx, y+yy);
      text(text, x+yy, y+xx);
    }
  }
  
  fill(fill);
  text(text, x, y);
}
