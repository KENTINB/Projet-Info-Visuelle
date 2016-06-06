import java.util.concurrent.LinkedBlockingQueue; //<>//
PVector rot;


//added elasticCoeff on square sides
float elasticCoeff = 0.85;

//assignement4
PVector gravityForce;
PVector friction;
float normalForce = 1.0;
float angleX = 0.0;
float angleZ = 0.0;
float con = 1.0;
float radius = 15.0;
float thickness = 25.0;
float side = 400.0;
float gravityConstant = 2*9.81/frameRate;
float mu = 0.2;
float frictionMagnitude = mu * normalForce;
PFont f;
PVector location;
PVector velocity;
Mover mover;

//assignement5
float cylinderBaseSize = 40;
float cylinderHeight = 50;
int cylinderResolution = 40;
PShape openCylinder = new PShape();
PShape topnBottom = new PShape();
ArrayList<PVector> objects = new ArrayList();

//assignement 6
PGraphics mySurface;
PGraphics myGame;
PGraphics minimap;
PGraphics myScore;
PGraphics scoreGraph;

int minimapSide = 100;
int scoreSize = 100;
float ratio = minimapSide/side;
float miniRadius = radius*ratio;
float miniCylinderSize = cylinderBaseSize*ratio;
int tailSize = 30;
LinkedBlockingQueue<PVector> trace = new LinkedBlockingQueue<PVector>(tailSize);
Float totalScore = 0.0;
float lastScore = 0.0;
float deltaScore = 1.5;
HScrollbar hs;
float positionHUD = height/3;
float maxScore = 1000000;
int maxScoreSize = 10;
ArrayList<Integer> graphInfo = new ArrayList<Integer>();
float playerMax = 1;
int counter = 0;
int graphWidth =1400;
int graphHeight = 100;
float deltaGraph = 0;
ImageProcessing imgproc;

public void settings() {
  size(200, 200, P3D);
}

public void setup() {
  

  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);


  
  scoreGraph = createGraphics(graphWidth, graphHeight, P2D);
  mySurface = createGraphics(2000, 700, P2D);
  minimap = createGraphics(minimapSide, minimapSide, P2D);
  myScore= createGraphics(scoreSize, scoreSize, P2D);
  hs = new HScrollbar(-150, 460, 300, 20);
  noStroke();
  f = createFont("Arial Bold", 16, true);
  mover = new Mover();

  //enable opacity
  hint(ENABLE_DEPTH_TEST);
  hint(ENABLE_DEPTH_SORT);

  //assignement5: Dzfinition of the cylindre.
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] z = new float[cylinderResolution + 1];

  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    z[i] = cos(angle) * cylinderBaseSize;
  }
  openCylinder = createShape();
  topnBottom = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], -(thickness/2), z[i]);
    openCylinder.vertex(x[i], -(cylinderHeight+thickness/2), z[i]);
  }
  openCylinder.endShape(QUAD_STRIP);

  topnBottom.beginShape(TRIANGLES);
  for (int i = 0; i < x.length; i++) {
    topnBottom.vertex(0, -(thickness/2), 0);
    topnBottom.vertex(x[i], -(thickness/2), z[i]);
    topnBottom.vertex(x[(i+1)%x.length], -(thickness/2), z[(i+1)%x.length]);

    topnBottom.vertex(0, -(cylinderHeight+thickness/2), 0);
    topnBottom.vertex(x[i], -(cylinderHeight+thickness/2), z[i]);
    topnBottom.vertex(x[(i+1)%x.length], -(cylinderHeight+thickness/2), z[(i+1)%x.length]);
  }
  topnBottom.endShape(TRIANGLES);
}

//assignement 6
void drawMySurface() {
  mySurface.beginDraw();
  mySurface.background(230);
  mySurface.endDraw();
}
//assignement 6
void drawScoreGraph() {
  float size = maxScoreSize*hs.getPos();
  scoreGraph.beginDraw();
  scoreGraph.background(0, 255, 255);
  counter++;
  if (counter >= 30) {
    counter = 0;
    if (mouseY-height/2<positionHUD) { 
      graphInfo.add(((int)Math.round(totalScore)));
    }
    playerMax = (totalScore < playerMax)? playerMax : totalScore;
  }
  for (int i = 0; i < graphInfo.size(); i++) {
    int y = graphInfo.get(i);
    scoreGraph.rect(i*size, graphHeight-(y/playerMax*graphHeight) + deltaGraph, size, y!=0? y/playerMax*graphHeight-deltaGraph : 0);
  }
  scoreGraph.endDraw();
}
//assignement 6
void drawMinimap() {
  minimap.beginDraw();
  pushMatrix();

  minimap.translate(minimapSide/2, minimapSide/2);

  minimap.background(200, 0, 0);
  minimap.stroke(10);
  if (!objects.isEmpty()) {
    minimap.fill(255, 255, 255);
    for (PVector o : objects) {
      minimap.ellipse((o.x-width/2)*ratio, (o.y-height/2)*ratio, miniCylinderSize*2, miniCylinderSize*2);
    }
  }
  if (mouseY-height/2<positionHUD) {

    if (trace.remainingCapacity()==0) {
      trace.poll();
    }
  }
  trace.offer(new PVector((location.x)*ratio, (location.z)*ratio));
  minimap.fill(0, 255, 255);
  minimap.ellipse((location.x)*ratio, (location.z)*ratio, miniRadius*2, miniRadius*2);
  minimap.fill(0, 255, 255, 150);
  minimap.noStroke();
  for (PVector p : trace) {
    minimap.ellipse(p.x, p.y, miniRadius*2, miniRadius*2);
  }


  popMatrix();
  minimap.endDraw();
}


void drawScore() {
  myScore.beginDraw();
  myScore.background(255);
  myScore.textFont(f, 16);
  myScore.textSize(10);
  myScore.fill(50);
  myScore.text("Total Score:\n" + totalScore + "\nvelocity: \n" + velocity.mag() + "\nLast Score: \n"+ lastScore, 10, 10);   
  myScore.endDraw();
}

void drawScrollBar() {
  if (mouseY-height/2>positionHUD) { 
    hs.update();
  }
  hs.display();
}


void drawMyGame() {
  //asignement5: Shift Mode
  if (keyCode == 16 && keyPressed ) {

    float mousex = mouseX - width/2;
    float mousey = mouseY - height/2;

    background(200);
    directionalLight(126, 126, 126, 0, 0, -1);
    ambientLight(102, 102, 102);
    translate(width / 2, height / 2, 0);
    rotateX(-PI/2);
    fill(255, 0, 0, 63);
    box(side, thickness, side);
    fill(0, 240, 240, 255);
    pushMatrix();
    translate(location.x, 0, location.z);
    sphere(radius); 
    popMatrix();
    pushMatrix();
    translate(mousex, 0, mousey);
    shape(openCylinder);
    shape(topnBottom);

    if (mousePressed && (mousex) < (cylinderBaseSize+side/2) &&  mousex > -cylinderBaseSize-side/2 && mousey > -cylinderBaseSize-side/2 && ((mousey) < (cylinderBaseSize+side/2))) {
      objects.add(new PVector(mouseX, mouseY));
    }
    popMatrix();
    displayCyl();
  } else { 

    //assignement4: Drawing of the plate and the sphere.
    background(200);
    directionalLight(126, 126, 126, 0, 0, -1);
    ambientLight(102, 102, 102);
    translate(width / 2, height / 2, 0);

    textFont(f, 16);
    fill(0);
    text("angleX: " + angleX + "\nangleZ: " + angleZ+ "\nvitesse:"+ con + "\nvelocity:"+velocity + "\nlocation:"+location, -width/2+60, -height/2+40, 40);    
    pushMatrix();
    rotateX(angleX);
    rotateZ(angleZ);
    fill(0, 204, 204);
    displayCyl();
    fill(255, 0, 0, 63);
    box(side, thickness, side);
    fill(0, 204, 204);

    if (mouseY-height/2<positionHUD) {
      mover.update();
    }

    mover.checkEdges();
    mover.checkCylinderCollision(objects);
    mover.display();
    popMatrix();
  }
}


public void draw() {
   rot = imgproc.getRotation();
  
  if( rot != null){
  angleX = rot.x;
  angleZ = rot.y;
}

  //assignement 6
  positionHUD = height/3;
  drawMyGame();
  drawScrollBar();
  drawScoreGraph();
  image(scoreGraph, -width/2 + 75 + minimapSide+scoreSize, positionHUD + 15 );
  drawMinimap();
  image(minimap, -width/2 +25, positionHUD +15);
  drawScore();
  image(myScore, -width/2+50+minimapSide, positionHUD+15);
  translate(0, 0, -2);
  drawMySurface();
  image(mySurface, -width/2, positionHUD);
}


// helper function, that put the value x in the interval min-max.
private float clamp(float x, float min, float max) {
  if (x>max) {
    return max;
  } else if (x<min) {
    return min;
  }
  return x;
}

// assignement5: Draw every cylinder in the ArraList objects.
private void displayCyl() {
  for (int i = 0; i<objects.size(); i++) {
    float positionX= objects.get(i).x - width/2;
    float positionY= objects.get(i).y - height/2;

    pushMatrix();
    translate(positionX, 0, positionY);
    shape(openCylinder);
    shape(topnBottom);
    popMatrix();
  }
}


// Class mover to describe the movement of the sphere by keeping track of his location and speed.
class Mover {
  Mover() {
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
  }

  // assignement4: Update the velocity and location according to the gravity and the friction of the box.
  void update() {
    gravityForce = new PVector(sin(angleZ)*gravityConstant, 0, -sin(angleX)*gravityConstant);
    friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    velocity.add(friction);
    velocity.add(gravityForce);
    location.add(velocity);
  }

  //assignement4: Draw the sphere.
  void display() {
    noStroke();
    strokeWeight(2);
    translate(location.x, -(thickness/2 + radius), location.z);
    sphere(radius);
  }

  // assignement4: Update location and velocity if necessary - the ball hit a edge of the box.
  void checkEdges() {
    if (location.x > side/2.0 -radius) {
      if (abs(location.x - (side/2-radius)) > deltaScore) {
        lastScore = -velocity.mag(); 
        totalScore = clamp(totalScore-velocity.mag(), 0, maxScore);
      }
      velocity.x = -velocity.x*elasticCoeff;
      location.x=side/2 - radius ;
    } else if (location.x < -side/2.0 + radius ) {
      if (abs(location.x - (-side/2+radius)) > deltaScore) {
        lastScore = -velocity.mag(); 
        totalScore = clamp(totalScore-velocity.mag(), 0, maxScore);
      }
      velocity.x = -velocity.x*elasticCoeff;
      location.x=-side/2 + radius;
    }
    if (location.z > side/2.0 - radius) {
      if (abs(location.z - (side/2-radius)) > deltaScore) {
        lastScore = -velocity.mag(); 
        totalScore = clamp(totalScore-velocity.mag(), 0, maxScore);
      }
      velocity.z = -velocity.z*elasticCoeff;
      location.z=side/2 - radius;
    } else if (location.z < -side/2.0+ radius) {
      if (abs(location.z - (-side/2+radius)) > deltaScore) {
        lastScore = -velocity.mag(); 
        totalScore = clamp(totalScore-velocity.mag(), 0, maxScore);
      }
      velocity.z = -velocity.z*elasticCoeff;
      location.z=-side/2 + radius;
    }
  } 

  // assignement5: Check for cylinder collision in an ArrayList passed in parameters. 
  void checkCylinderCollision(ArrayList<PVector> obj) {
    for (int i = 0; i< obj.size(); i++) {
      PVector n = (new PVector(location.x, 0, location.z)).sub(new PVector(obj.get(i).x -width/2, 0, obj.get(i).y-height/2));
      PVector n2 = n.copy();

      if (sqrt(n.x*n.x+n.z*n.z)< cylinderBaseSize+radius) {
        PVector velocityBefore = new PVector(velocity.x, 0, velocity.z);
        velocity = velocityBefore.sub(n.normalize().mult(2.0f*velocityBefore.dot(n.normalize())));

        /*1st Method for the calculation of the location:*/
        float temp = sqrt((n2.z*n2.z)+(n2.x*n2.x));
        location = new PVector(n2.x/temp*(cylinderBaseSize+radius)+obj.get(i).x-width/2, 0, n2.z/temp*(cylinderBaseSize+radius)+obj.get(i).y-height/2);
        totalScore = clamp(totalScore+velocity.mag(), 0, maxScore);
        lastScore = velocity.mag();

        /* 2nd Method for the calculation of the location:
         if(n.z>0 && n.x >0){ angle = PI + atan(n.z/n.x);}
         else if (n.z>0 && n.x < 0){ angle =  - atan(abs(n.z)/abs(n.x));}
         else if (n.z<0 && n.x < 0){ angle = atan(abs(n.z)/abs(n.x));}
         else if (n.z<0 && n.x > 0){ angle = PI -atan(abs(n.z)/abs(n.x));}
         else angle = 0;
         location = new PVector((cylinderBaseSize+radius+1)*cos(angle)+obj.get(i).x-width/2,0,(cylinderBaseSize+radius+1)*sin(angle)+obj.get(i).y-height/2);
         */
      }
    }
  }
}