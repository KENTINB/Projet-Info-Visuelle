void settings() {
  size(1000, 1000, P2D);
}
void setup () {
}
void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);

  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  //rotated around x
  float[][] transform1 = rotateXMatrix(PI/8);
  input3DBox = transformBox(input3DBox, transform1);
  projectBox(eye, input3DBox).render();
  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox).render();
  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2, 2, 2);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

// Method 1, Assignement 2, Part 1 (Step 2)
/*
projects a point in 3D in a 2D plan
*/
public My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  //Complete the code!
  float coeff = eye.z/(eye.z - p.z);
  return new My2DPoint(coeff*(p.x - eye.x), coeff*(p.y - eye.y));
}

// Method 2, Assignement 2, Part 1 (Step 3)
/*
represents a box in 2D
*/
class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  void render() {
    // Complete the code! use only line(x1, y1, x2, y2) built-in function.
    line(s[0].x, s[0].y, s[1].x, s[1].y); //1 0->1
    line(s[0].x, s[0].y, s[3].x, s[3].y); //2 0->3
    line(s[0].x, s[0].y, s[4].x, s[4].y); //3 0->4
    line(s[1].x, s[1].y, s[2].x, s[2].y); //4 1->2
    line(s[1].x, s[1].y, s[5].x, s[5].y); //5 1->5
    line(s[2].x, s[2].y, s[3].x, s[3].y); //6 2->3
    line(s[2].x, s[2].y, s[6].x, s[6].y); //7 2->6
    line(s[3].x, s[3].y, s[7].x, s[7].y); //8 3->7
    line(s[4].x, s[4].y, s[5].x, s[5].y); //9 4->5
    line(s[4].x, s[4].y, s[7].x, s[7].y); //10 4->7
    line(s[5].x, s[5].y, s[6].x, s[6].y); //11 5->6
    line(s[6].x, s[6].y, s[7].x, s[7].y); //12 6->7
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x, y+dimY, z+dimZ), 
      new My3DPoint(x, y, z+dimZ), 
      new My3DPoint(x+dimX, y, z+dimZ), 
      new My3DPoint(x+dimX, y+dimY, z+dimZ), 
      new My3DPoint(x, y+dimY, z), 
      origin, 
      new My3DPoint(x+dimX, y, z), 
      new My3DPoint(x+dimX, y+dimY, z)
    };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

// Methode 3, Assignement 2, Part 1 (Step 3)
/*
projects a 3D box in 2D plan
*/
public My2DBox projectBox (My3DPoint eye, My3DBox box) {
  // Complete the code!
  My2DPoint[] projecteds = new My2DPoint[8];
  for (int i=0; i<8; i++) {
    projecteds[i]= projectPoint(eye, box.p[i]);
  }
  return new My2DBox(projecteds);
}

public float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

// Method 4-9, Assignement 2, Part 2 (Step 2)
/*
rotates the camera around X-axis with angle 'angle'
*/
float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0, 0, 0}, 
    {0, cos(angle), sin(angle), 0}, 
    {0, -sin(angle), cos(angle), 0}, 
    {0, 0, 0, 1}});
}
/*
rotates the camera around Y-axis with angle 'angle'
*/
float[][] rotateYMatrix(float angle) {
  // Complete the code!
  return(new float[][] {{cos(angle), 0, sin(angle), 0}, 
    {0, 1, 0, 0}, 
    {-sin(angle), 0, cos(angle), 0}, 
    {0, 0, 0, 1}});
}
/*
rotates the camera around Z-axis with angle 'angle'
*/
float[][] rotateZMatrix(float angle) {
  // Complete the code!
  return(new float[][] {{cos(angle), -sin(angle), 0, 0}, 
    {sin(angle), cos(angle), 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 0, 1}});
}
/*
changes box's scale with a coefficient that can differ from one axis to another
*/
float[][] scaleMatrix(float x, float y, float z) {
  // Complete the code!
  return(new float[][] {{x, 0, 0, 0}, 
    {0, y, 0, 0}, 
    {0, 0, z, 0}, 
    {0, 0, 0, 1}});
}
/*
moves the box following a given vector representer by it's 3 coordinates
*/
float[][] translationMatrix(float x, float y, float z) {
  // Complete the code!
  return(new float[][] {{1, 0, 0, x}, 
    {0, 1, 0, y}, 
    {0, 0, 1, z}, 
    {0, 0, 0, 1}});
}

// Method 10, Assignement 2, Part 2 (Step 3)
/*
calculates the matricial product of a and b
*/
float[] matrixProduct(float[][] a, float[] b) {
  //Complete the code!
  float sum=0;
  float[] result = new float[4];
  for (int i=0; i<4; i++) {
    for (int j=0; j<4; j++) {
      sum+= a[i][j]*b[j];
    }
    result[i]=sum;
    sum=0;
  }
  return result;
}
// Method 11, Assignement 2, Part 2 (Step 3)
/*
applies the changes to My3DBox through transformMatrix with the given formula
*/
public My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  //Complete the code! You need to use the euclidian3DPoint() function given below.
  My3DPoint[] result = new My3DPoint[8];
  for (int i=0; i<8; i++) {
    result[i] = euclidian3DPoint(matrixProduct(transformMatrix, new float[]{box.p[i].x, box.p[i].y, box.p[i].z, 1}));
  }
  return new My3DBox(result);
}
/*
helper methode to transform an array of float into an euclidian 3DPoint
*/
My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}