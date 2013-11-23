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
  
void setup() {
  size(GAME_WIDTH,GAME_HEIGHT);
}

void draw() {
  background(GAME_BACKGROUND_COLOR);
}
