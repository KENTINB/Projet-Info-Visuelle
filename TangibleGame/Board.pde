import processing.video.*;
import java.util.Collections;
import java.util.Random;


public void movieEvent(Movie m) {
  m.read();
}

class ImageProcessing extends PApplet {

  Movie cam2;
  PVector rotation;
  
  public PVector getRotation(){
   return rotation; 
  }


  PImage img;
  int max = 0xFFFFFF;
  HScrollbar thresholdBar1;
  HScrollbar thresholdBar2;
  QuadGraph graph;
  int sizeKernel = 3;
  float[][] kernel = { { 1, 2, 1}, { 2, 4, 2 }, { 1, 2, 1}};
  float weight = 16.f;
  int thresholdAcc = 150;
  float minHUE = 50;
  float maxHUE = 135;
  float minS = 75;
  float maxS = 255;
  float minB = 50;
  float maxB = 216;
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  TwoDThreeD t = new TwoDThreeD(600, 400);

  // size of the region we search for a local maximum
  int neighbourhood = 10;
  // only search around lines with more that this amount of votes
  // (to be adapted to your image)
  int minVotes = 150;




  void settings() {
    size(1300, 500);
  }
  void setup() {

    //img = loadImage("board1.jpg");
    //noLoop();
    // no interactive behaviour: draw() will be called only once.
    graph = new QuadGraph();

    //Assignement 9 Camera
    /*
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
     }*/
    cam2 = new Movie(this, "C:/Users/Quentin/Documents/GitHub/Projet-Info-Visuelle/TangibleGame/testvideo.mp4"); //Put the video in the same directory
    cam2.loop();
  }
  void draw() {
    //Assignement 9 Camera
    /*
  if (cam.available() == true) {
     cam.read();
     }*/

    movieEvent(cam2);
    img = cam2;

    image(img, 0, 0);
    PImage conv = sobel(((intensityThreshold(convolute(displayHSV(img, minHUE, maxHUE, minS, maxS, minB, maxB)), 10))));
    
    int acc[] = getAccumulator(conv);
     ArrayList<PVector> lines = hough(conv, acc, 4);
     graph.build(lines, img.width, img.height);
     
     List<int[]> quads = graph.findCycles();
     ArrayList<PVector> corners = getIntersections(displayGoodQuads(graph, lines, quads), 600, 400);
     if(corners.size() == 4) {
     rotation =  t.get3DRotations(sortCorners(corners));
     }
    image(conv, 600, 0);

    /*
    img.resize(500, 400);
     PImage conv = sobel(((intensityThreshold(convolute(displayHSV(img, minHUE, maxHUE, minS, maxS, minB, maxB)), 10))));
     conv.resize(500, 400);
     
     image(img, 0, 0);
     int acc[] = getAccumulator(conv);
     ArrayList<PVector> lines = hough(conv, acc, 4);
     graph.build(lines, img.width, img.height);
     
     List<int[]> quads = graph.findCycles();
     //getIntersections(lines);
     println(t.get3DRotations(sortCorners(getIntersections(displayGoodQuads(graph, lines, quads), 500, 400))).mult(180/PI));
     */



    //image(displayAcc(conv, acc), 500, 0);
    //image(conv, 900, 0);
  }

  boolean goodQuad(QuadGraph g, PVector c1, PVector c2, PVector c3, PVector c4) {
    return g.isConvex(c1, c2, c3, c4) && g.nonFlatQuad(c1, c2, c3, c4) && g.validArea(c1, c2, c3, c4, 1000000, 0);
  }

  ArrayList<PVector> displayGoodQuads(QuadGraph graph, ArrayList<PVector> lines, List<int[]> quads) {
    ArrayList<PVector> res = new ArrayList<PVector>();
    for (int[] quad : quads) {
      PVector l1 = lines.get(quad[0]);
      PVector l2 = lines.get(quad[1]);
      PVector l3 = lines.get(quad[2]);
      PVector l4 = lines.get(quad[3]);
      // (intersection() is a simplified version of the
      // intersections() method you wrote last week, that simply
      // return the coordinates of the intersection between 2 lines)
      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);
      // Choose a random, semi-transparent colour
      if (goodQuad(graph, c12, c23, c34, c41)) {

        //stroke(204, 102, 0);
        /*
      line(c12.x, c12.y, c23.x, c23.y);
         line(c34.x, c34.y, c23.x, c23.y);
         line(c34.x, c34.y, c41.x, c41.y);
         line(c12.x, c12.y, c41.x, c41.y);
         */
        res.add(l1);
        res.add(l2);
        res.add(l3);
        res.add(l4);

        Random random = new Random();
        fill(color(min(255, random.nextInt(300)), 
          min(255, random.nextInt(300)), 
          min(255, random.nextInt(300)), 150));
        quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
      }
    }
    return res;
  }

  //Assignement 9
  int[] getAccumulator(PImage edgeImg) {

    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi);
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
    // our accumulator (with a 1 pix margin around)
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
    int DemiRAxe = rDim/2;
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
            int rScaled = (int)Math.round(r * DemiRAxe / maxRadius) + DemiRAxe;
            accumulator[theta*rDim + rScaled] += 1 ;
          }
        }
      }
    }
    return accumulator;
  }

  PImage displayAcc(PImage edgeImg, int accumulator[]) {
    int phiDim = (int) (Math.PI / discretizationStepsPhi);
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);

    PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    // You may want to resize the accumulator to make it easier to see:
    houghImg.resize(600, 400);
    houghImg.updatePixels();
    return houghImg;
  }


  ArrayList<PVector> hough(PImage edgeImg, int accumulator[], int nLines) {

    ArrayList<PVector> res = new ArrayList<PVector>();
    ArrayList<Integer> bestCandidates = new ArrayList();

    int phiDim = (int) (Math.PI / discretizationStepsPhi);
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
    int DemiRAxe = rDim/2 /*>>> 1*/;
    int maxRadius = (int)Math.ceil(Math.hypot(width, height));

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

    Collections.sort(bestCandidates, new HoughComparator(accumulator));

    for (int idx = 0; idx < Math.min(nLines, bestCandidates.size()); idx++) {

      float phi = (float) (Math.round(bestCandidates.get(idx)/rDim) * discretizationStepsPhi/*Math.PI / phiDim*/);

      float r = ((bestCandidates.get(idx) % rDim)-DemiRAxe)*maxRadius/DemiRAxe ;
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


  ArrayList<PVector> getIntersections(ArrayList<PVector> lines, float w, float h) {

    ArrayList<PVector> intersections = new ArrayList<PVector>();
    PVector vec1, vec2;
    float x, y, d, phi1, phi2, r1, r2;
    for (int i = 0; i < lines.size() - 1; i++) {
      vec1 = lines.get(i);
      r1 = vec1.x;
      phi1 = vec1.y;
      for (int j = i + 1; j < lines.size(); j++) {
        vec2 = lines.get(j);
        r2 = vec2.x;
        phi2 = vec2.y;
        d = cos(phi2)*sin(phi1)-cos(phi1)*sin(phi2);
        x = (r2*sin(phi1) - r1*sin(phi2))/d;
        y = (-r2*cos(phi1)+ r1*cos(phi2))/d;
        // compute the intersection and add it to ’intersections’
        // draw the intersection
        fill(255, 128, 0);
        ellipse(x, y, 10, 10);
        if (x>0 && y>0 && x< w && y < h) intersections.add(new PVector(x, y));
      }
    }
    return intersections;
  }

  PVector intersection(PVector vec1, PVector vec2) {
    float x, y, d, phi1, phi2, r1, r2;
    r1 = vec1.x;
    phi1 = vec1.y;
    r2 = vec2.x;
    phi2 = vec2.y;

    d = cos(phi2)*sin(phi1)-cos(phi1)*sin(phi2);
    x = (r2*sin(phi1)- r1*sin(phi2))/d;
    y = (-r2*cos(phi1)+r1*cos(phi2))/d;
    return new PVector(x, y);
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

  PImage filterBiggerThreshold(PImage img, float threshold) {
    PImage result = createImage(width, height, RGB);
    // create a new, initially transparent, 'result' image
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      if (brightness(img.pixels[i]) > threshold) {
        result.pixels[i] = 0;
      } else {
        result.pixels[i] = img.pixels[i];
      }
    }
    return result;
  }

  PImage intensityThreshold(PImage img, float threshold) {
    PImage result = img.copy();
    for (int i = 0; i < img.width * img.height; i++) {
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


  PImage displayHue( float min, float max) {
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

  PImage displayHSV(PImage img, float minHUE, float maxHUE, float minS, float maxS, float minB, float maxB) {
    PImage result = img.copy();
    // create a new, initially transparent, 'result' image
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      if ((int)hue(img.pixels[i])> minHUE && (int)hue(img.pixels[i])< maxHUE && (int)saturation(img.pixels[i])> minS && (int)saturation(img.pixels[i])< maxS && (int)brightness(img.pixels[i])> minB && (int)brightness(img.pixels[i])< maxB  ) {
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

  //additional filter
  PImage areaFilter(PImage img, float threshold) {
    PImage res = img;
    for (int i = 1; i< img.height*img.width -1; i++) {
      if (img.pixels[i-1]>threshold && img.pixels[i]>threshold &&img.pixels[i+1]>threshold) {
        res.pixels[i] = max;
      } else {
        res.pixels[i] = 0;
      }
    }
    return img;
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
}