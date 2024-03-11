//Minh Le Quynh Cao, 46822097
//[x] I declare that I have not seen anyone else's code
//[x] I declare that I haven't shown my code to anyone else.

final int N_LANES = 5;
final int N_CARS_IN_LANE = 3;
final int MIN_GAP = 100;
final int MAX_LIVES = 3;
final int WIN_SCORE = 3;

//Global lane variable declaration.
float currentLane;

//Global car variables declaration.
float[][] carX = new float[N_LANES][N_CARS_IN_LANE];
float[][] carWidth = new float[N_LANES][N_CARS_IN_LANE];
float[][] carSpeed = new float[N_LANES][N_CARS_IN_LANE];
color[][] carColor = new color[N_LANES][N_CARS_IN_LANE];

boolean movingCar;

float minSpeed = 1;
float maxSpeed = 7;

//Global pedestrian variables declaration.
float pedestrianX;
float pedestrianY;
float pedestrianHeight;

boolean movingPedestrian;

//Global lives left & win score variables declaration.
int lives;
int score;

void reset() {
  
  //Each lane height setup
  currentLane = height/2/N_LANES;
  
  //Cars setup
  movingCar = true;
  for (int i = 0; i < N_LANES; i++) {
    for (int k = 0; k < N_CARS_IN_LANE; k++) {
      carX[i][k] = random(width);
      carWidth[i][k] = random(width/24, width/10);
      carSpeed[i][k] = random(minSpeed, maxSpeed);
      carColor[i][k] = color(random(255), random(225), random(255));
    }
  }

  //Pedestrian setup
  movingPedestrian = true;
  pedestrianHeight = currentLane*0.8;
  pedestrianX = width/2;
  pedestrianY = height-pedestrianHeight/2-currentLane*0.1;
  
  //Lives left setup
  lives = MAX_LIVES;
  
  //Win score setup
  score = 0;
}
  
void setup() {
  size(1200, 400);
  reset();
}

void draw() {
  background(255);
  multiLanes();
  multiCars();
  pedestrianDisplay(pedestrianX, pedestrianY, pedestrianHeight);
  livesLeft();
  score();
}

//Multiple lanes implementation
void multiLanes() {
  int lane = height/2;
  for (int i = 0; i <= lane; i+=lane/N_LANES) {
    lanes(0, i);
  }
}

//Display dashed-line lane
void lanes(int lineLength, int lineHeight) {
  for (lineLength = 0; lineLength < width; lineLength+=3) {
    line(lineLength, lineHeight, lineLength+4, lineHeight);
    strokeWeight(1);
    if (lineLength%2 == 0) {
      stroke(0); 
    }
    else {
      stroke(255); 
    }
  }
}

//Multiple vehicles implementation
void multiCars() {
  for (int iLane = 0; iLane < N_LANES; iLane++) {
    for (int nCars = 0; nCars < N_CARS_IN_LANE; nCars++) {
        
      //Display multiple vehicles
      carDisplay(carX[iLane][nCars], iLane*currentLane, carWidth[iLane][nCars], currentLane*0.8, carColor[iLane][nCars]); 
      
      //Move the vehicles
      if(movingCar){
        for (int i = 0; i < carSpeed[iLane][nCars]; i++) {
          carX[iLane][nCars]++;
        } 
        
        //Check the overlap and gap between vehicles
        for (int k = 0; k < nCars; k++) { // k<nCars: for comparing between current car and displayed cars.
        
          // In case the current car is faster than displayed car.
          if (carX[iLane][nCars] > carX[iLane][k]) { 
            float mostLeft = carX[iLane][nCars]-carWidth[iLane][nCars]/2; // Last point of the current car frame.
            float mostRight = carX[iLane][k]+carWidth[iLane][k]/2; // First point of the displayed car frame.
            if (mostLeft - mostRight <=0) { // In case the displayed car overlaps the current car.
              carSpeed[iLane][k] = carSpeed[iLane][nCars]*0.1; // Decrease the speed of displayed car.
            }
            else if (mostLeft - mostRight > 0 && mostLeft-mostRight <= MIN_GAP){ // In case there is no overlap between cars.
              carSpeed[iLane][k] = carSpeed[iLane][nCars]; // Cars speed becomes the same when the gap of cars is lower than MIN_GAP.
            }
          }
          
          // In case the displayed car is faster than the current car.
          else { 
            float mostLeft = carX[iLane][k]-carWidth[iLane][k]/2; // Last point of the displayed car frame.
            float mostRight = carX[iLane][nCars]+carWidth[iLane][nCars]/2; // First point of the current car frame.
            if (mostLeft - mostRight <= 0) { // In case the current car overlaps the displayed car.
              carSpeed[iLane][nCars] = carSpeed[iLane][k]*0.1; // Decrease the speed of current car.
            }
            else if (mostLeft - mostRight > 0 && mostLeft-mostRight <= MIN_GAP) { // In case there is no overlap between cars
              carSpeed[iLane][nCars] = carSpeed[iLane][k]; // Cars speed becomes the same when the gap of cars is lower than MIN_GAP.
            }
          }
        }
        
        // Vehicle comes back after it left the screen.
        if (carX[iLane][nCars] > width + carWidth[iLane][nCars]/2) {
          carX[iLane][nCars] = -carWidth[iLane][nCars];
          carSpeed[iLane][nCars] = random(minSpeed, maxSpeed);
        }
      }
      
      //Collision detection
      if (pedestrianX + pedestrianHeight/2 > carX[iLane][nCars] - carWidth[iLane][nCars]/2 &&
          pedestrianX - pedestrianHeight/2 < carX[iLane][nCars] + carWidth[iLane][nCars]/2 &&
          pedestrianY + pedestrianHeight/2 > iLane*currentLane - currentLane*0.8/2 && //iLane*currentLane is the carY of carDisplay().
          pedestrianY - pedestrianHeight/2 < iLane*currentLane + currentLane*0.8/2) { //currentLane*0.8 is the frameHeight of carDisplay().
        pedestrianX = width/2;
        pedestrianY = height - pedestrianHeight/2 - currentLane*0.1; 
        lives--;
        livesLeft();
      }
    }    
  }
}

//Display vehicle
void carDisplay(float bigCarX, float carY, float frameWidth, float frameHeight, color colour) { 
  rectMode(CENTER);
  stroke(0);
  
  //Big car frame
  fill(colour);
  rect(bigCarX, carY + frameHeight/2/0.8, frameWidth, frameHeight, 30);
  
  //Medium car frame
  fill(255);
  rect(bigCarX - frameWidth*0.1, carY + frameHeight/2/0.8, frameWidth*6/11, frameHeight, 30); 
  
  //Small car frame
  fill(colour);
  rect(bigCarX - frameWidth*0.1, carY + frameHeight/2/0.8, frameWidth*3/10, frameHeight*3/4, 10); 
}

//Display pedestrian
void pedestrianDisplay(float pedX, float pedY, float pedHeight) {
  noStroke();
  rectMode(CENTER);
  fill(255, 170, 0);
  rect(pedX, pedY, pedHeight*2, pedHeight, 50);
  fill(75);
  circle(pedX, pedY, pedHeight);
}
   
//Pedestrian implementation
void keyPressed() {
  if (movingPedestrian) {
    if (key == CODED) {
      if (keyCode == UP) {
        pedestrianY-=currentLane;
      } 
      else if (keyCode == DOWN) {
        pedestrianY+=currentLane;
      } 
      else if (keyCode == LEFT) {
        pedestrianX-=currentLane;
      } 
      else {
        pedestrianX+=currentLane;
      }
    }
    if (pedestrianX<0) {
      pedestrianX = pedestrianHeight; 
    }
    else if (pedestrianX>width) {
      pedestrianX = width - pedestrianHeight; 
    }
    else if (pedestrianY>height) {
      pedestrianY = height-pedestrianHeight/2 - currentLane*0.1;
    }
  }
  
  //Reset the game.
  if (key == ' ') {
    reset();
  }
}

//Display lives left
void livesLeft() {
  fill(0);
  textSize(width/60);
  text("Lives Left: "+lives, width-width*5/24, height-height/16);
  if (lives == 0) {
    youLose();    
  }
}

//Game over scenario
void youLose() {
    movingCar = false; 
    movingPedestrian = false;
    background(255);
    fill(0);
    textSize(width/16);
    text("Game Over", width/3, height/2);
    textSize(width/36);
    text("Press spacebar to restart", width/3, height*3/5);
}

//Display score
void score() {
  fill(0);
  textSize(width/60);
  text("Score: "+score, width-width/12, height-height/16);
  if (pedestrianY<0) {
    score++;
    pedestrianX = width/2;
    pedestrianY = height - pedestrianHeight/2 - currentLane*0.1;
  }
  if (score == WIN_SCORE) {
    youWin();
  }
}

//Win scenario
void youWin() {
  movingCar = false;
  movingPedestrian = false;
  background(255);
  fill(0);
  textSize(width/15);
  text("You Win", width*3/8, height/2);
  textSize(width/36);
  text("Press spacebar to restart", width/3, height*3/5);
}
