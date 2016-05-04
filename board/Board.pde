PImage img;
int max = 0xFFFFFF;
HScrollbar thresholdBar1;
HScrollbar thresholdBar2;
int sizeKernel = 3;
float[][] kernel = { { 0, -1, 0 }, { 12, 15, 12 }, { 0, -1, 0 }};
float weight = 15.f;



void settings() {
  size(800, 600);
}
void setup() {
  img = loadImage("board1.jpg");
  noLoop();
  // no interactive behaviour: draw() will be called only once.
  thresholdBar1 = new HScrollbar(0, 0, 800, 20);
  thresholdBar2 = new HScrollbar(0, 20, 800, 20);
}
void draw() {
  background(color(0, 0, 0));
  thresholdBar1.display();
  thresholdBar1.update();
  thresholdBar2.display();
  thresholdBar2.update();
  //image(filterThreshold(img,255*thresholdBar.getPos()), 0, 20);
  //image(displayHue(img,thresholdBar1.getPos()*255,thresholdBar2.getPos()*255),0,40);
  //image(convolute(img), 0, 0);
  image(hough(sobel(img)),0,0);
}

PImage hough(PImage edgeImg) {
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  for(int i = 0; i< accumulator.length;i++){
  accumulator[i] = 0;
  }
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for (int phi = 0; phi < phiDim; phi++) {
          int r = (int)Math.round(x*cos(phi)+y*sin(phi));
          if(r<0){
          r += (rDim-1)/2;
          }   
              accumulator[phi* rDim + r] += 1;
          
          }
        
        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator with something like: r += (rDim - 1) / 2
      }
      
    }
    
  }
  for(int i = 0; i< accumulator.length;i++){
  println(accumulator[i]+", ");
  }
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
   houghImg.resize(400, 400);
  houghImg.updatePixels();
  return houghImg;
}

PImage filterThreshold(PImage img, float threshold) {
  PImage result = createImage(width, height, RGB);
  // create a new, initially transparent, 'result' image
  for (int i = 0; i < img.width * img.height; i++) {
    // do something with the pixel img.pixels[i]
    if (brightness(img.pixels[i]) > threshold) {
      result.pixels[i] = max;
    } else {
      result.pixels[i] = 0;
    }
  }
  return result;
}

PImage filterThresholdInverted(PImage img, int threshold) {
  PImage result = createImage(width, height, RGB);
  // create a new, initially transparent, 'result' image
  for (int i = 0; i < img.width * img.height; i++) {
    // do something with the pixel img.pixels[i]
    if (brightness(img.pixels[i]) < threshold) {
      result.pixels[i] = max;
    } else {
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

PImage displayHue(PImage img, float max, float min) {
  PImage result = createImage(width, height, RGB);
  // create a new, initially transparent, 'result' image
  for (int i = 0; i < img.width * img.height; i++) {
    // do something with the pixel img.pixels[i]
    if ((int)hue(img.pixels[i])> min && (int)hue(img.pixels[i])< max) {
      result.pixels[i] = img.pixels[i];
    } else {
      result.pixels[i] = color(0);
    }
  }
  return result;
}


int getPos(PImage img, int x, int y) {
  return img.pixels[x+y*img.width];
}

PImage convolute(PImage img) {
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  // kernel size N = 3
  int sum =0;
  for (int y = 2; y < img.height - 2; y++) {
    // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) {
      // Skip left and right
      for (int k =0; k<sizeKernel; k++) {
        for (int j =0; j<sizeKernel; j++) {
          sum +=brightness((int)(kernel[k][j]*(getPos(img, x+k-sizeKernel/2, y+j-sizeKernel/2))));
        }
      }
      result.pixels[x+y*img.width] = color((int)(sum/weight));
      sum = 0;
    }
  }


  // for each (x,y) pixel in the image:
  //     - multiply intensities for pixels in the range
  //       (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  //       corresponding weights in the kernel matrix
  //     - sum all these intensities and divide it by the weight
  //     - set result.pixels[y * img.width + x] to this value
  return result;
}

PImage sobel(PImage img) {
  float[][] hKernel = { { 0, 1, 0  }, 
    { 0, 0, 0 }, 
    { 0, -1, 0 } };
  float[][] vKernel = { { 0, 0, 0  }, 
    { 1, 0, -1 }, 
    { 0, 0, 0  } };
  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[img.width * img.height];
  // *************************************
  // Implement here the double convolution
  // *************************************

  int sumh =0;
  int sumv =0;
  for (int y = 2; y < img.height - 2; y++) {
    // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) {
      // Skip left and right
      sumh += hKernel[2][1]*color(getPos(img, x+1, y));
      sumh += hKernel[0][1]*color(getPos(img, x-1, y));
      sumv += vKernel[1][2]*color(getPos(img, x, y+1));
      sumv += vKernel[1][0]*color(getPos(img, x, y-1));
      float sum=sqrt(pow(sumh, 2) + pow(sumv, 2));
      if (max<sum) {
        max = sum;
      }
      sumv =0; 
      sumh =0;
      buffer[x+y*img.width] = sum;
    }
  }

  for (int y = 2; y < img.height - 2; y++) {
    // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) {
      // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) {
        // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}