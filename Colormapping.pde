void gradient(String function, PVector start, PVector end, int ct1, int ct2)
{
  float dx = start.x - end.x;
  float dy = start.y - end.y;
  
  float d =  sqrt( sq(dx) + sq(dy) );
  
  int dct = ct2 - ct1;
    
  for (Luminaire l : _luminaires(STUDIO))
  {
    float distance = sqrt( sq(l.getPosition().x - start.x) + sq(l.getPosition().y - start.y) );
    float p = distance / d;
    
    if (function.equals("CT")) 
    {
      int value = int (ct1 + dct * p);
      l.setCT(value);
    }
    else if (function.equals("dimLevel"))
    {
      int value = int (ct1 + dct * p);
      l.setDimLevel(value);
    }
  }
}
