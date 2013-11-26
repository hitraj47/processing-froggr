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

// number of each type of lane
int numWaterLanes;
int numSafeLanes;
int numRoadLanes;

Sprite player;
PImage playerImage;

Platform test;
PImage testImage;

Vehicle vehicleTest;

// Win lane
Lane winLane;

// water lanes
ArrayList<Lane> waterLanes;

// safe lanes
ArrayList<Lane> safeLanes;

// road lanes
ArrayList<Lane> roadLanes;

// starting lane
Lane startLane;
  
void setup() {
  size(GAME_WIDTH,GAME_HEIGHT);
  
  numWaterLanes = 5;
  numSafeLanes = 2;
  numRoadLanes = 4;
  setupLanes(numWaterLanes, numSafeLanes, numRoadLanes);
  
  playerImage = loadImage("sprites/player/player-idle.gif");
  player = new Sprite(playerImage, 50, 50);
  testImage = loadImage("sprites/player/player-death.gif");
  test = new Platform(200, 300, MovingSprite.DIRECTION_LEFT, Platform.LILY, 3);
  vehicleTest = new Vehicle( 200, 450, MovingSprite.DIRECTION_LEFT, Vehicle.RED_CAR, 2);
}

void draw() {
  background(GAME_BACKGROUND_COLOR);
  drawLanes();
  player.display();
  test.display();
  vehicleTest.display();
  if (player.hasCollidedWith(test, 0)) {
    println("collision");
  } else {
    println("no collision");
  }
}

void setupLanes(int _numWaterLanes, int _numSafeLanes, int _numRoadLanes) {
  
  // start at the top
  int y = 0;
  
  // win lane
  winLane = new Lane(0, 0, Lane.LANE_WIN);
  y = y + LANE_HEIGHT;
  
  // water lanes
  
  
}

void drawLanes() {
  
  // draw first lane from the top, the win lane
}
