PImage img;
int max = 0xFFFFFF;
HScrollbar thresholdBar1;
HScrollbar thresholdBar2;
int sizeKernel = 3;


void settings() {
size(800, 600);
}
void setup() {
img = loadImage("board1.jpg");
//noLoop();
// no interactive behaviour: draw() will be called only once.
thresholdBar1 = new HScrollbar(0, 0, 800, 20);
thresholdBar2 = new HScrollbar(0, 20, 800, 20);
}
void draw() {
background(color(0,0,0));
thresholdBar1.display();
thresholdBar1.update();
thresholdBar2.display();
thresholdBar2.update();
//image(filterThreshold(img,255*thresholdBar.getPos()), 0, 20);
image(displayHue(img,thresholdBar1.getPos()*255,thresholdBar2.getPos()*255),0,40);

}

PImage filterThreshold(PImage img,float threshold){
PImage result = createImage(width, height, RGB);
// create a new, initially transparent, 'result' image
for(int i = 0; i < img.width * img.height; i++) {
// do something with the pixel img.pixels[i]
      if(brightness(img.pixels[i]) > threshold){
            result.pixels[i] = max;
      }else{
            result.pixels[i] = 0;
      }
}
return result;
}

PImage filterThresholdInverted(PImage img,int threshold){
PImage result = createImage(width, height, RGB);
// create a new, initially transparent, 'result' image
for(int i = 0; i < img.width * img.height; i++) {
// do something with the pixel img.pixels[i]
      if(brightness(img.pixels[i]) < threshold){
            result.pixels[i] = max;
      }else{
            result.pixels[i] = 0;
      }
}
return result;
}

private float clamp(float x, float min, float max) {
  if (x>max) {
    return max;
  } else if (x<min) {
    return min;
  }
  return x;
}

PImage displayHue(PImage img, float max, float min){
  PImage result = createImage(width, height, RGB);
// create a new, initially transparent, 'result' image
for(int i = 0; i < img.width * img.height; i++) {
// do something with the pixel img.pixels[i]
       if((int)hue(img.pixels[i])> min && (int)hue(img.pixels[i])< max){
       result.pixels[i] = img.pixels[i];
}else{result.pixels[i] = color(0);
}
}
return result;
}


int getPos(PImage img, int x,int y){
   return img[x+y*img.width];
}

PImage convolute(PImage img) {
float[][] kernel = { { 0, 0, 0 },{ 0, 2, 0 },{ 0, 0, 0 }};
float weight = 1.f;
// create a greyscale image (type: ALPHA) for output
PImage result = createImage(img.width, img.height, ALPHA);
// kernel size N = 3
  int sum =0;
  for(int i = 0; i < img.width * img.height; i++) {
     for(int x =0; x<sizeKernel; x++){
        for(int y =0; y<sizeKernel;y++){
            tempX = x-sizeKernel/2;
            tempY = y-sizeKernel/2;
            if(tempX>0 && tempY>0){sum += kernel[x][y]*getPos(img,x,y);}
        }
     }
     result.pixels[i] = sum;
     sum = 0;
  }


// for each (x,y) pixel in the image:
//     - multiply intensities for pixels in the range
//       (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
//       corresponding weights in the kernel matrix
//     - sum all these intensities and divide it by the weight
//     - set result.pixels[y * img.width + x] to this value
return result;
}