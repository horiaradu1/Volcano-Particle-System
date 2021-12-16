class LavaParticle {
  PVector position;
  float lifespan;
  PVector vel;
  PVector acc;
  PVector colourLava;
  boolean vapour;
  float sphereSize;

  LavaParticle(PVector position_) {
    // Setup particle velocity, position and lifespan
    float radius = random(0.5, 1) * initialLavaVelocity;
    float x = (radius * sqrt(random(0, 1))) * cos(random(0, 1) * 2 * PI);
    float z = (radius * sqrt(random(0, 1))) * sin(random(0, 1) * 2 * PI);
    vel = new PVector(x, random(0.5, 3) * initialLavaVelocityY, z);
    acc = new PVector(0, 0, 0);
    position = position_.copy();
    lifespan = lifespanSliderLava;
    // Determine colours
    if (randomColour == false) {
      int r = (int)random(100, 255);
      int g = (int)random(0, 80);
      int b = (int)random(0, 20);
      colourLava = new PVector(r, g, b);
    } else {
      int r = (int)random(0, 255);
      int g = (int)random(0, 255);
      int b = (int)random(0, 255);
      colourLava = new PVector(r, g, b);
    }
    sphereSize = random(1, 2);
  }

  void applyForce(PVector inputForce) {
    acc.add(inputForce);
  }

  void run(ArrayList<Collision> coliderList) {
    update(coliderList);
    render();
  }

  void update(ArrayList<Collision> coliderList) {
    vel.add(acc);

    colide(coliderList);

    position.add(vel);
    acc.mult(0);
    lifespan -= 1;
  }

  void colide(ArrayList<Collision> coliderList) {
    for (int i=0; i<coliderList.size(); i++) {
      Collision colider = coliderList.get(i);
      PVector intersectionPoint = colider.isCollision(position, vel);
      if (intersectionPoint.mag() != 0) {
        if (colider.isPointInColider(intersectionPoint)) {
          if (colider.material == "water") {
            vapour = true;
          }
          position = intersectionPoint;
          vel = colider.getCollisionDirection(vel);
          vel.mult(colider.reflection);
        }
      }
    }
  }

  void render() {
    // Rendering for lava
    colourLava.x -= 0.2;
    colourLava.y -= 0.2;
    colourLava.z -= 0.2;

    pushMatrix();
    translate(position.x, -position.y, position.z);
    // Sphere or quad
    if (spheresRendering == true) {
      noStroke();
      fill(colourLava.x, colourLava.y, colourLava.z, lifespan);
      sphereDetail(4);
      sphere(sphereSize);
    } else {
      particleRender(1.5, lavaImg, 255, 0, 0);
    }
    popMatrix();
  }

  boolean isDead() {
    if (lifespan <= 0) {
      return true;
    } else {
      return false;
    }
  }
}
