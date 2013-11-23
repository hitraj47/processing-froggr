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
  
void setup() {
  size(GAME_WIDTH,GAME_HEIGHT);
  playerImage = loadImage("sprites/player/player-idle.gif");
  player = new Sprite(playerImage, 50, 50);
}

void draw() {
  background(GAME_BACKGROUND_COLOR);
  player.display();
}
