float angleX = 0;
float angleZ = 0;
void settings() {
size(500, 500, P3D);
}
void setup() {
noStroke();
}
void draw() {
  background(200);
lights();
camera(0, 0, 450, 250, 250, 0, 0, 1, 0);
translate(width/2,height/2,0);
rotateX(angleX);
rotateY(angleZ);
box(200,20,200);
}
void mouseDragged(){
  float dX = (mouseX - pmouseX);
  float dZ = (mouseY - pmouseY);
if(dX>1.0){
angleX+=PI/10;
}
else if(dX<-1.0){
angleX-=PI/10;
}
else if(dZ>1.0){
angleZ+=PI/10;
}else if(dZ<-1.0){
angleZ-=PI/10;
}
}