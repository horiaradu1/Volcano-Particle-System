class SmokeParticle {
  PVector position;
  float lifespan;
  PVector vel;
  PVector acc;
  PVector colourSmoke;
  float sphereSize;

  SmokeParticle(PVector position_) {
    // Setup particle velocity, position and lifespan
    float vx = randomGaussian()*0.1 * initialSmokeVelocity;
    float vy = randomGaussian()*0.05 * initialSmokeVelocity;
    float vz = randomGaussian()*0.1 * initialSmokeVelocity;
    acc = new PVector(0, 0, 0);
    vel = new PVector(vx, vy, vz);
    position = position_.copy();
    // Determine colours
    if (randomColour == false) {
      int rgb = (int)random(50, 80);
      colourSmoke = new PVector(rgb, rgb, rgb);
    } else {
      int r = (int)random(0, 255);
      int g = (int)random(0, 255);
      int b = (int)random(0, 255);
      colourSmoke = new PVector(r, g, b);
    }
    lifespan = lifespanSliderSmoke;
    sphereSize = random(1, 2);
  }

  void applyForce(PVector inputForce) {
    acc.add(inputForce);
  }

  void run() {
    update();
    render();
  }

  void update() {
    vel.add(acc);
    position.add(vel);
    lifespan -= random(1, 3);
    acc.mult(0);
  }

  void render() {
    // Rendering for smoke
    pushMatrix();
    translate(position.x, -position.y, position.z);
    // Sphere or quad
    if (spheresRendering == true) {
      noStroke();
      fill(colourSmoke.x, colourSmoke.y, colourSmoke.z, lifespan);
      sphereDetail(4);
      sphere(sphereSize);
    } else {
      particleRender(1.5, smokeImg, 0, 0, 0);
    }
    popMatrix();
  }

  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
