import ddf.minim.*;

Minim minim;
AudioPlayer pop, alarm;

int soundInterval = 1000;
long lastSound = 0;

void setupSound()
{  
  minim = new Minim(this);
  pop = minim.loadFile("C:/Program Files (x86)/Workrave/share/sounds/default/micro-break-ended.wav");
  alarm = minim.loadFile("C:/Program Files (x86)/Workrave/share/sounds/default/break-ignored.wav");
}

void playAlarm()
{
  if (millis() > 10000)
  {
    //PLAY A SOUND
    if (millis() - lastSound > soundInterval)
    {
      lastSound = millis();
      alarm.rewind();
      alarm.play();
    }
  }
}

