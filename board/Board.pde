import processing.video.*;
import java.util.Collections;

Capture cam;

PImage img;
int max = 0xFFFFFF;
HScrollbar thresholdBar1;
HScrollbar thresholdBar2;
int sizeKernel = 3;
float[][] kernel = { { 0, -1, 0 }, { 12, 15, 12 }, { 0, -1, 0 }};
float weight = 15.f;
int thresholdAcc = 150;

// size of the region we search for a local maximum
int neighbourhood = 10;
// only search around lines with more that this amount of votes
// (to be adapted to your image)
int minVotes = 150;

void settings() {
  size(640, 480);
}
void setup() {
  img = loadImage("board1.jpg");
  //noLoop();
  // no interactive behaviour: draw() will be called only once.
  thresholdBar1 = new HScrollbar(0, 0, 800, 20);
  thresholdBar2 = new HScrollbar(0, 20, 800, 20);

  //Assignement 9 Camera
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
}
void draw() {
  background(color(0, 0, 0));
  //thresholdBar1.display();
  //thresholdBar1.update();
  //thresholdBar2.display();
  //thresholdBar2.update();
  //image(filterThreshold(img,255*thresholdBar.getPos()), 0, 20);
  //image(displayHue(img,thresholdBar1.getPos()*255,thresholdBar2.getPos()*255),0,40);
  //image(convolute(img), 0, 0);
  //image(img, 0, 0);  
  //hough(sobel(img));
  //image(hough(sobel(img)),0,0);

  //Assignement 9 Camera
  if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();
  image(img, 0, 0);
  getIntersections(hough(sobel(displayHue(img, 60, 140)), 50));
}

//Assignement 9
ArrayList<PVector> hough(PImage edgeImg, int nLines) {
  ArrayList<PVector> res = new ArrayList<PVector>();
  ArrayList<Integer> bestCandidates = new ArrayList();
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  int halfRAxisSize = rDim >>> 1;
  int maxRadius = (int)Math.ceil(Math.hypot(width, height));

  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  double[] sinTable = new double[phiDim];
  double[] cosTable = new double[phiDim];
  for (int theta = phiDim - 1; theta >= 0; theta--)
  {
    double thetaRadians = theta * Math.PI / phiDim;
    sinTable[theta] = Math.sin(thetaRadians);
    cosTable[theta] = Math.cos(thetaRadians);
  }

  for (int y = 0; y < edgeImg.height-1; y++) {
    for (int x = 0; x < edgeImg.width-1; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for (int theta = phiDim - 1; theta >= 0; theta--)
        {
          double r = cosTable[theta] * x + sinTable[theta] * y;
          int rScaled = (int)Math.round(r * halfRAxisSize / maxRadius) + halfRAxisSize;
          accumulator[theta*rDim + rScaled] += 1 ;
        }

        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator with something like: r += (rDim - 1) / 2
      }
    }
  }
  for (int i = 0; i<accumulator.length; i++) {
    if (accumulator[i]>minVotes) {
      bestCandidates.add(i);
    }
  }

  //////////////////////
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
          // check we are not outside the image
          if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
            // check we are not outside the image
            if (accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if (accumulator[idx] < accumulator[neighbourIdx]) {
              // the current idx is not a local maximum!
              bestCandidate=false;
              break;
            }
          }
          if (!bestCandidate) break;
        }
        if (bestCandidate) {
          // the current idx *is* a local maximum
          bestCandidates.add(idx);
        }
      }
    }
  }
  ////////////////



  Collections.sort(bestCandidates, new HoughComparator(accumulator));



  for (int idx = 0; idx < Math.min(nLines, bestCandidates.size()); idx++) {

    float phi = (float) (Math.round(bestCandidates.get(idx)/rDim) * Math.PI / phiDim);
    float r = ((bestCandidates.get(idx) % rDim)-halfRAxisSize)*maxRadius/halfRAxisSize ;
    res.add(new PVector(r, phi));

    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    stroke(204, 102, 0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    } else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else
          line(x1, y1, x3, y3);
      } else
        line(x2, y2, x3, y3);
    }
  }
  return res;
}

ArrayList<PVector> getIntersections(ArrayList<PVector> lines) {
  
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  PVector vec1, vec2;
  float x,y,d,phi1,phi2,r1,r2;
  for (int i = 0; i < lines.size() - 1; i++) {
    vec1 = lines.get(i);
    r1 = vec1.x;
    phi1 = vec1.y;
    for (int j = i + 1; j < lines.size(); j++) {
      vec2 = lines.get(j);
      r2 = vec2.x;
      phi2 = vec2.y;
      d = cos(phi2)*sin(phi1)-cos(phi1)*sin(phi2);
      x = (r2*sin(phi1)- r1*sin(phi2))/d;
      y = (-r2*cos(phi1)+r1*cos(phi2))/d;
      // compute the intersection and add it to ’intersections’
      // draw the intersection
      fill(255, 128, 0);
      ellipse(x, y, 10, 10);
    }
  }
  return intersections;
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

PImage filterThresholdInverted(PImage img, float threshold) {
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

PImage displayHue(PImage img, float min, float max) {
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
  float[][] hKernel2 = { { -1, -2, -1  }, 
    { 0, 0, 0 }, 
    { 1, 2, 1  } };
  float[][] vKernel2 = { { -1, 0, 1  }, 
    { -2, 0, 2 }, 
    { -1, 0, 1 } };

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
      /* sumh += hKernel[2][1]*color(getPos(img, x+1, y));
       sumh += hKernel[0][1]*color(getPos(img, x-1, y));
       sumv += vKernel[1][2]*color(getPos(img, x, y+1));
       sumv += vKernel[1][0]*color(getPos(img, x, y-1));
       */
      sumh = multMatrice(img, hKernel2, x, y, 3);
      sumv = multMatrice(img, vKernel2, x, y, 3);

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

int multMatrice(PImage img, float kernel[][], int x, int y, int kernelSize) {
  int sum = 0;
  for (int i =0; i<kernelSize; i++) {
    for (int j =0; j<kernelSize; j++) {
      sum += kernel[i][j]*color(getPos(img, x+i-1, y+j-1));
    }
  }
  return sum;
}