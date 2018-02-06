public class Interface
{
  protected Node _node =  new Node();
  float w, h, x, y;
  
  public Interface()
  {
  }
  
  public Node getNode()
  {
    return this._node;
  }
  
  public void setNode( Node node )
  {
    this._node  =  node;
  }
  
  public void draw()
  {
  }
}
