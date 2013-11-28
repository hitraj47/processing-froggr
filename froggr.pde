/**
 * Width of the game in pixels.
 */
public static final int GAME_WIDTH = 500;

/**
 * Height of the game in pixels.
 */
public static final int GAME_HEIGHT = 700;

/**
 * Background color of the screen
 */
public final color GAME_BACKGROUND_COLOR = color(0,0,0);

// lane height in pixels
public static final int LANE_HEIGHT = 50;

// how many pixels is one space of movement
public static final int MOVE_AMOUNT = 50;

// number of lives the player starts with
public static final int STARTING_LIVES = 3;

// number of each type of lane
int numWaterLanes;
int numSafeLanes;
int numRoadLanes;

// the player
Player player;

// Win lane
Lane winLane;

// water lanes
ArrayList<Lane> waterLanes = new ArrayList<Lane>();

// safe lanes
ArrayList<Lane> safeLanes = new ArrayList<Lane>();

// road lanes
ArrayList<Lane> roadLanes = new ArrayList<Lane>();

// starting lane
Lane startLane;

// the x position of where the player starts
int playerStartX;

// boundaries so the player doesn't go off screen
int leftBound;
int rightBound;
int bottomBound;
  
void setup() {
  size(GAME_WIDTH,GAME_HEIGHT);
  
  numWaterLanes = 5;
  numSafeLanes = 2;
  numRoadLanes = 4;
  setupLanes(numWaterLanes, numSafeLanes, numRoadLanes);
  
  // set boundaries
  leftBound = 0;
  rightBound = width;
  bottomBound = height - LANE_HEIGHT;
  
  playerStartX = 200;  
  player = new Player(playerStartX, GAME_HEIGHT - (2 * LANE_HEIGHT), STARTING_LIVES);
}

void draw() {
  background(GAME_BACKGROUND_COLOR);
  drawLanes();
  player.display();
}

void keyPressed() {
  if (keyCode == UP) {
    if (player.getY() - MOVE_AMOUNT >= 0) {
      player.moveForward(MOVE_AMOUNT);
    }
  } else if (keyCode == DOWN) {
    if(player.getY() + MOVE_AMOUNT < bottomBound) {
      player.moveBack(MOVE_AMOUNT);
    }
  } else if (keyCode == LEFT) {
    if (player.getX() - MOVE_AMOUNT >= leftBound) {
      player.moveLeft(MOVE_AMOUNT);
    }
  } else if (keyCode == RIGHT) {
    if (player.getX() + MOVE_AMOUNT < rightBound) {
      player.moveRight(MOVE_AMOUNT);
    }
  }
}

void setupLanes(int _numWaterLanes, int _numSafeLanes, int _numRoadLanes) {
  
  // start at the top
  int y = 0;
  
  // win lane
  winLane = new Lane(0, 0, Lane.LANE_WIN);
  y = y + LANE_HEIGHT;
  
  // water lanes
  for (int i = 0; i < _numWaterLanes; i++) {
    waterLanes.add(new Lane(0, y, Lane.LANE_WATER));
    y = y + LANE_HEIGHT;
  }
  
  // safe lanes
  for (int i = 0; i < _numSafeLanes; i++) {
    safeLanes.add(new Lane(0, y, Lane.LANE_GRASS));
    y = y + LANE_HEIGHT;
  }
  
  // top road
  roadLanes.add(new Lane(0, y, Lane.LANE_ROAD_TOP));
  y = y + LANE_HEIGHT;
  
  // middle road lanes
  for (int i = 0; i < _numRoadLanes-2; i++) {
    roadLanes.add(new Lane(0, y, Lane.LANE_ROAD_MIDDLE));
    y = y + LANE_HEIGHT;
  }
  
  // bottom road
  roadLanes.add(new Lane(0, y, Lane.LANE_ROAD_BOTTOM));
  y = y + LANE_HEIGHT;
  
  // start lane
  startLane = new Lane(0, y, Lane.LANE_GRASS);
  
}

void drawLanes() {
  
  // draw the lanes starting from the top
  winLane.display();
  
  for (Lane l : waterLanes) {
    l.display();
  }
  
  for (Lane l : safeLanes) {
    l.display();
  }
  
  for (Lane l : roadLanes) {
    l.display();
  }
  
  startLane.display();
}
