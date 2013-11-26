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

Sprite player;
PImage playerImage;

Platform test;
PImage testImage;

Vehicle vehicleTest;

// Win lane
Lane winLane;

// Arraylist of water lanes, should be 5
ArrayList<Lane> waterLanes;

// Array list of road lanes, should be 3
ArrayList<Lane> roadLanes;

// starting lane
Lane startLane;
  
void setup() {
  size(GAME_WIDTH,GAME_HEIGHT);
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

void drawLanes() {
  
}
