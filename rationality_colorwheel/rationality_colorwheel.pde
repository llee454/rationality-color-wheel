enum Mode {
  Normal, // normal mode - generates the "normal" colorwheel
  Bounded // outputs upper and lower bounds for the posterior probability.
}

// TOGGLE ME!!!
Mode mode = Mode.Bounded;

int n = 125;

color blue   = color (200, 200, 255);
color green  = color (200, 255, 200);
color yellow = color (255, 255, 200);
color orange = color (255, 225, 200);
color red    = color (255, 200, 200);

float offset = PI/2 - PI/5;

color getColor (int level) {
  switch (level) {
    case 0: return red;
    case 1: return orange;
    case 2: return yellow;
    case 3: return green;
    case 4: return blue;
    default:
      return color (200, 200, 200);
  }
}

float getProbability (int level) {
  switch (level) {
    case 0: return 0.025; // half way between 0.05 and 0.0
    case 1: return 0.125; // half way between 0.20 and 0.05
    case 2: return 0.50; // ... 0.20 and 0.80
    case 3: return 0.875; // ... 0.80 and 0.95
    case 4: return 0.975; // ... 0.95 and 1.00
    default:
      return 0.0;
  }
}

// Accepts a probability level and returns the upper bound of the probability range for the given level.
float getProbabilityUpperBound (int level) {
  switch (level) {
    case 0: return 0.05;
    case 1: return 0.20;
    case 2: return 0.79;
    case 3: return 0.94;
    case 4: return 1.00;
    default:
      return 0.0;
  }
}

// Accepts a probability level and returns the lower bound of the probability range for the given level.
float getProbabilityLowerBound (int level) {
  switch (level) {
    case 0: return 0.00;
    case 1: return 0.06;
    case 2: return 0.21;
    case 3: return 0.80;
    case 4: return 0.95;
    default:
      return 0.0;
  }}

/*
  Accepts three arguments:
    prior, the probability that the hypothesis is true without the evidence;
    conditional, the probability of seeing the evidence if the hypothesis is true;
    notConditional, the probability of seeing the evidence if the hypothesis is not true;
  and returns the probability that the hypothesis is true using Bayes rule.
*/
float posterior (int prior, int conditional, int notConditional) {
  float priorProb   = getProbability (prior);
  float condProb    = getProbability (conditional);
  float notCondProb = getProbability (notConditional);
  float posterior = condProb * priorProb / ((condProb * priorProb) + (notCondProb * (1 - priorProb)));

  println ("prior: ", priorProb, " cond: ", condProb, " notCond: ", notCondProb, " posterior: ", posterior);
  
  return posterior;
}

// Returns the upper bound for the posterior probability for inputs within the given probability ranges.
float posteriorUpperBound (int prior, int conditional, int notConditional) {
  float priorUB          = getProbabilityUpperBound (prior);
  float conditionalUB    = getProbabilityUpperBound (conditional);
  float notConditionalLB = getProbabilityLowerBound (notConditional);
  float posterior = conditionalUB * priorUB / ((conditionalUB * priorUB) + (notConditionalLB * (1 - priorUB)));
  
  println ("prior (ub): ", priorUB, " cond (ub): ", conditionalUB, " not cond (lb): ", notConditionalLB, " posterior: ", posterior);
  
  return posterior;
}

// Returns the lower bound for the posterior probability for inputs within the given probability ranges.
float posteriorLowerBound (int prior, int conditional, int notConditional) {
  float priorLB          = getProbabilityLowerBound (prior);
  float conditionalLB    = getProbabilityLowerBound (conditional);
  float notConditionalUB = getProbabilityUpperBound (notConditional);
  float posterior = conditionalLB * priorLB / ((conditionalLB * priorLB) + (notConditionalUB * (1 - priorLB)));

  println ("prior (lb): ", priorLB, " cond (lb): ", conditionalLB, " not cond (ub): ", notConditionalUB, " posterior: ", posterior);
  
  return posterior;
}

int getLevel (float probability) {
  int percent = round (10000 * probability);
  if (percent <= 500) {
    return 0;
  } else if (percent <= 2000) {
    return 1;
  } else if (percent < 8000) {
    return 2;
  } else if (percent < 9500) {
    return 3;
  } else {
    return 4;
  }
}

void setup() {
  size (1400, 1400);
  background (255);
  stroke(100);
  translate (width/2, height/2);
  for (int i = 0; i < n; i ++) {
    int prior = i / 25;
    int conditional = (i / 5) % 5;
    int notConditional = i % 5;
    float posterior = posterior (prior, conditional, notConditional);
    int   posteriorLevel     = getLevel (posterior);

    switch (mode) {
      case Normal:
    
        ellipseMode (CENTER);
        pushMatrix ();
        rotate (2 * PI * i / n);
          // outer ring
          pushMatrix ();
          fill (getColor (prior));
          arc (0, 0, 1200, 1200, -offset, 2*PI/n - offset, PIE);
          popMatrix ();
          // middle ring
          pushMatrix ();
          fill (getColor (conditional));
          arc (0, 0, 1100, 1100, -offset, 2*PI/n - offset, PIE);
          popMatrix ();
          // inner ring
          pushMatrix ();
          fill (getColor (notConditional));
          arc (0, 0, 1000, 1000, -offset, 2*PI/n - offset, PIE);
          popMatrix ();
          // result ring
          pushMatrix ();
          fill (getColor (posteriorLevel));
          arc (0, 0, 900, 900, -offset, 2*PI/n - offset, PIE);
          popMatrix ();
        popMatrix ();
        fill (255);
        circle (0, 0, 800);
        break;
      case Bounded:
        float posteriorLB = posteriorLowerBound (prior, conditional, notConditional);
        float posteriorUB = posteriorUpperBound (prior, conditional, notConditional);
        int posteriorLBLevel = getLevel (posteriorLB);
        int posteriorUBLevel = getLevel (posteriorUB);
    
        ellipseMode (CENTER);
        pushMatrix ();
        rotate (2 * PI * i / n);
          // outer ring
          pushMatrix ();
          fill (getColor (prior));
          arc (0, 0, 1200, 1200, -offset, 2*PI/n - offset, PIE);
          popMatrix ();
          // middle ring
          pushMatrix ();
          fill (getColor (conditional));
          arc (0, 0, 1100, 1100, -offset, 2*PI/n - offset, PIE);
          popMatrix ();
          // inner ring
          pushMatrix ();
          fill (getColor (notConditional));
          arc (0, 0, 1000, 1000, -offset, 2*PI/n - offset, PIE);
          popMatrix ();
          // result ring - upper bound
          pushMatrix ();
          fill (getColor (posteriorUBLevel));
          arc (0, 0, 900, 900, -offset, 2*PI/n - offset, PIE);
          popMatrix ();
          // result ring - median value
          pushMatrix ();
          fill (getColor (posteriorLevel));
          arc (0, 0, 880, 880, -offset, 2*PI/n - offset, PIE);
          popMatrix ();
          // result ring - lower bound
          pushMatrix ();
          fill (getColor (posteriorLBLevel));
          arc (0, 0, 820, 820, -offset, 2*PI/n - offset, PIE);
          popMatrix ();
        popMatrix ();
        // result ring outline
        noFill ();
        strokeWeight (2);
        circle (0, 0, 900);
        strokeWeight (1); // back to the default value.
        // inner text area
        fill (255);
        circle (0, 0, 800);
        break;
    }
  }
  fill (100);
  text (
    "Outer Ring: The prior hypothesis - P (H)\nSecond Ring: The conditional probability - P (E|H)\nThird Ring: The contradiction probability - P (E|not H)\nInner Ring: the posterior probability - P (H).",
    -150, -75, 300, 300
  );
  fill (getColor (4));
  rect (-100, 0, 25, 25);
  fill (100);
  text ("Very Likely (≥ 95%)", -60, 0, 300, 50);

  fill (getColor (3));
  rect (-100, 25, 25, 25);
  fill (100);
  text ("Likely (≥ 80%)", -60, 25, 300, 50);

  fill (getColor (2));
  rect (-100, 50, 25, 25);
  fill (100);
  text ("Fair (50%)", -60, 50, 300, 50);

  fill (getColor (1));
  rect (-100, 75, 25, 25);
  fill (100);
  text ("Unlikely (≤ 20%)", -60, 75, 300, 50);

  fill (getColor (0));
  rect (-100, 100, 25, 25);
  fill (100);
  text ("Very Unlikely (≤ 5%)", -60, 100, 300, 50);
  
  textSize (25);
  fill (100);
  text ("The Evidence Colorwheel", -150, -125, 300, 50);

  switch (mode) {
    case Normal:
      save ("evidence_colorwheel.png");
      break;
    case Bounded:
      save ("evidence_colorwheel_bounded.png");
      break;
  }
}
