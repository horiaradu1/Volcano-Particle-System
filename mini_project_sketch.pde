import controlP5.*;
import queasycam.*;
QueasyCam qcam;
PMatrix3D baseMat;

ControlP5 cp5;
ParticleSystem ps;
PImage bg;
PImage grass;
PImage water;
PImage volcano;
PImage smokeImg;
PImage lavaImg;
PFont boldFont;
boolean eruption = false;
boolean textureBool = false;
ArrayList<Collision> coliderList = new ArrayList<Collision>();
float radius;

PVector gravity;
PVector gravitySmoke;

int lifespanSliderLava = 600;
int lifespanSliderSmoke = 1000;
float initialLavaVelocity = 1;
float initialLavaVelocityY = 1;
float initialSmokeVelocity = 1;
int particleMultiplierLava = 5;
int particleMultiplierSmoke = 5;
boolean gravityToggle = true;
float gravityIntensity = 1;
boolean randomColour = false;
boolean spheresRendering = true;

// Setup the scene, camera and particle system, load images
void setup() {
  size(1000, 800, P3D);
  bg = loadImage("sky.jpg");
  grass = loadImage("grass.jpg");
  water = loadImage("ocean.jpg");
  volcano = loadImage("rocks.jpg");
  smokeImg = loadImage("smokeT.png");
  lavaImg = loadImage("lavaT.png");
  textAlign(LEFT, TOP);
  boldFont = createFont("Bitstream Charter Bold", 18);

  frameRate(60);
  ps = new ParticleSystem();

  // Create coliders
  pyramidColider(6, 120, 100, "volcano", 0.4);
  radius = 10;
  cubeColider(80, 10, "grass", 0.05);
  cubeColider(300, 5, "water", 0.05);

  // Setup gravity for particle systems
  gravity = new PVector(0, -0.05, 0);
  gravitySmoke = new PVector(0, 0.004, 0);

  cp5 = new ControlP5(this);

  // Add sliders and buttons for interaction
  cp5.addSlider("initialLavaVelocityY").setPosition(5, 620).setSize(300, 25).setRange(0, 10).setValue(1).setLabel("Lava Initial Velocity Eruption Upwards");
  cp5.addSlider("lifespanSliderLava").setPosition(5, 645).setSize(300, 25).setRange(0, 3000).setValue(600).setLabel("Lava Lifespan");
  cp5.addSlider("particleMultiplierLava").setPosition(5, 670).setSize(300, 25).setRange(0, 20).setValue(5).setLabel("Lava Particle Multiplier");
  cp5.addSlider("initialLavaVelocity").setPosition(5, 695).setSize(300, 25).setRange(0, 10).setValue(1).setLabel("Lava Initial Velocity Radius");
  cp5.addSlider("lifespanSliderSmoke").setPosition(5, 720).setSize(300, 25).setRange(0, 3000).setValue(1000).setLabel("Smoke Lifespan");
  cp5.addSlider("particleMultiplierSmoke").setPosition(5, 745).setSize(300, 25).setRange(0, 20).setValue(5).setLabel("Smoke Particle Multiplier");
  cp5.addSlider("initialSmokeVelocity").setPosition(5, 770).setSize(300, 25).setRange(0, 10).setValue(1).setLabel("Smoke Initial Velocity Radius");
  cp5.addToggle("randomColour").setPosition(900, 650).setSize(50, 25).setValue(randomColour).setLabel("Random Colours");
  cp5.addToggle("spheresRendering").setPosition(900, 550).setSize(50, 25).setValue(spheresRendering).setLabel("Spehers or Quads");
  cp5.addToggle("gravityToggle").setPosition(900, 700).setSize(50, 25).setValue(gravityToggle).setLabel("Gravity");
  cp5.addSlider("gravityIntensity").setPosition(600, 750).setSize(300, 25).setRange(-1, 5).setValue(1).setLabel("Gravity Intensity");
  cp5.setAutoDraw(false);

  // Create freelook camera
  qcam = new QueasyCam(this);
  qcam.speed = 4;
  qcam.sensitivity = 0.3;
  qcam.controllable = false;
  baseMat = getMatrix(baseMat);
  camera(width/2, height/2-150, (height/2) / tan(PI/6) - 40, width/2, height/2-50, 300, 0, 1, 0);
}

void draw() {
  int start_time = millis();
  // Configure textures, on or off
  if (textureBool == true) {
    textureMode(IMAGE);
    noStroke();
  } else {
    textureMode(NORMAL);
    stroke(0, 255, 0);
  }

  background(bg);

  // Render other objects
  pyramid(6, 120, 100);
  cube(80, 10, grass);
  cube(300, 5, water);

  for (int i=0; i<coliderList.size(); i++)
    coliderList.get(i).render();

  // Render particle systems + determine if eruption of volcano or not
  float x = width/2 + (radius * sqrt(random(0, 1))) * cos(random(0, 1) * 2 * PI);
  float z = 300 + (radius * sqrt(random(0, 1))) * sin(random(0, 1) * 2 * PI);
  if (eruption == false) {
    ps.addParticleSmoke(new PVector(x, -height/2+50, z));
    ps.runSmoke();
    ps.runLava(coliderList);
  } else {
    ps.addParticleLava(new PVector(x, -height/2+52, z));
    ps.runSmoke();
    ps.runLava(coliderList);
  }

  // Load interface of the program
  g.pushMatrix();
  g.hint(DISABLE_DEPTH_TEST);
  g.resetMatrix();
  g.applyMatrix(baseMat);
  cp5.draw();
  fill(0, 255, 0);
  textFont(boldFont);
  text("Frame Rate: " + (int)frameRate, width*0.01f, height*0.01f);
  text("Nr. of smoke and steam particles: " + ps.smokeParticles.size(), width*0.01f, height*0.03f);
  text("Nr. of lava particles: " + ps.lavaParticles.size(), width*0.01f, height*0.05f);
  text("Press {space} for eruption", width*0.70f, height*0.01f);
  text("Press {t} for textures", width*0.70f, height*0.03f);
  text("Press {f} for freelook camera", width*0.70f, height*0.05f);
  text("Use {w}, {a}, {s}, {d} to move camera", width*0.65f, height*0.07f);
  text("Press {mouse} to move view orientation", width*0.65f, height*0.09f);
  g.hint(ENABLE_DEPTH_TEST);
  g.popMatrix();
  println(millis() - start_time);
}

void keyPressed() {
  if (key == ' ') {
    eruption = !eruption;
  }
  if (key == 'f') {
    qcam.controllable = !qcam.controllable;
  }
  if (key == 't') {
    textureBool = !textureBool;
  }
}

void pyramidColider(int sides, float d, float h, String material, float reflection) {
  PVector[] basePts = new PVector[sides];
  for (int i = 0; i < sides; ++i ) {
    float ang = TWO_PI * i / sides;
    basePts[i] = new PVector(cos(ang) * d/2, h/2, sin(ang) * d/2);
  }

  for (int i = 0; i < sides; ++i ) {
    int i2 = (i+1) % sides;
    Collision pyramidSide1 = new Collision(new PVector(basePts[i].x + width/2, -basePts[i].y-height/2, basePts[i].z+300), new PVector(basePts[i].x*0.3 + width/2, h/2-height/2, basePts[i].z*0.3+300), new PVector(basePts[i2].x*0.3 + width/2, h/2-height/2, basePts[i2].z*0.3+300), material, reflection);
    Collision pyramidSide2 = new Collision(new PVector(basePts[i].x + width/2, -basePts[i].y-height/2, basePts[i].z+300), new PVector(basePts[i2].x + width/2, -basePts[i2].y-height/2, basePts[i2].z+300), new PVector(basePts[i2].x*0.3 + width/2, h/2-height/2, basePts[i2].z*0.3+300), material, reflection);
    Collision pyramidSideTop = new Collision(new PVector(basePts[i].x*0.3 + width/2, h/2-height/2, basePts[i].z*0.3+300), new PVector(width/2, h/2-height/2, 300), new PVector(basePts[i2].x*0.3 + width/2, h/2-height/2, basePts[i2].z*0.3+300), material, 1);
    coliderList.add(pyramidSide1);
    coliderList.add(pyramidSide2);
    coliderList.add(pyramidSideTop);
  }
}

void pyramid(int sides, float d, float h) {
  PVector[] basePts = new PVector[sides];
  for (int i = 0; i < sides; ++i ) {
    float ang = TWO_PI * i / sides;
    basePts[i] = new PVector(cos(ang) * d/2, h/2, sin(ang) * d/2);
  }
  pushMatrix();
  translate(width/2, height/2, 300);
  beginShape(QUAD);
  fill(247, 104, 6);
  texture(volcano);
  for (int i = 0; i < sides; ++i ) {
    int i2 = (i+1) % sides;
    vertex(basePts[i].x, basePts[i].y, basePts[i].z, 0, volcano.pixelHeight);
    vertex(basePts[i2].x, basePts[i2].y, basePts[i2].z, 0, 0);
    vertex(basePts[i2].x*0.3, -h/2, basePts[i2].z*0.3, volcano.pixelWidth, 0);
    vertex(basePts[i].x*0.3, -h/2, basePts[i].z*0.3, 0, 0);
  }
  endShape();
  beginShape();
  fill(247, 104, 6);
  for (int i = 0; i < sides; ++i ) {
    vertex(basePts[i].x*-0.3, -h/2, basePts[i].z*-0.3);
  }
  endShape(CLOSE);
  popMatrix();
}

void cubeColider(int s, int h, String material, float reflection) {
  Collision triangle1 = new Collision(new PVector(-s+width/2, h-height/2-60, -s+300), new PVector(s+width/2, h-height/2-60, -s+300), new PVector(s+width/2, h-height/2-60, s+300), material, reflection);
  Collision triangle2 = new Collision(new PVector(-s+width/2, h-height/2-60, -s+300), new PVector(s+width/2, h-height/2-60, s+300), new PVector(-s+width/2, h-height/2-60, s+300), material, reflection);
  coliderList.add(triangle1);
  coliderList.add(triangle2);
}

void cube(int s, int h, PImage img) {
  pushMatrix();
  translate(width/2, height/2+60, 300);
  beginShape(QUAD);
  texture(img);
  // +Z "front" face
  vertex(-s, -h, s, 0, 0);
  vertex( s, -h, s, img.pixelWidth, 0);
  vertex( s, h, s, img.pixelWidth, img.pixelHeight);
  vertex(-s, h, s, 0, img.pixelHeight);
  // back
  vertex( s, -h, -s, 0, 0);
  vertex(-s, -h, -s, img.pixelWidth, 0);
  vertex(-s, h, -s, img.pixelWidth, img.pixelHeight);
  vertex( s, h, -s, 0, img.pixelHeight);
  // bottom
  vertex(-s, h, s, 0, 0);
  vertex( s, h, s, img.pixelWidth, 0);
  vertex( s, h, -s, img.pixelWidth, img.pixelHeight);
  vertex(-s, h, -s, 0, img.pixelHeight);
  // top
  vertex(-s, -h, -s, 0, 0);
  vertex( s, -h, -s, img.pixelWidth, 0);
  vertex( s, -h, s, img.pixelWidth, img.pixelHeight);
  vertex(-s, -h, s, 0, img.pixelHeight);
  // right
  vertex( s, -h, s, 0, 0);
  vertex( s, -h, -s, img.pixelWidth, 0);
  vertex( s, h, -s, img.pixelWidth, img.pixelHeight);
  vertex( s, h, s, 0, img.pixelHeight);
  // left
  vertex(-s, -h, -s, 0, 0);
  vertex(-s, -h, s, img.pixelWidth, 0);
  vertex(-s, h, s, img.pixelWidth, img.pixelHeight);
  vertex(-s, h, -s, 0, img.pixelHeight); 
  endShape();
  popMatrix();
}

void particleRender(float x, PImage txt, int a, int b, int c) {
  if (textureBool == true) {
    textureMode(NORMAL);
    beginShape(QUAD);
    texture(txt);
    vertex(x, x, 0, x);
    vertex(-x, x, 0, 0);
    vertex(-x, -x, x, 0);
    vertex(x, -x, 0, 0);
    endShape();
  } else {
    beginShape(QUAD);
    stroke(a, b, c);
    vertex(x, x, 0, x);
    vertex(-x, x, 0, 0);
    vertex(-x, -x, x, 0);
    vertex(x, -x, 0, 0);
    endShape();
  }
}
