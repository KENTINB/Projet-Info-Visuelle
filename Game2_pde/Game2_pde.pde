/**added elasticCoeff on square sides //<>//
 *
 */
float elasticCoeff = 0.9;
PVector gravityForce;
PVector friction;
float normalForce = 1.0;
float angleX = 0.0;
float angleZ = 0.0;
float con = 1.0;
float radius = 25.0;
float thickness = 25.0;
float side = 500.0;
float gravityConstant = 4.0;
float mu = 0.2;
float frictionMagnitude = mu * normalForce;
PFont f;
Mover mover;
public void settings() {
  size(200, 200, P3D);
}

public void setup() {
  noStroke();
  f = createFont("Arial Bold", 16, true);
  mover = new Mover();
}


public void draw() {
  background(200);
  directionalLight(126, 126, 126, 0, 0, -1);
  ambientLight(102, 102, 102);
  translate(width / 2, height / 2, 0);

  textFont(f, 16);
  fill(0);
  text("angleX: " + angleX + "\nangleZ: " + angleZ+ "\nvitesse:"+ con, -width/2+60, -height/2+40, 40);

  //camera(0, height / 2, width / 2, 0, 0, 0, 0, 1, 1);

  rotateX(angleX);
  rotateZ(angleZ);
  fill(0, 204, 204);

  box(side, thickness, side);

  mover.update();
  mover.checkEdges();
  mover.display();
}

public void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  //Signe?
  if (e < 0) con = clamp( con*1.05f, 0.2f, 2f);
  else con = clamp( con*0.95f, 0.2f, 2f);
}

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
private float clamp(float x, float min, float max) {
  if (x>max) {
    return max;
  } else if (x<min) {
    return min;
  }
  return x;
}

class Mover {
  PVector location;
  PVector velocity;
  Mover() {
    location = new PVector(width/2, height/2);
    velocity = new PVector(1, 0, 1);
  }
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
  void display() {
    noStroke();
    strokeWeight(2);
    translate(location.x, -(thickness/2 + radius), location.z);
    
    sphere(radius);
  }
  void checkEdges() {
    if (location.x > side/2) {
      velocity.x = -velocity.x;
      location.x=side/2;
    } else if (location.x < -side/2) {
      velocity.x = -velocity.x;
      location.x=-side/2;
    }
    if (location.z > side/2) {
      velocity.z = -velocity.z;
      location.z=side/2;
    } else if (location.z < -side/2) {
      velocity.z = -velocity.z;
      location.z=-side/2;
    }
  }
}