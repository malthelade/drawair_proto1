let video;
let poseNet;
let pose;
let drawings = []
let currentdrawings = []
let estimationWindowWidth = 5;
let x_estimation = []
let y_estimation = []
let current_point;
let smoothed_point;
let tracking_point;
let debug = false;
let estimationSlider;


function setup() {
  current_point = createVector(0, 0);
  smoothed_point = createVector(0, 0);
  createCanvas(900, 630)
  video = createCapture(VIDEO);
  video.size(900, 600);
  video.hide();
  poseNet = ml5.poseNet(video, modelLoaded);
  poseNet.on('pose', gotposes);
  estimationSlider = createSlider(1, 15, estimationWindowWidth, 1);
  estimationSlider.position(50, 600);
  estimationSlider.size(255);
  estimationSlider.hide();
}

function modelLoaded() {
  console.log('Model Ready');
}
// if the pose array has more indexes than 0 it will set the pose variabel to the first index in the poses array
function gotposes(poses) {
  if (poses.length > 0) {
    pose = poses[0].pose;
  }
  if (!pose) {
    console.log('pose empty')
    return
  }

  current_point = pose.rightWrist;

  if (mouseIsPressed == true && mouseButton === LEFT) {
    if (current_point) {

      // Estimate next point
      const pVec = estimatePoint(current_point)
      smoothed_point = pVec; // DEBUG
      // add point to drawing
      currentdrawings.push(pVec);
    }
  }
}

function estimatePoint(current_point) {

  x_estimation.push(current_point['x']);
  if (x_estimation.length > estimationWindowWidth) {
    x_estimation.shift();
  }

  y_estimation.push(current_point['y']);
  if (y_estimation.length > estimationWindowWidth) {
    y_estimation.shift();
  }

  //x average
  let x_sum = 0;
  for (const xVal of x_estimation) {
    x_sum += xVal;
  }
  const x_avg = x_sum / x_estimation.length;

  //y average
  let y_sum = 0;
  for (const yVal of y_estimation) {
    y_sum += yVal;
  }
  const y_avg = y_sum / y_estimation.length;

  return createVector(x_avg, y_avg)
}

//runs 60 times a second and is used to draw what is seen on the screen.
function draw() {
  background(0);
  image(video, 0, 0);
  render_drawing();
  if (currentdrawings.length > 0) {
    render_currentdrawing();
  }
  // debug mode code
  if (debug == true) {
    stroke('red')
    circle(current_point.x, current_point.y, 8); // DEBUG
    stroke('blue')
    circle(smoothed_point.x, smoothed_point.y, 20); // DEBUG
    estimationWindowWidth = estimationSlider.value();
    estimationSlider.show();
  } else {
    estimationWindowWidth = 5
    estimationSlider.hide();
  }
}

// debug mode code
function mousePressed() {
  if (mouseButton === RIGHT) {
    clearDrawings();
  }

  if (mouseButton === LEFT) {
    clearEstimaton();
  }
}

function mouseReleased() {
  if (mouseButton === LEFT) {
    if (currentdrawings.length > 0) {
      clone = currentdrawings.slice();
      drawings.push(clone);
    }
    currentdrawings = [];
  }
}
// activate debug mode
function keyPressed() {
  if (key == "d") {
    if (debug == false) {
      debug = true
    }
    else {
      (debug = false);
    }
  }
}



function render_drawing() {
  for (const drawing of drawings) {
    noFill();
    beginShape();
    stroke('red');
    strokeWeight(3);
    curveVertex(drawing[0].x, drawing[0].y)
    for (const p of drawing) {
      curveVertex(p.x, p.y);

    };
    const lastpoint = drawing[drawing.length - 1];
    curveVertex(lastpoint.x, lastpoint.y);
    endShape();

    //debug mode code
    if (debug == true) {
      beginShape();
      noFill();
      stroke('blue');
      strokeWeight(1);

      for (const p of drawing) {
        vertex(p.x, p.y);

      };

      endShape();
      //debug mode code 
    }
  }
}

function render_currentdrawing() {
  beginShape();
  noFill();
  stroke('red');
  strokeWeight(5);
  curveVertex(currentdrawings[0].x, currentdrawings[0].y)
  for (const p of currentdrawings) {
    curveVertex(p.x, p.y);
  };
  const lastpoint = currentdrawings[currentdrawings.length - 1];
  curveVertex(lastpoint.x, lastpoint.y)
  endShape();
}

function clearEstimaton() {
  x_estimation = [];
  y_estimation = [];
}

function clearDrawings() {
  drawings = [];
  console.log('cleared');
}
