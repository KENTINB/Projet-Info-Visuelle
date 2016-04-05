//added elasticCoeff on square sides //<>//
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
float gravityConstant = 2.0;
float mu = 0.2;
float frictionMagnitude = mu * normalForce;
PFont f;
PVector location;
PVector velocity;
Mover mover;

//assignement5
float cylinderBaseSize = 50;
float cylinderHeight = 50;
int cylinderResolution = 40;
PShape openCylinder = new PShape();
PShape topnBottom = new PShape();
ArrayList<PVector> objects = new ArrayList();

//assignement 6
PGraphics mySurface;
PGraphics myGame;
PGraphics minimap;
int minimapSide = 135;
float ratio = minimapSide/side;
float miniRadius = radius*ratio;
float miniCylinderSize = cylinderBaseSize*ratio;

public void settings() {
  size(200, 200, P3D);
}

public void setup() {
  mySurface = createGraphics(4000, 700, P2D);
  minimap = createGraphics(minimapSide, minimapSide, P2D);
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
  mySurface.background(200);
  mySurface.endDraw();
}

//assignement 6
void drawMinimap(){
minimap.beginDraw();
pushMatrix();

minimap.translate(minimapSide/2, minimapSide/2);

minimap.background(255, 0, 0, 50);
if(!objects.isEmpty()){
fill(0);
for(PVector o:objects){minimap.ellipse((o.x-width/2)*ratio,(o.y-height/2)*ratio,miniCylinderSize,miniCylinderSize);
}

}
popMatrix();
minimap.endDraw();
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
    text("angleX: " + angleX + "\nangleZ: " + angleZ+ "\nvitesse:"+ con + "\nvitesse:"+velocity + "\nlocation:"+location, -width/2+60, -height/2+40, 40);    
    pushMatrix();
    rotateX(angleX);
    rotateZ(angleZ);
    fill(0, 204, 204);
    displayCyl();
    fill(255, 0, 0, 63);
    box(side, thickness, side);
    fill(0, 204, 204);

    mover.update();
    mover.checkEdges();
    mover.checkCylinderCollision(objects);
    mover.display();
    popMatrix();
  }
}

public void draw() {
  drawMyGame();
  
  //assignement 6
  drawMySurface();
  image(mySurface, -width, height/3 );
  translate(0,0,10);
  drawMinimap();
  image(minimap, -width/2 +25, height/3 +10);
}

// assignement3: Change the speed of the box.
public void mouseWheel(MouseEvent event) {
  float e = event.getCount();     
  if (e < 0) con = clamp( con*1.05f, 0.2f, 2f);
  else con = clamp( con*0.95f, 0.2f, 2f);
}

// assignement3: Change the orientation of the box.
public void mouseDragged() {
  float dZ = (mouseX - pmouseX);
  float dX = (mouseY - pmouseY);
  if (dX < -1) {
    angleX= clamp(angleX+con*PI/48, -PI/3, PI/3);
  } else if (dX > 1) {
    angleX= clamp(angleX-con*PI/48, -PI/3, PI/3);
  }
  if (dZ > 1) {
    angleZ= clamp(angleZ+con*PI/48, -PI/3, PI/3);
  } else if (dZ < -1) {
    angleZ= clamp(angleZ-con*PI/48, -PI/3, PI/3);
  }
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
      velocity.x = -velocity.x*elasticCoeff;
      location.x=side/2 - radius ;
    } else if (location.x < -side/2.0 + radius ) {
      velocity.x = -velocity.x*elasticCoeff;
      location.x=-side/2 + radius;
    }
    if (location.z > side/2.0 - radius) {
      velocity.z = -velocity.z*elasticCoeff;
      location.z=side/2 - radius;
    } else if (location.z < -side/2.0+ radius) {
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