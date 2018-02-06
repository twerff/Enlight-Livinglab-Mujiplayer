ArrayList<Poly> _polygons = new ArrayList<Poly>();

void newPolygon(int act, int ct, int dim, int... areas)
{ 
  //remove the areas from the other polygons
  removePolygon(areas);
  
  //if the activity is not -1; 
  if (act >= 0)
  {
    Poly p = new Poly(act, ct, dim, areas);
    _polygons.add(p);
  }
  
  addDrawingToXML(act,ct,dim,areas);
}

void removePolygon(int... areas)
{
  //remove the areas from the other polygons
  for (Poly p : _polygons) p.remove(areas);
  
  //if a polygon is empty, remove it
  for (int i = 0; i<_polygons.size(); i++)
  {
    Poly p = _polygons.get(i);
    
    if (p.areas.size() == 0)
    {
      _polygons.remove(p);
      i--;
    }
  }
  
  removeDrawingFromXML(areas);
}

void turnOff(int... areas)
{
  for (int i : areas)
  {
    _areas.get(i).setDimLevel( 0 );
  }
}

class Poly
{
  ArrayList<Integer> areas = new ArrayList<Integer>();
  int activity = -1;
  int ct;
  int dimLevel;
  int ID;
  
  public Poly(int act, int ct, int dim, int... ar)
  {
    ID = _polygons.size();
    
    activity = act;
    this.ct = ct;
    dimLevel = dim;
    
//    if (ar.length == 4)
//    {
//      ENLIGHT.createMessage("timeUpdated", ADDRESS_PC, ct);
//      ENLIGHT.createMessage("dimLevelChanged", ADDRESS_PC, dim);
//    }
    for (int i = 0; i<ar.length; i++)
    {
      areas.add(ar[i]);
      Area a = _areas.get( ar[i] );
      
      a.setCT( ct );
      a.setActivity( act );
      a.setDimLevel( dim );
    }
  }
  
  public void remove(int... areasToRemove)
  {    
    for (int i = 0; i<areasToRemove.length; i++)
    {
      for (int a = 0; a<areas.size(); a++)
      {
        if (areasToRemove[i] == areas.get(a))
        {
          areas.remove( a );
        }
      }
    }
  }
  
  public void apply()
  {
  }
}
