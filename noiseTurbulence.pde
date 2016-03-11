/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/143842*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
//Raven Kwok aka Guo, Ruiwen
//ravenkwok.com
//vimeo.com/ravenkwok
//flickr.com/photos/ravenkwok
import java.util.Map;
import java.util.Iterator;

import SimpleOpenNI.*;

SimpleOpenNI context;


  color[]  colors = new color[]{color(201,255,151),
                              color(114,127,102),
                              color(102,127,137),
                              color(127,121,46),
                              color(204,194,73),
                              color(127,121,107),
                              color(255,200,68),
                              color(6,127,53),
                              color(79,127,98),
                              color(34,204,64),
                              
                              };                                 
  boolean noTracking=true;
  
  PVector p2d;
  
  int handVecListSize = 20;
Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };


ArrayList<Particle> pts;
boolean onPressed, showInstruction;
PFont f;
PImage [] images = new PImage [7];
PImage photo;

float r,g,b;

void setup() {
  size(displayWidth, displayHeight, P2D);
  smooth();
  frameRate(60);
  colorMode(RGB);
  rectMode(CENTER);

  images = new PImage [5];
  pts = new ArrayList<Particle>();
  images[0]= loadImage("1.jpg");
  images[0].resize(displayWidth, displayHeight);
  
  images[1]= loadImage("3.jpg");
  images[1].resize(displayWidth, displayHeight);
  images[2]= loadImage("4.jpg");
  images[2].resize(displayWidth, displayHeight);
  images[3]= loadImage("5.png");
  images[3].resize(displayWidth, displayHeight);
  
  images[4]= loadImage("7.png");
  images[4].resize(displayWidth, displayHeight);
  
  photo= images [int(random(0,4))];
  
  showInstruction = true;
  f = createFont("Calibri", 24, true);

  background(255);
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  } 
  
   context.enableDepth();
  

  context.setMirror(true);

  
  context.enableHand();
  
 
  context.startGesture(SimpleOpenNI.GESTURE_CLICK);
   context.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE);
  // context.startGesture(SimpleOpenNI.GESTURE_WAVE);
   
  
}

void draw() {
  
   
   
  if (showInstruction) {
    background(255);
    fill(128);
    textAlign(CENTER, CENTER);
    textFont(f);
    textLeading(36);
    text("Drag and draw." + "\n" +
      "Press 'c' to clear the stage." + "\n"
      , width*0.5, height*0.5);
  }
 
  
  context.update();
  
  if(handPathList.size() > 0)  
  {    
    Iterator itr = handPathList.entrySet().iterator();     
    while(itr.hasNext())
    {
      Map.Entry mapEntry = (Map.Entry)itr.next(); 
      int handId =  (Integer)mapEntry.getKey();
      println("handId", handId);
      ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
      PVector p;
       p2d = new PVector();
      
        stroke(userClr[ (handId - 1) % userClr.length ]);
        noFill(); 
        strokeWeight(1);        
        /*Iterator itrVec = vecList.iterator(); 
        beginShape();
          while( itrVec.hasNext() ) 
          { 
            p = (PVector) itrVec.next(); 
            
            context.convertRealWorldToProjective(p,p2d);
            vertex(p2d.x*(width/640),p2d.y*(height/320));
          }
        endShape();  */ 
  
        stroke(userClr[ (handId - 1) % userClr.length ]);
        strokeWeight(4);
        p = vecList.get(0);
        context.convertRealWorldToProjective(p,p2d);
        //point(p2d.x*(width/640),p2d.y*(height/320));
        photo.loadPixels();
         // image(handL,p2d.x*(width/640),p2d.y*(height/480));
          for (int i=0;i<10;i++) {
          int loc=int(constrain((p2d.x*(width/640))+(p2d.y*(height/320))*photo.width,0,photo.width*photo.height-1));
          Particle newP = new Particle((p2d.x*(width/640)), (p2d.y*(height/320)), i+pts.size(), i+pts.size());
           r = red(photo.pixels[loc]);
           g = green(photo.pixels[loc]);
            b = blue(photo.pixels[loc]);
            newP.setColor(r,g,b);
            pts.add(newP);
    }
        
 
    }        
  }
  
 
  for (int i=0; i<pts.size(); i++) {
    Particle p = pts.get(i);
    int loc2=int(p.loc.x)+int(p.loc.y)*width;
    loc2=constrain(loc2,0,width*height-1);
    //if (brightness(zebra.pixels[loc2])<250){
       float r = red(photo.pixels[loc2]);
       float g = green(photo.pixels[loc2]);
       float b = blue(photo.pixels[loc2]);
       p.setColor(r,g,b);
      p.update();
      p.display();
  }

  for (int i=pts.size()-1; i>-1; i--) {
    Particle p = pts.get(i);
    if (p.dead) {
      pts.remove(i);
    }
  }
}

void mousePressed() {
  onPressed = true;
  if (showInstruction) {
    background(255);
    showInstruction = false;
  }
}

void mouseReleased() {
  onPressed = false;
}

void keyPressed() {
  if (key == 'c') {
    for (int i=pts.size()-1; i>-1; i--) {
      Particle p = pts.get(i);
      pts.remove(i);
    }
    background(255);
  }
  
  if (keyCode==32) {
  
saveFrame("ParticleDraw####.jpg");
}
}

class Particle{
  PVector loc, vel, acc;
  int lifeSpan, passedLife;
  boolean dead;
  float alpha, weight, weightRange, decay, xOffset, yOffset;
  color c;
  
  Particle(float x, float y, float xOffset, float yOffset){
    loc = new PVector(x,y);
    
    float randDegrees = random(360);
    vel = new PVector(cos(radians(randDegrees)), sin(radians(randDegrees)));
    vel.mult(random(5));
    
    acc = new PVector(0,0);
    lifeSpan = int(random(30, 90));
    decay = random(0.75, 0.9);
    //c = color(random(255),random(255),255);
    weightRange = random(3,50);
    
    this.xOffset = xOffset;
    this.yOffset = yOffset;
  }
  
  void update(){
    if(passedLife>=lifeSpan){
      dead = true;
    }else{
      passedLife++;
    }
    
    alpha = float(lifeSpan-passedLife)/lifeSpan * 70+50;
    weight = float(lifeSpan-passedLife)/lifeSpan * weightRange;
    
    acc.set(0,0);
    
    float rn = (noise((loc.x+frameCount+xOffset)*0.01, (loc.y+frameCount+yOffset)*0.01)-0.5)*4*PI;
    float mag = noise((loc.y+frameCount)*0.01, (loc.x+frameCount)*0.01);
    PVector dir = new PVector(cos(rn),sin(rn));
    acc.add(dir);
    acc.mult(mag);
    
    float randDegrees = random(360);
    PVector randV = new PVector(cos(radians(randDegrees)), sin(radians(randDegrees)));
    randV.mult(0.5);
    acc.add(randV);
    
    vel.add(acc);
    vel.mult(decay);
    vel.limit(3);
    loc.add(vel);
  }
  
  void setColor(float r, float g, float b){
  
  c=color(r,g,b);
  }
  
  void display(){
    
    strokeWeight(weight+1);
    stroke(0, alpha);
    point(loc.x, loc.y);
    
    strokeWeight(weight);
    stroke(c);
    point(loc.x, loc.y);
  }
}


void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);
 
  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);
  
  handPathList.put(handId,vecList);
}

void onTrackedHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );
  
  ArrayList<PVector> vecList = handPathList.get(handId);
  if(vecList != null)
  {
    vecList.add(0,pos);
    if(vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1); 
  }  
}

void onLostHand(SimpleOpenNI curContext,int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos)
{

   if(gestureType== SimpleOpenNI.GESTURE_HAND_RAISE){
     
    println("onCompletedGesture - HANDRAISE" + gestureType + ", pos: " + pos);
    int handId = context.startTrackingHand(pos);
    println("hand stracked: " + handId);
   if (showInstruction) {
    background(255);
    showInstruction = false;
  }
   } 
   
  
  if(gestureType== SimpleOpenNI.GESTURE_CLICK){
     
    println("onCompletedGesture - WAVE" + gestureType + ", pos: " + pos);
    for (int i=pts.size()-1; i>-1; i--) {
      Particle p = pts.get(i);
      pts.remove(i);
    }
    background(255);
     photo= images [int(random(0,4))];
    
  }   
 
}
