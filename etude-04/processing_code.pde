int nStars = 250;
PVector[] sc = new PVector[nStars];
float[] rad = new float[nStars];
int nClusters = 40;
color[] colors = new color[nClusters];
PVector[] cc = new PVector[nClusters];
ArrayList<int>[] clusters = new ArrayList<int>  [nClusters];
nFStars1 = 30;
nFStars2 = 30;
PVector[] fixedStars = new PVector[nFStars1];
PVector[] fixedStars2 = new PVector[nFStars2];

PGraphics bigSky; 
swidth = 1500;
sheight = 1500;

float w = 0.05; // angular speed

void setup() {
  size(600, 400);

  bigSky = createGraphics(swidth, sheight);

  // generate background stars
  for (int i=0; i<nFStars1; i++) {
    fixedStars[i] = new PVector( random(swidth), random(sheight) );
  }
  for (int i=0; i<nFStars2; i++) {
    fixedStars2[i] = new PVector( random(swidth), random(sheight) );
  }
  
  // set foreground star colors
  for (int i=0; i<nClusters; i++) {
    colorMode(HSB);
    //colors[i] = color(i*255/nClusters, 200, 150);
    colorMode(RGB);
    colors[i] = color(250, 250, 200);
  }
  

  // generate random locations and sizes for stars
  for (int i=0; i<nStars; i++) {
    sc[i] = new PVector( random(swidth), random(sheight) );
    rad[i] = random(2.0) + 2.0;
  }

  // k-mean clustering algorithm
  // generate random cluster centroids
  for (int i=0; i<nClusters; i++) {
    cc[i] = new PVector( random(swidth), random(sheight) );
    clusters[i] = new ArrayList();
  }

  // iterate several times
  for (int iter=0; iter<15; iter++) {
    // Empty clusters
    for (int i=0; i<nClusters; i++) {
      clusters[i].clear();
    }

    // Assign each object to the group that has the closest centroid   
    for (int i=0; i<nStars; i++) {
      clusters[ findClosestCentroid(i) ].add(i);
    }

    // Recalculate the positions of the centroids.
    for (int i=0; i<nClusters; i++) {
      cc[i] = centerOfMass(i);
    }
  }

  //noLoop();
}

void draw() {
  background(100);
  bigSky.beginDraw();
  bigSky.background(0);
  bigSky.smooth();
  bigSky.noStroke();
  bigSky.fill(255);

  // draw random stars
  for (int i=0; i<30; i++) {
    bigSky.fill(150);
    bigSky.ellipse(fixedStars[i].x, fixedStars[i].y, 2, 2);
  }
  for (int i=0; i<30; i++) {
    bigSky.fill(80);
    bigSky.ellipse(fixedStars2[i].x, fixedStars2[i].y, 1, 1);
  }

  // draw Clusters
  for (int i=0; i<nClusters; i++) {
    for (int j=0; j<clusters[i].size(); j++) {
      int sIn = clusters[i].get(j);
      bigSky.fill(colors[i]);
      bigSky.fill( lerpColor( color(250,250,150), color(200,200, 250), random(1000)/1000.) );
      bigSky.ellipse(sc[sIn].x, sc[sIn].y, rad[sIn], rad[sIn]);
    }
    //println( centerOfMass(i) );
  }  
  
  //drawCentroids();

  // for each cluster draw some constellations 
  for (int i=0; i<nClusters; i++) {
    bigSky.stroke( colors[i] );
    if ( clusters[i].size() > 3 && clusters[i].size()<8) {
      //println( i, clusters[i].size() );
      for ( int j=0; j<clusters[i].size()-1; j++) {
        int sIn1 = clusters[i].get(j);
        int sIn2 = clusters[i].get(j+1);
        bigSky.line( sc[sIn1].x, sc[sIn1].y, sc[sIn2].x, sc[sIn2].y );
      }
    }
  }

  bigSky.endDraw();
  pushMatrix();
  translate(width/2,height*5.0/4);
  rotate(w*TWO_PI*(-1)*millis()/1000,0);
  image(bigSky, -swidth/2, -sheight/2);
  popMatrix();
  
  for(int x=0; x<width; x++) {
    stroke(20);
    line(x,height, x,height-100*noise( 0.005*x) );
  }
  stats.update();
}

int findClosestCentroid(int starNo) {
  int clusterNo = 0;
  float minDist = 99999.0;
  for (int j=0; j<nClusters; j++) {  
    float d = sc[starNo].dist(cc[j]);
    if (d<minDist) {
      minDist = d;
      clusterNo = j;
    }
  }  
  return clusterNo;
}


void drawCentroids() {
  for (int i=0; i<nClusters; i++) {
    //fill( 50+i*205/nClusters, 0, 0 );
    fill(colors[i]); 
    rect(cc[i].x, cc[i].y, 5, 5);
  }
}

PVector centerOfMass(int clusterNo) {
  PVector center = new PVector(0., 0.);
  int clusterSize = clusters[clusterNo].size();
  for (int i=0; i<clusterSize; i++) {
    int starInClisterIndex = clusters[clusterNo].get(i);
    center.add( sc[starInClisterIndex] );
  }
  center.div( clusterSize );
  return center;
}

void mousePressed(event e) {
  setup();
  draw();
}   