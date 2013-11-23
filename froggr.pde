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

Sprite player;
PImage playerImage;

Platform test;
PImage testImage;
  
void setup() {
  size(GAME_WIDTH,GAME_HEIGHT);
  playerImage = loadImage("sprites/player/player-idle.gif");
  player = new Sprite(playerImage, 50, 50);
  testImage = loadImage("sprites/player/player-death.gif");
  test = new Platform(200, 300, MovingSprite.DIRECTION_LEFT, Platform.LOG, 3);
}

void draw() {
  background(GAME_BACKGROUND_COLOR);
  player.display();
  test.display();
  if (player.hasCollidedWith(test, 0)) {
    println("collision");
  } else {
    println("no collision");
  }
}
