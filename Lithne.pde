Lithne lithne     = null;
FunctionTable ft  = null;
NodeManager nm    = null;

int tweakerCT = 0;
int tweakerDim = 0;

public final String LITHNEPORT = "COM43";

boolean lithneEnabled = false;

void setupLithne()
{

  ft = new FunctionTable();
  nm = new NodeManager();

  try
  {
    if (!lithneEnabled)
    {
      lithne = new Lithne( this, LITHNEPORT, 115200 ); 
      lithne.begin();
      lithneEnabled = true;
      traceln("Lithne ready on "+ LITHNEPORT);
    }
  }
  catch (Error e)
  {
    lithneEnabled = false;
    traceln("Lithne connect error " + e);
  }

  nm.addNode("00 13 a2 00 40 79 ce 74", "Indirect1" );    // L77
  nm.addNode("00 13 A2 00 40 89 AE 1C", "UI" );    // L16

  //pointers
  nm.addNode("00 13 A2 00 40 8B 2A 13", "PointerRed" );    // RED
  nm.addNode("00 13 A2 00 40 79 CE 42", "PointerGreen" );    // GREEN
  nm.addNode("00 13 A2 00 40 79 CE 7D", "PointerBlue" );    // BLUE
  nm.addNode("00 13 A2 00 40 79 CE AE", "PointerOrange" );    // ORANGE

  nm.addNode("00 13 A2 00 40 79 CE 32", "IndicatorRed" );    // ?
  nm.addNode("00 13 A2 00 40 79 CE AF", "IndicatorGreen" );    // ?
  nm.addNode("00 13 A2 00 40 79 CE 6A", "IndicatorOrange" );
  nm.addNode("00 13 A2 00 40 79 CE 6F", "IndicatorBlue" );

  lithne.addMessageListener( ft );
}


public class FunctionTable implements MessageListener
{
  /**
   *  This is a basic constructor, that actually does nothing.
   **/
  FunctionTable() {
  }

  /**
   *  Whenever the Lithne library receives data from the XBee, this is converted into a Message object.
   *  The library then throws an event, which basically informs all of its listeners
   **/

  public void messageEventReceived( MessageEvent event )
  {
    //log("Lithne", ( event.getMessage().fromXBeeAddress64() ).toString(), "COORDINATOR", str( event.getMessage().getFunction() ), event.getMessage().getArguments());
    //traceln("Lithne Message: "+event.getMessage().toString());
    
    
    
    if ( event.getMessage().functionIs( "error" ) )
    {
      traceln("This is an ERROR message.");
    }
    
    else if (event.getMessage().functionIs("Tobi"))
    {
      OSCclient OSCclient = getOSCclient("Tobi");

      if (event.getMessage().getNumberOfArguments() == 2)
      {
        Luminaire l = _luminaires.get(0);
        int ct = event.getMessage().getArgument(0);
        int dim = int ( map(event.getMessage().getArgument(1), 0, 255, l.getMinDimLevel(), l.getMaxDimLevel()));
        l.setCT(ct);
        l.setDimLevel(dim);
        
        OSCclient.newMessage(l);
        traceln("Tobi: " + ct + " " + dim);
      }
      else if (event.getMessage().getNumberOfArguments() > 2)
      {
        int ct = event.getMessage().getArgument(0);
        
        for (int i = 2; i<event.getMessage().getNumberOfArguments(); i++)
        {
          int lampID = event.getMessage().getArgument(i);
          Luminaire l = _luminaires.get(lampID);
          int dim = int ( map(event.getMessage().getArgument(1), 0, 255, l.getMinDimLevel(), l.getMaxDimLevel()));
          
          l.setCT(ct);
          l.setDimLevel(dim);
          
          OSCclient.newMessage(l);
          traceln("Tobi: lamp " + lampID + " = " + ct + "K " + dim);
        }
        
      }
    }
    
    else if (event.getMessage().functionIs("Tweaker"))
    {
      OSCclient OSCclient = getOSCclient("Tweaker");
      
      if (event.getMessage().getNumberOfArguments() == 2)
      {
        Luminaire l = _luminaires.get(0);
        int ct = event.getMessage().getArgument(0);
        int dim = int ( map(event.getMessage().getArgument(1), 0, 255, l.getMinDimLevel(), l.getMaxDimLevel()));
        
        if (abs(ct - tweakerCT) < 10 && abs(dim - tweakerDim) < 300) return;
        
        tweakerCT = ct;
        tweakerDim = dim;
        
        
        l = _luminaires.get(14);
        l.setCT(ct);
        l.setDimLevel(dim);
        OSCclient.newMessage(l);
        l = _luminaires.get(18);
        l.setCT(ct);
        l.setDimLevel(dim);
        OSCclient.newMessage(l);

        traceln("Tweaker: " + ct + " " + dim);
      }
      
    }

    //SASHARM
    else if (event.getMessage().functionIs("saskiaharm"))
    {
      if (event.getMessage().getNumberOfArguments() == 2)
      {        
        for (Luminaire l : _luminaires (OFFICE))
        {
          int ct = int( map(event.getMessage().getArgument(0), 0, 255, l.getMinCT(), l.getMaxCT()));
          int dim = int ( map(event.getMessage().getArgument(1), 0, 255, l.getMinDimLevel(), l.getMaxDimLevel()));

          l.setCT(ct);
          l.setDimLevel(dim);
        }
      }
    }


    ///POINTERS
    else if ( event.getMessage().functionIs("pointer") )
    {
      OSCclient OSCclient = getOSCclient("pointer");
      
      //FOR PROJECT MARKET!!
      int ct = (int) map(event.getMessage().getArgument(0), 0, 255, 1700, 8000);
      int dimLevel = (int) map(event.getMessage().getArgument(1), 0, 255, 0, 65535);

      for (Luminaire l : _luminaires (FLEX))
      {
        l.setDimLevel(dimLevel);
        l.setCT(ct);
        OSCclient.newMessage(l);
      }
      
      int value = constrain(ct, 2000, 6500);
      int cct = (int) map(value, 2000, 6500, 500, 154);
      
      for (int i = 0; i<NUM_HUE_LAMPS; i++)
      {
        _hueLamps.get(i).setDimLevel(dimLevel);
        _hueLamps.get(i).setCT(cct);
      }
      
      getLuminaireByShortAddress("0x8835").setDimLevel(dimLevel);
      
      //FOR PROJECT MARKET!!

      if (event.getMessage().getNumberOfArguments() == 2)
      {
        for (Pointer p : _pointers)
        {
          if (event.getMessage().fromXBeeAddress64().equals(p.getNode().getXBeeAddress64()))
          {
            //ENABLE FOR MULI, IT IS DISABLED FOR DEMO PURPOSES (PROJECT MARKET)
            //int ct = (int) map(event.getMessage().getArgument(0),0,255,1700,8000);
            //int dimLevel = (int) map(event.getMessage().getArgument(1),0,255,0,65535);
            //p.update(event.getMessage().getArgument(0), event.getMessage().getArgument(1));

            traceln(p.getNode().getName() + " (" + p.getID() + "): " + event.getMessage().getArgument(0) + ", " + event.getMessage().getArgument(1));
            return;
          }
        }

        traceln("Undefined pointer " + event.getMessage().fromXBeeAddress64().toString());
      }
    } else if ( event.getMessage().functionIs("receiver") )
    {
      if (event.getMessage().getNumberOfArguments() == 0)
      {
        traceln("indicator meld zich ");
      } 
      else if (event.getMessage().getNumberOfArguments() == 1)
      {
        Indicator indicator = null;

        for (Indicator i : _indicators)
        {          
          if (event.getMessage().fromXBeeAddress64().equals(i.getNode().getXBeeAddress64()))
          {
            indicator = i;

            traceln(i.getNode().getName() + " received Pointer ID " + event.getMessage().getArgument(0));

            for (Pointer p : _pointers)
            {
              if (event.getMessage().getArgument(0) == p.getID())
              {
                indicator.updateFromPointer(p);

                return;
              }
            }
          }
        }

        traceln("Undefined receiver " + event.getMessage().fromXBeeAddress64());
      }
    }

    /////////////

    /* Unknown function */
    else
    {
      String argumentString = "";
      for (int i = 0; i < event.getMessage ().getNumberOfArguments(); i++)
      {
        argumentString += event.getMessage().getArgument(i);

        if (i != event.getMessage().getNumberOfArguments()-1) 
        { 
          argumentString += ", ";
        }
      }
      traceln(
      "Received unknown function: hash " + 
        event.getMessage().getFunction() +
        " from node " +
        nm.getNodeName(event.getMessage().fromXBeeAddress64()) + 
        " (" + event.getMessage().fromXBeeAddress64() + ")" +
        " in scope " + event.getMessage().getScope() +
        " with " + event.getMessage().getNumberOfArguments() + " args: " +
        argumentString
        );
    }
  }
}

void resetAllNodes()
{
  for (int i = 0; i < nm.getNumberOfNodes (); i++)
  {
    Node n = nm.getNodeAt(i);
    if (n != null)
    {
      ili.lithne.Message updateMsg  =  new ili.lithne.Message();
      updateMsg.toXBeeAddress64( n.getXBeeAddress64() );
      updateMsg.toXBeeAddress16( n.getXBeeAddress16() );
      updateMsg.setScope( Lithne.hash("LithneUploading") );
      updateMsg.setFunction( 2 ); // reset main proc

      if ( getLithne() != null )
      {
        traceln("Resetting " + n.getName());
        getLithne().send( updateMsg );
      }
    }
  }
}

void resetNode(String name)
{
  boolean success = false;
  for (int i = 0; i < nm.getNumberOfNodes (); i++)
  {
    Node n = nm.getNodeAt(i);
    if (n != null)
    {
      if (n.getName().equals(name))
      {
        success = true;
        ili.lithne.Message updateMsg  =  new ili.lithne.Message();
        updateMsg.toXBeeAddress64( n.getXBeeAddress64() );
        updateMsg.toXBeeAddress16( n.getXBeeAddress16() );
        updateMsg.setScope( Lithne.hash("LithneUploading") );
        updateMsg.setFunction( 2 ); // reset main proc

        if ( getLithne() != null )
        {
          traceln("Resetting " + n.getName());
          getLithne().send( updateMsg );
        }
      }
    }
  }
  if (!success)
  {
    traceln("The requested node " +name+ " does not exist");
  }
}

Lithne getLithne()
{
  return lithne;
}

