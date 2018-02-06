boolean weatherEnabled = false;
Weather weather;
 
void setupWeather()
{
  weatherEnabled = true;
  weather = new Weather();
}

void doWeather()
{
  if (newHour()) weather.getWeatherInfo();
  if (ENLIGHT._unfoundLuminaires.size() == 0) weather.draw();
}

class Weather
{
  ArrayList<Cloud> _clouds = new ArrayList<Cloud>();
  long randomCloud = 10;
  
  int windSpeed = 10;
  int windDirection = 90;
  float cloudiness = 0.1;
  
  public Weather()
  {
    //getWeatherInfo();
  }
  
  public void getWeatherInfo()
  {
    String location = "eindhoven";
    String API = "https://query.yahooapis.com/v1/public/yql?q=";
    
    String url = API + "select%20item.condition.code%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22"+location+"%22)&format=xml&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys";
    XML xml = loadXML(url);
    
    int c = xml.getChild("results").getChild("channel").getChild("item").getChildren()[0].getInt("code");
    
    if (c <= 4) cloudiness = 1;
    else if (c == 27 || c == 28) cloudiness = 0.7;
    else if (c <= 30) cloudiness = 0.5;
    else if (c <= 32) cloudiness = 0;
    else if( c == 44 ) cloudiness = 0.5;
    else if (c >= 38 ) cloudiness = 0.8;
    else traceln("got weather code "+ c + "have a look at https://developer.yahoo.com/weather/documentation.html");
    
    url = API + "select%20wind%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22"+location+"%22)&format=xml";
    xml = loadXML(url);
    
    XML wind = xml.getChild("results").getChild("channel").getChildren()[0];
    windSpeed = wind.getInt("speed");
    windDirection = wind.getInt("direction");
    
    traceln("Weather info updated: " + (cloudiness*100) + "% clouds & wind at " + windSpeed + "km/h at " + windDirection + " degrees");
  }
  
  public void draw()
  {    
    //clouds
    for (int i = 0; i<_clouds.size(); i++) 
    {
      Cloud c = _clouds.get(i);
      c.draw();
    }
    
    if (millis() > randomCloud)
    {
      Cloud c = new Cloud();
      randomCloud = millis() + int(random(5000, 20000 / cloudiness));
      traceln("new cloud in " + (randomCloud - millis())/1000 + " seconds");
    }
  }
  
  class Cloud
  {
    float x;
    float y;
    float w;
    float h;
    float speed;
    float direction;
    long created;
    int density;
    
    ArrayList<Luminaire> _lums = new ArrayList<Luminaire>();
    
    public Cloud()
    {
      x = width/2  + width/2 * cos( random(0.75, 1.25)*PI - radians(windDirection) );
      y = height/2 + height/2 * sin( random(0.75, 1.25)*PI - radians(windDirection) );
      
      w = random(20,400);
      h = random(20,400);
      h = w;
      density = int( random (5000,30000) );
      speed = random(windSpeed/3*2 , windSpeed/3*4);
      direction = windDirection;
      created = millis();
      weather._clouds.add(this);
    }
    
    public void draw()
    {
      long timeTraveling = millis() - created;
      
      float xdirection = ( cos(radians(direction)) );
      float ydirection = ( sin(radians(direction)) );
      
      x += ( speed/36 * xdirection );
      x += ( speed/36 * ydirection );
      
      ellipse(x,y,w,h);
      
      for (int i = 0; i<_luminaires.size(); i++)
      {
        Luminaire l = _luminaires.get(i);
        
        if ( circleRect(x,y,w/2, l.getX(),l.getY(),l.getWidth(),l.getHeight()) )
        {
          boolean neww = true;
          for (Luminaire ll : _lums)
          {
            if (ll == l) neww = false;
          }
          
          if (neww)
          {
            _lums.add(l);
            l.updateDimLevel( -density );
          }
        }
        else
        {
          for (int ii = 0; ii<_lums.size(); ii++)
          {
            Luminaire ll = _lums.get(ii);
            if (l == ll)
            {
              _lums.remove(l);
              l.updateDimLevel( density );
            }
          }
        }
      }
      
      //remove the cloud if out of stage
      if(x>width*2 || x<-width || y>height*2 || y<-height) weather._clouds.remove(this);
    }
  }
}



  

