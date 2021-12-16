class ParticleSystem {
  ArrayList<LavaParticle> lavaParticles;
  ArrayList<SmokeParticle> smokeParticles;
  ArrayList<PVector> deadLavaParticles;
  PVector origin;
  float counterLava = 0.0;
  float timerLava = 5.0;
  float counterSmoke = 0.0;
  float timerSmoke = 5.0;
  int howManyLava;
  int howManySmoke;

  ParticleSystem() {
    lavaParticles = new ArrayList<LavaParticle>();
    smokeParticles = new ArrayList<SmokeParticle>();
    deadLavaParticles = new ArrayList<PVector>();
  }

  // LAVA PARTICLES
  void addParticleLava(PVector position) {
    howManyLava = (int) 10 * particleMultiplierLava; // Random nr of particles to add per run
    if (counterLava >= timerLava) {
      counterLava = 0;
      for (int i=0; i<howManyLava; i++) {
        lavaParticles.add(new LavaParticle(position));
      }
    } else {
      counterLava += 1; // Count time between particle spawn
    }
  }

  void runLava(ArrayList<Collision> coliderList) {
    for (int i = 0; i<lavaParticles.size(); i++) {
      LavaParticle p = lavaParticles.get(i);
      if (p.vapour == true) {
        smokeParticles.add(new SmokeParticle(p.position));
        int temp = smokeParticles.size()-1;
        smokeParticles.get(temp).lifespan = smokeParticles.get(temp).lifespan/4;
        smokeParticles.get(temp).colourSmoke = new PVector(238, 238, 238);
        lavaParticles.remove(i);
      }
      if (p.isDead()) {
        lavaParticles.remove(i);
      }
      // Stop at a certain terminal velocity
      if (gravityToggle == true) {
        if (p.vel.y > -5) {
          PVector force = new PVector();
          p.applyForce(PVector.mult(gravity, gravityIntensity, force));
        }
      }
      p.run(coliderList);
    }
  }

  // SMOKE PARTICLES
  void addParticleSmoke(PVector position) {
    howManySmoke = (int) 2 * particleMultiplierSmoke; // Random nr of particles to add per run
    if (counterSmoke >= timerSmoke) {
      counterSmoke = 0;
      for (int i=0; i<howManySmoke; i++) {
        smokeParticles.add(new SmokeParticle(position));
      }
    } else {
      counterSmoke += 1; // Count time between particle spawn
    }
  }

  void runSmoke() {
    for (int i = 0; i<smokeParticles.size(); i++) {
      SmokeParticle p = smokeParticles.get(i);
      if (p.isDead()) {
        smokeParticles.remove(i);
      }
      // Stop at a certain terminal velocity
      if (gravityToggle == true) {
        if (p.vel.y < 0.5) {
          PVector force = new PVector();
          p.applyForce(PVector.mult(gravitySmoke, gravityIntensity, force));
        }
      }
      p.run();
    }
  }
}
