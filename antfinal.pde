import processing.serial.*;
Serial serial; // Serial port objects

import ddf.minim.*;
Minim minim;
// Sounds for every level
AudioPlayer level1Sound;
AudioPlayer level2Sound;
AudioPlayer level3Sound;
AudioPlayer conSound;

PImage level1, level2, level3; // Instructions for every level

int level = 1; // Current level

// Level 1 variables
int gridSize0 = 20; // Size of each grid cell
int cols, rs; // Number of columns and rows in the grid
int cX, cY; // Current positipon of the brush

boolean[][] grid0; // Array to store the state of each grid cell

color color1 = color(178, 216, 255); // Light blue
color color2 = color(190); // White

// Level 2 variables
int gridSize = 20; // Size of each grid cell
int columns, rows; // Number of columns and rows in the grid
int currentX, currentY; // Current position of the brush

boolean[][] grid; // Array to store the state of each grid cell

String moveSequence = ""; // String to store the sequence of key moves

boolean level2Passed = false; // Flag to track if Level 2 is passed

color color3 = color(0); // Black
color color4 = color(190); // White

// Level 3 variables
int[][] grid2;
int x;
int y;
int dir;

int Antu = 0;
int Antr = 1;
int Antd = 2;
int Antl = 3; // clockwise

int cellSize = 30; // Size of each square cell
int fr = 8;

color colorR, colorL, colorLR, colorRL; // Four colors for the RLLR scheme

boolean patternRunning = false; // Check if the pattern is running
boolean buttonPressed = false;  // Check if the button is pressed

int[][] originalGrid;
int[][] cellSizes;  // Array to store varying cell sizes

void setup() {
  size(900, 900);

// Load pictures of instruction
  level1 = loadImage("level1.png");
  level2 = loadImage("level2.png");
  level3 = loadImage("level3.png"); 

// Set every level
  if (level == 1) {
    setupLevel1();
  } else if (level == 2) {
    setupLevel2();
  } else if (level == 3) {
    setupLevel3();
  }

  String portName = "/dev/cu.usbmodem1301"; // Modify the serial port name as needed
  //String portName = "/dev/cu.usbmodem101"; // Modify the serial port name as needed
  serial = new Serial(this, portName, 9600);
}

void draw() {

  if (level == 1) {
    drawLevel1();
    image(level1, 0, 0, 300, 200);
    fill(0); // Black
    textSize(40);
    textAlign(LEFT, TOP);
    text("level 1", 700, 20); //need to be adjusted according to projection
  } else if (level == 2) {
    drawLevel2();
    image(level2, 0, 0, 350, 250);
    fill(255); // White
    textSize(40);
    textAlign(LEFT, TOP);
    text("level 2", 700, 20);
  } else if (level == 3) {
    drawLevel3();
    image(level3, 0, 0, 350, 250);
    fill(255); // White
    textSize(40);
    textAlign(LEFT, TOP);
    text("level 3", 700, 20);
    if (patternRunning) {
      moveAnt();
    }
  }
}

void j() {
  if (key == 'k') {
    level = 2; // Jump to Level 2
    setupLevel2(); // Setup Level 2
    level1Sound.pause();
  } else if (key == 'b') {
    level = 1; // Back to Level 1
    setupLevel1(); // Setup Level 1
    level2Sound.pause();
  } else if (key == 'j') { // Skip to Level3
    level = 3; // Jump to Level 3
    setupLevel3(); // Setup Level 3
    level2Sound.pause();
  } else if (key == 'p') {
    minim = new Minim(this);
    conSound = minim.loadFile("Conclusion.mp3");
    conSound.loop();
    level1Sound.pause();
    level2Sound.pause();
    level3Sound.pause();
  } else if (key == 's') {
    conSound.pause();
  } else if (level == 1) {
    keyPressedLevel1();
  } else if (level == 2) {
    keyPressedLevel2();
  } else if (level == 3) {
    keyPressedLevel3();
  }
}

void keyReleased() {
  if (level == 1) {
    keyReleasedLevel1();
  } else if (level == 2) {
    keyReleasedLevel2();
  } else if (level == 3) {
    keyReleasedLevel3();
  }
}

void setupLevel1() {

  gridSize0 = cellSize; // Size of each grid cell
  cols = width / gridSize0; // Calculate the number of columns
  rs = height / gridSize0; // Calculate the number of rows
  cX = cols / 2; // Start at the center column
  cY = rs / 2; // Start at the center row
  grid0 = new boolean[cols][rs]; // Initialize the grid array

  minim = new Minim(this);
  level1Sound = minim.loadFile("Level1.mp3");
  level1Sound.loop();

  // Set all cells to false (not colored)
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rs; y++) {
      grid0[x][y] = false;
    }
  }
}

void drawLevel1() {

  serialEvent1(serial);

  //  Draw background
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    color c = lerpColor(color1, color2, inter);
    stroke(c);
    line(0, y, width, y);
  }

  // Draw the grid
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rs; y++) {
      float xPos = x * gridSize0;
      float yPos = y * gridSize0;

      noStroke();
      if (grid0[x][y]) {
        if (x == cX && y == cY) {
          // If the current cell is the highlighted cell, make it blink
          if (frameCount % 30 < 10) {
            fill(0, 100); // Set the fill color to black for colored cells
          } else {
            fill(255, 100); // Set the fill color to white for colored cells
          }
        } else {
          fill(0, 100); // Set the fill color to black for colored cells
        }
      } else {
        fill(255, 100); // Set the fill color to white for uncolored cells
      }

      stroke(255, 100); // Set the stroke color to white
      strokeWeight(5); // Set the stroke weight to 5
      rect(xPos, yPos, cellSize*1.2, cellSize*1.2); // Draw the grid cell
    }
  }
}

void keyPressedLevel1() {
  if (key == 'r') {
    println("Reset");
    setupLevel1();
    redraw();
  }

  // Store the key moves in the string
  if (keyCode == LEFT) {
    moveSequence += "L";
    println("L");
  } else if (keyCode == RIGHT) {
    moveSequence += "R";
    println("R");
  } 

  // Check the move sequence for the specified patterns and move accordingly
  if (moveSequence.endsWith("LRR")) {
    // Move one step to the right
    cX = min(cX + 1, cols - 1);
    moveSequence = "";
  } else if (moveSequence.endsWith("RLL")) {
    // Move one step to the left
    cX = max(cX - 1, 0);
    moveSequence = "";
  } else if (moveSequence.endsWith("LRL")) {
    // Move one step up
    cY = max(cY - 1, 0);
    moveSequence = "";
  } else if (moveSequence.endsWith("RLR")) {
    // Move one step down
    cY = min(cY + 1, rs - 1);
    moveSequence = "";
  }

  // Color the current cell black
  grid0[cX][cY] = true;
}

void keyReleasedLevel1() {
  // Add key release behavior if needed
}

void setupLevel2() {
  
  gridSize = cellSize; // Size of each grid cell
  columns = width / gridSize; // Calculate the number of columns
  rows = height / gridSize; // Calculate the number of rows
  currentX = columns / 2; // Start at the center column
  currentY = rows / 2; // Start at the center row
  grid = new boolean[columns][rows]; // Initialize the grid array

  minim = new Minim(this);
  level2Sound = minim.loadFile("Level2.mp3");
  level2Sound.loop();

  // Set all cells to false (not colored)
  for (int x = 0; x < columns; x++) {
    for (int y = 0; y < rows; y++) {
      grid[x][y] = false;
    }
  }
}

void drawLevel2() {

  serialEvent2(serial);

  //  Draw background
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    color c = lerpColor(color3, color4, inter);
    stroke(c);
    line(0, y, width, y);
  }

  // Draw the grid
  for (int x = 0; x < columns; x++) {
    for (int y = 0; y < rows; y++) {
      float xPos = x * gridSize;
      float yPos = y * gridSize;

      noStroke();

      if (grid[x][y]) {
        if (x == currentX && y == currentY) {
          // If the current cell is the highlighted cell, make it blink
          if (frameCount % 30 < 10) {
            fill(0, 100); // Set the fill color to black for colored cells
          } else {
            fill(255, 100); // Set the fill color to white for colored cells
          }
        } else {
          fill(0, 100); // Set the fill color to black for colored cells
        }
      } else {
        fill(255, 100); // Set the fill color to white for uncolored cells
      }

      stroke(255, 100); // Set the stroke color to white
      strokeWeight(5); // Set the stroke weight to 2
      rect(xPos, yPos, cellSize*1.2, cellSize*1.2); // Draw the grid cell
      //  rect(xPos, yPos, cellSize * 2, cellSize * 2); // Draw the rectangle around the grid cell
    }
  }



  // Check if Level 2 is passed
  if (!level2Passed && checkLevel2Passed()) {
    level2Passed = true;
    println("Level 2 passed!");
    level = 3; // Switch to Level 3
    setupLevel3(); // Setup Level 3
    level2Sound.pause();
  }
}

boolean checkLevel2Passed() {
  // Check if a 4x4 area is filled with black cells
  for (int startX = 0; startX < columns - 3; startX++) {
    for (int startY = 0; startY < rows - 3; startY++) {
      boolean levelComplete = true;
      for (int x = startX; x < startX + 4; x++) {
        for (int y = startY; y < startY + 4; y++) {
          if (!grid[x][y]) {
            levelComplete = false;
            break;
          }
        }
        if (!levelComplete) {
          break;
        }
      }
      if (levelComplete) {
        return true;
      }
    }
  }
  return false;
}

void keyPressedLevel2() {
  // Store the key moves in the string
  if (keyCode == LEFT) {
    moveSequence += "L";
    println("L");
  } else if (keyCode == RIGHT) {
    moveSequence += "R";
    println("R");
  } 

  // Check the move sequence for the specified patterns and move accordingly
  if (moveSequence.endsWith("LRR")) {
    // Move one step to the right
    currentX = min(currentX + 1, columns - 1);
    moveSequence = "";
  } else if (moveSequence.endsWith("RLL")) {
    // Move one step to the left
    currentX = max(currentX - 1, 0);
    moveSequence = "";
  } else if (moveSequence.endsWith("LRL")) {
    // Move one step up
    currentY = max(currentY - 1, 0);
    moveSequence = "";
  } else if (moveSequence.endsWith("RLR")) {
    // Move one step down
    currentY = min(currentY + 1, rows - 1);
    moveSequence = "";
  }

  // Color the current cell black
  grid[currentX][currentY] = true;
}

void keyReleasedLevel2() {
  // Add key release behavior if needed
}

void setupLevel3() {
  frameRate(fr);
  x = width / 2;
  y = height / 2;
  dir = Antu;
  // Initialize the grid with dimensions equal to the canvas size divided by cell size
  grid2 = new int[width / cellSize][height / cellSize];
  // Initialize the cellSizes array
  cellSizes = new int[grid2.length][grid2[0].length];
  for (int i = 0; i < grid2.length; i++) {
    for (int j = 0; j < grid2[0].length; j++) {
      cellSizes[i][j] = cellSize;
    }
  }

  colorR = generateRColor();    // Random color
  colorL = generateRColor();    
  colorLR = generateRColor();  
  colorRL = generateRColor();   

  //  frameRate(fr);

  minim = new Minim(this);
  level3Sound = minim.loadFile("Level3.mp3");
  level3Sound.loop();
}

void drawLevel3() {

  //  background(255);
  //draw gradient background
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    color c = lerpColor(color3, color4, inter);
    stroke(c);
    line(0, y, width, y);
  }

  for (int i = 0; i < grid2.length; i++) {
    for (int j = 0; j < grid2[0].length; j++) {
      if (grid2[i][j] == Antu) {
        fill(0, 200);
      } else if (grid2[i][j] == Antr) {
        fill(colorL);
      } else if (grid2[i][j] == Antd) {
        fill(colorLR);
      } else if (grid2[i][j] == Antl) {
        fill(colorRL);
      }
      int xPos = i * cellSize;
      int yPos = j * cellSize;
      stroke(255, 100);
      strokeWeight(6);
      //noStroke();
      rect(xPos, yPos, cellSize*0.9, cellSize*0.9);
    }
  }

  serialEvent3(serial);

  moveAnt();
  
}

void keyPressedLevel3() {
  if (keyCode == LEFT) {
    moveSequence += "L";
    println("L");
  } else if (keyCode == RIGHT) {
    moveSequence += "R";
    println("R");
  }


  if (!patternRunning ) {
    if (moveSequence.endsWith("LRR") || moveSequence.endsWith("RLL") || 
      moveSequence.endsWith("LRL") || moveSequence.endsWith("RLR")) {
      patternRunning = true;
    }
  }
}


void keyReleasedLevel3() {
  // Add key release behavior if needed
  if (keyCode == LEFT || keyCode == RIGHT) {
    patternRunning = false;
  }
}

void moveAnt() {
  int currentCellX = x / cellSize;
  int currentCellY = y / cellSize;
  int currentState = grid2[currentCellX][currentCellY];

  if (buttonPressed && patternRunning) {
    if (currentState == Antu) {
      turnRight();
      grid2[currentCellX][currentCellY] = Antr;
    } else if (currentState == Antr) {
      turnLeft();
      grid2[currentCellX][currentCellY] = Antd;
    } else if (currentState == Antd) {
      turnLeft();
      grid2[currentCellX][currentCellY] = Antl;
    } else if (currentState == Antl) {
      turnRight();
      grid2[currentCellX][currentCellY] = Antu;
    }

    moveForward();

    buttonPressed = false;  // Reset the button to false
    patternRunning = false;
  }
}


void turnRight() {
  dir++;
  if (dir > Antl) {
    dir = Antu;
  }
}

void turnLeft() {
  dir--;
  if (dir < Antu) {
    dir = Antl;
  }
}

void moveForward() {
  if (dir == Antu) {
    y -= cellSize;
  } else if (dir == Antr) {
    x += cellSize;
  } else if (dir == Antd) {
    y += cellSize;
  } else if (dir == Antl) {
    x -= cellSize;
  }
}



color generateRColor() {
  int r = (int) random(90, 256);   // Random red component between 100 and 255
  int g = (int) random(50, 150);   // Green component is set to 0
  int b = (int) random(30, 180);   // Random blue component between 150 and 255
  float alp = 180;
  return color(r, g, b, alp);
}

void serialEvent1(Serial serial) {
  String input = serial.readStringUntil('\n');

  if (input != null) {
    input = input.trim();

    if (input.equals("LEFT")) {
      moveSequence += "L";
      println("Left!");
    } else if (input.equals("RIGHT")) {
      moveSequence += "R";
      println("Right!");
    } else if (input.equals("SKIP")) {
      level = 2; // Jump to Level 1
      setupLevel2(); // Setup Level 1
      level1Sound.pause();
      println("Skip");
    } 

    if (moveSequence.endsWith("LRR")) {
      cX = min(cX + 1, cols - 1);
      moveSequence = "";
    } else if (moveSequence.endsWith("RLL")) {
      cX = max(cX - 1, 0);
      moveSequence = "";
    } else if (moveSequence.endsWith("LRL")) {
      cY = max(cY - 1, 0);
      moveSequence = "";
    } else if (moveSequence.endsWith("RLR")) {
      cY = min(cY + 1, rs - 1);
      moveSequence = "";
    }
    grid0[cX][cY] = true;
  }
}

void serialEvent2(Serial serial) {
  String input = serial.readStringUntil('\n');

  if (input != null) {
    input = input.trim();

    if (input.equals("LEFT")) {
      moveSequence += "L";
      println("Left!");
    } else if (input.equals("RIGHT")) {
      moveSequence += "R";
      println("Right!");
    } else if (input.equals("BACK")) {
      level = 1; // Back to Level 1
      setupLevel1(); // Setup Level 1
      level2Sound.pause();
      println("Back");
    }

    if (moveSequence.endsWith("LRR")) {
      currentX = min(currentX + 1, columns - 1);
      moveSequence = "";
    } else if (moveSequence.endsWith("RLL")) {
      currentX = max(currentX - 1, 0);
      moveSequence = "";
    } else if (moveSequence.endsWith("LRL")) {
      currentY = max(currentY - 1, 0);
      moveSequence = "";
    } else if (moveSequence.endsWith("RLR")) {
      currentY = min(currentY + 1, rows - 1);
      moveSequence = "";
    }
    grid[currentX][currentY] = true;
  }
}

void serialEvent3(Serial serial) {
  String input = serial.readStringUntil('\n');

  if (input != null) {
    input = input.trim();

    if (input.equals("LEFT")) {
      moveSequence += "L";
      println("Left!");
    } else if (input.equals("RIGHT")) {
      moveSequence += "R";
      println("Right!");
    } else if (input.equals("BACK")) {
      level = 1; // Back to Level 1
      setupLevel1(); // Setup Level 1
      level3Sound.pause();
      println("Back");
    }

    if (!patternRunning ) {
      if (moveSequence.endsWith("LRR") || moveSequence.endsWith("RLL") || 
        moveSequence.endsWith("LRL") || moveSequence.endsWith("RLR")) {
        patternRunning = true;
        buttonPressed = true;  // 按钮被按下  
        moveSequence = "";
      }
    }
  }
}
