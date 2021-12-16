class Collision {
  PVector vertex1;
  PVector vertex2;
  PVector vertex3;
  PVector centroid;
  String material;
  PVector normala;
  float reflection;
  PVector pointInPlane;

  Collision(PVector vertex1_, PVector vertex2_, PVector vertex3_, String material_, float reflection_) {
    // Colider points in plane (triangle)
    vertex1 = vertex1_;
    vertex2 = vertex2_;
    vertex3 = vertex3_;
    material = material_;
    reflection = reflection_;
    pointInPlane = new PVector(0, 0, 0);

    // Get plane (triangle) normal vector by cross product and normalize
    PVector planeVector1_2 = PVector.sub(vertex2, vertex1);
    PVector planeVector1_3 = PVector.sub(vertex3, vertex1);
    normala = planeVector1_2.cross(planeVector1_3);
    normala.normalize();
  }

  PVector isCollision(PVector origin, PVector vector) {
    // Has input particle, with input vector, collided with plane
    PVector vectorNormalised = vector.copy();
    vectorNormalised.normalize();

    // Triangle calculation between normal of plane, vector and vertex1
    PVector offset = PVector.sub(vertex1, origin);
    float dotProduct1 = PVector.dot(normala, offset);
    float dotProduct2 = PVector.dot(normala, vectorNormalised);
    float t = dotProduct1/dotProduct2;

    PVector scaledVector = PVector.mult(vectorNormalised, t);

    if (vector.mag() > scaledVector.mag()) {
      // Detected collision
      pointInPlane = PVector.add(origin, scaledVector);
    } else {
      // Detected no collision
      pointInPlane = new PVector(0, 0, 0);
    }
    return pointInPlane;
  }

  PVector getCollisionDirection(PVector vector) {
    // Determine direction to change velocity of particle
    float vectorMagnitude = vector.mag();
    PVector vectorNormalised = vector.copy();
    vectorNormalised.normalize();

    // Get vector for collision reflection
    float dotProduct = 2 * PVector.dot(vectorNormalised, normala);
    PVector scaledNormal = PVector.mult(normala, dotProduct);
    PVector vectorDirection = PVector.sub(vectorNormalised, scaledNormal);
    vectorDirection.mult(vectorMagnitude);

    return vectorDirection;
  }

  boolean isPointInColider(PVector inputPoint) {
    // Is input particle in colider 
    PVector v0 = PVector.sub(vertex3, vertex1);
    PVector v1 = PVector.sub(vertex2, vertex1);
    PVector v2 = PVector.sub(inputPoint, vertex1);

    float prod00 = PVector.dot(v0, v0);
    float prod01 = PVector.dot(v0, v1);
    float prod02 = PVector.dot(v0, v2);
    float prod11 = PVector.dot(v1, v1);
    float prod12 = PVector.dot(v1, v2);
    float inverse = 1 / ((prod00 * prod11) - (prod01 * prod01));
    float x = ((prod00 * prod12) - (prod01 * prod02)) * inverse;
    float y = ((prod11 * prod02) - (prod01 * prod12)) * inverse;


    if ((x >= 0) && (y >= 0) && (x + y < 1)) {
      return true;
    } else {
      return false;
    }
  }

  void render() {
    noStroke();
    noFill();
    beginShape(TRIANGLE);
    vertex(vertex1.x, -vertex1.y, vertex1.z);
    vertex(vertex2.x, -vertex2.y, vertex2.z);
    vertex(vertex3.x, -vertex3.y, vertex3.z);
    endShape();
  }
}
