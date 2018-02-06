XML map;

void loadMapXML()
{
  try
  {
    map = loadXML("/data/map.xml");
  }
  catch (Exception e)
  {
    println("map XML file not found! Creating a new one..");
    map = parseXML("<map></map>").addChild("drawings");
    
    updateMapXML();
  }
  
  loadDrawings();
  
  println("map XML is loaded");
}

void loadDrawings()
{
  for (XML drawing : map.getChild("drawings").getChildren("drawing"))
  {
    int act = drawing.getInt("act");
    int ct = drawing.getInt("ct");
    int dim = drawing.getInt("dimLevel");
    
    int[] areas = {};
    
    for (XML area : drawing.getChildren("area")) areas = append(areas, area.getInt("ID"));

    newPolygon(act, ct, dim, areas);
  }
}

void addDrawingToXML(int act, int ct, int dim, int... areas)
{
  removeDrawingFromXML(areas);
  
  XML drawing = map.getChild("drawings").addChild("drawing");
  drawing.setInt("activity", act);
  drawing.setInt("ct", ct);
  drawing.setInt("dimLevel", dim);
  
  for (int a: areas) 
  {
    XML area = drawing.addChild("area");
    area.setInt("ID", a);
  }
  
  updateMapXML();
}

void removeDrawingFromXML(int... areas)
{
  for (XML drawing : map.getChild("drawings").getChildren())
  {    
    for (XML area : drawing.getChildren("area"))
    {
      for (int a : areas)
      { 
        if (area.getInt("ID") == a) drawing.removeChild(area);
      }
    }
    
    if (drawing.getChildren("area").length == 0) map.getChild("drawings").removeChild(drawing);
  }
  updateMapXML();
}

void updateMapXML()
{
  saveXML(map, "/data/map.xml");
}
