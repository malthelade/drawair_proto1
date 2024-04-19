let video;
let flippedVideo;
let poseNet;
let pose;
let drawings = []
let currentdrawings = []
const estimationWindowWidth = 5
let x_estimation = []
let y_estimation = []
let current_point;

function setup() {
  createCanvas(900, 600)
  video = createCapture(VIDEO);
  video.size(900, 600);
  video.hide();
  flippedVideo = ml5.flipImage(video);
  poseNet = ml5.poseNet(video, modelLoaded);
  poseNet.on('pose', gotposes);
}

function modelLoaded() {
  console.log('Model Ready');
}
// if the pose array has more indexes than 0 it will set the pose variabel to the first index in the poses array
function gotposes(poses) {
  if (poses.length > 0) {
    pose = poses[0].pose;
  }

  current_point = pose.rightWrist;

  if (mouseIsPressed == true && mouseButton === LEFT) {
    if (current_point) {

      // Estimate next point
      const pVec = estimatePoint(current_point)
      // add point to drawing
      currentdrawings.push(pVec);
    }
  }
}

function estimatePoint(current_point) {

  x_estimation.push(current_point['x']);
  if (x_estimation.length > estimationWindowWidth) {
    x_estimation.shift()
  }

  y_estimation.push(current_point['y']);
  if (y_estimation.length > estimationWindowWidth) {
    y_estimation.shift()
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
  translate(width, 0);
  scale(-1, 1);
  image(video, 0, 0);
  render_drawing();
  render_currentdrawing();
}

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

function render_drawing() {
  for (const drawing of drawings) {
    noFill();
    beginShape();
    stroke('pink');
    strokeWeight(10);
    for (const p of drawing) {
      vertex(p.x, p.y);
    };
    const lastpoint = drawing[drawing.length - 1];
    vertex(lastpoint.x, lastpoint.y);
    endShape();
  }
}


function render_currentdrawing() {
  beginShape();
  noFill();
  stroke('pink');
  strokeWeight(10);
  for (const p of currentdrawings) {
    vertex(p.x, p.y);
  };
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
