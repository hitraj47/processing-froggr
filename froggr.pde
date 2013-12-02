import gifAnimation.*;
import SimpleOpenNI.*;
import java.util.Map;
import ddf.minim.*;
import java.util.Iterator;

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
public final color GAME_BACKGROUND_COLOR = color(0, 0, 0);

// lane height in pixels
public static final int LANE_HEIGHT = 50;

// how many pixels is one space of movement
public static final int MOVE_AMOUNT = 50;

// number of lives the player starts with
public static final int STARTING_LIVES = 3;

/**
 * The nextPointsPosition keeps track of the next YPos the user must reach
 * to gain NEW_LANE_POINTS.
 */
private int nextPointsPosition = 600;

/**
 * Points that are earned when a fly is consumed.
 */
private final int CONSUME_FLY_BONUS = 100;

/**
 * Points that are earned when entering a lane for the first time.
 */
private final int NEW_LANE_POINTS = 25;

public static final String HOP = "sounds/player-movement.wav";
public static final String COLLISION = "sounds/sprite-collision.wav";
public static final String SPLASH = "sounds/splash.wav";
public static final String VICTORY = "sounds/victory.wav";

int flysConsumed = 0;

int score = 0;

boolean gameWon;
boolean gameOver;

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

// platforms
ArrayList<Platform> platforms = new ArrayList<Platform>();

// vehicles
ArrayList<Vehicle> vehicles = new ArrayList<Vehicle>();

// starting lane
Lane startLane;

private ArrayList<Fly> flys = new ArrayList<Fly>();

// the x position of where the player starts
int playerStartX;

// boundaries so the player doesn't go off screen
int leftBound;
int rightBound;
int bottomBound;

// keep track of time...
long time;
long kinectTime;

// regen times for lanes
long regen;

// kinect stuff
SimpleOpenNI context;
int handVecListSize = 20;
Map<Integer, ArrayList<PVector>>  handPathList = new HashMap<Integer, ArrayList<PVector>>();
color[]       userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};
PVector origin;

// speed of moving objects
int speed;

// a PApplet class referring to this, for use with animated gifs
public static PApplet applet;

// variable to determine whether in applet mode
boolean appletMode = false;

// width of kinect input area
public static final int KINECT_INPUT_AREA_WIDTH = 300;

// restart game button
Button btnRestart;

void setup() {
  applet = this;
  kinectTime = millis();
  if (appletMode) {
    size(GAME_WIDTH, GAME_HEIGHT);
  } 
  else {
    size(GAME_WIDTH+KINECT_INPUT_AREA_WIDTH, GAME_HEIGHT);
  }

  gameWon = false;
  gameOver = false;
  numWaterLanes = 5;
  numSafeLanes = 2;
  numRoadLanes = 4;
  setupLanes(numWaterLanes, numSafeLanes, numRoadLanes);
  createFlys();

  // set boundaries
  leftBound = 0;
  rightBound = GAME_WIDTH;
  bottomBound = height - LANE_HEIGHT;

  playerStartX = 250;  
  player = new Player(playerStartX, GAME_HEIGHT - (2 * LANE_HEIGHT), STARTING_LIVES);

  // start up kinect
  if (!appletMode) {
    context = new SimpleOpenNI(this);
    if (context.isInit() == false) {
      println("Can't init SimpleOpenNI, maybe the camera isn't connected!");
      // set speed slower to compensate for no kinect
      speed = 1;
      // lane regen
      regen = 6000;
    } 
    else {
      /*
    * set this speed to 2 when kinect is connected for regular speed.
       * set at 1 for now because 2 is a little difficult with kinect
       */
      speed = 1;

      // with kinect, the lane regen needs to be increased
      // so platforms dont overlap
      regen = 10000;
    }
    context.enableDepth();
    context.enableHand();
    context.startGesture(SimpleOpenNI.GESTURE_WAVE);
  } 
  else {
    speed = 1;
    regen = 6000;
  }

  btnRestart = new Button("Restart Game", GAME_WIDTH/2 + 100, GAME_HEIGHT - 30, 100, 30);
  btnRestart.setBorderColor(0, 255, 0);
  btnRestart.setLabelColor(0, 128, 0);

  // set time to negative regen so it draws stuff when game loads
  time = -regen;
}

void draw() {
  // update kinect cam
  if (!appletMode) {
    context.update();
  }

  background(GAME_BACKGROUND_COLOR);
  drawLanes();
  drawFlys();
  generateMovingSprites();
  drawMovingPlatforms();
  processPlayer();
  drawMovingVehicles();
  drawPlayerLives();
  processGameplay();
  drawRestartButton();
  
  if (!appletMode) {
    drawInputInfo();
    drawTrackedHands();
  }
}

void drawRestartButton() {
  if (gameWon || gameOver) {
    btnRestart.display();
    if (btnRestart.isMouseOverButton()) {
      btnRestart.setUpdating(true);
    } 
    else {
      btnRestart.setUpdating(false);
    }
  } 
  else {
    fill(GAME_BACKGROUND_COLOR);
    rectMode(CORNER);
    noStroke();
    rect(btnRestart.getXPosition()-btnRestart.getWidth()/2, GAME_HEIGHT - LANE_HEIGHT, btnRestart.getWidth(), LANE_HEIGHT);
  }
}

void mousePressed() {
  if (btnRestart.isMouseOverButton()) {
    btnRestart.setUpdating(true);
  }
}

void mouseReleased() {
  if (btnRestart.isMouseOverButton()) {
    if (gameWon || gameOver) {
      restartGame();
    }
  }
}

void restartGame() {
  // set all flys to, er, not consumed
  for (Fly f : flys) {
    f.setConsumed(false);
  }
  flysConsumed = 0;

  // reset game won/over variables
  gameWon = false;
  gameOver = false;

  // reset score
  score = 0;

  // remove all moving sprites
  vehicles.clear();
  platforms.clear();

  // reset time
  time = -regen;
}

void drawInputInfo() {
  noStroke();
  fill(GAME_BACKGROUND_COLOR);
  rectMode(CORNER);
  rect(GAME_WIDTH, 0, KINECT_INPUT_AREA_WIDTH, height);
}

void drawTrackedHands() {
  // draw the tracked hands
  if (handPathList.size() > 0)  
  {    
    Iterator itr = handPathList.entrySet().iterator();     
    while (itr.hasNext ())
    {
      Map.Entry mapEntry = (Map.Entry)itr.next(); 
      int handId =  (Integer)mapEntry.getKey();
      ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
      PVector p;
      PVector p2d = new PVector();

      stroke(userClr[ (handId - 1) % userClr.length ]);
      noFill(); 
      strokeWeight(1);         

      if (vecList.size() > 0) {
        PVector currentPoint = vecList.get(0);
        PVector currentPoint2d = new PVector();
        PVector lastPoint = vecList.get(vecList.size()-1);
        PVector lastPoint2d = new PVector();
        context.convertRealWorldToProjective(currentPoint, currentPoint2d);
        context.convertRealWorldToProjective(lastPoint, lastPoint2d);
        PVector origin2d = new PVector();
        context.convertRealWorldToProjective(origin, origin2d);
        float buffer = 40;

        drawMovementBounds(origin2d, buffer);
        if (currentPoint2d.x < origin2d.x-buffer) {
          if (millis() - kinectTime > 500) {
            if (player.getX() - MOVE_AMOUNT >= leftBound) {
              player.moveLeft(MOVE_AMOUNT);
              kinectTime = millis();
            }
          }
        } 
        else if (currentPoint2d.x > origin2d.x+buffer) {
          if (millis() - kinectTime > 500) {
            if (player.getX() + MOVE_AMOUNT < rightBound) {
              player.moveRight(MOVE_AMOUNT);
              kinectTime = millis();
            }
          }
        } 
        else if (currentPoint2d.y < origin2d.y-buffer) {
          if (millis() - kinectTime > 500) {
            if (player.getY() - MOVE_AMOUNT >= 0) {
              player.moveForward(MOVE_AMOUNT);
              kinectTime = millis();
            }
          }
        } 
        else if (currentPoint2d.y > origin2d.y+buffer) {
          if (millis() - kinectTime > 500) {
            if (player.getY() + MOVE_AMOUNT < bottomBound) {
              player.moveBack(MOVE_AMOUNT);
              kinectTime = millis();
            }
          }
        }

        stroke(userClr[ (handId - 1) % userClr.length ]);
        strokeWeight(4);
        p = vecList.get(0);
        context.convertRealWorldToProjective(p, p2d);
        point(p2d.x+350, p2d.y);
      }
    }
  }
}

void drawMovementBounds(PVector origin, float buffer) {

  ellipseMode(CENTER);
  noFill();
  stroke(0, 255, 0);
  ellipse(origin.x+350, origin.y, buffer*2, buffer*2);
}

void onNewHand(SimpleOpenNI curContext, int handId, PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);

  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);

  handPathList.put(handId, vecList);
}

void onTrackedHand(SimpleOpenNI curContext, int handId, PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );

  ArrayList<PVector> vecList = handPathList.get(handId);
  if (vecList != null)
  {
    vecList.add(0, pos);
    if (vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1);
  }
}

void onLostHand(SimpleOpenNI curContext, int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curContext, int gestureType, PVector pos)
{
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);

  int handId = context.startTrackingHand(pos);
  println("hand stracked: " + handId);

  origin = pos;
}

void keyPressed() {
  if (!gameOver && !gameWon) {
    if (keyCode == UP) {
      if (player.getY() - MOVE_AMOUNT >= 0) {
        player.moveForward(MOVE_AMOUNT);
      }
    } 
    else if (keyCode == DOWN) {
      if (player.getY() + MOVE_AMOUNT < bottomBound) {
        player.moveBack(MOVE_AMOUNT);
      }
    } 
    else if (keyCode == LEFT) {
      if (player.getX() - MOVE_AMOUNT >= leftBound) {
        player.moveLeft(MOVE_AMOUNT);
      }
    } 
    else if (keyCode == RIGHT) {
      if (player.getX() + MOVE_AMOUNT < rightBound) {
        player.moveRight(MOVE_AMOUNT);
      }
    }
  }
}

void drawMovingPlatforms() {
  Iterator<Platform> pi = platforms.iterator();
  while (pi.hasNext ()) {
    Platform p = pi.next();
    p.move(speed);
    if (isOffScreen(p.getX(), p.getWidth())) {
      p.removeSprite();
      pi.remove();
    }
    p.display();
  }
}

void drawMovingVehicles() {
  Iterator<Vehicle> vi = vehicles.iterator();
  while (vi.hasNext ()) {
    Vehicle v = vi.next();
    v.move(speed);
    if (isOffScreen(v.getX(), v.getWidth())) {
      v.removeSprite();
      vi.remove();
    }
    v.display();
  }
}

boolean isOffScreen(int x, int w) {

  if (x > GAME_WIDTH || (x+w) < 0) 
  {
    return true;
  } 
  else {
    return false;
  }
}

void generateMovingSprites() {

  boolean updateTime = false;

  if (millis() - time > regen) {
    platforms.add(new Platform(GAME_WIDTH, waterLanes.get(0).getY(), MovingSprite.DIRECTION_LEFT, Platform.LOG, 3));
    updateTime = true;
  }

  if (millis() - time > regen) {
    Platform platform = new Platform(0, waterLanes.get(1).getY(), MovingSprite.DIRECTION_RIGHT, Platform.TURTLE, 2);
    platform.setX(0 - platform.getWidth());
    platforms.add(platform);
    updateTime = true;
  }

  if (millis() - time > regen) {
    platforms.add(new Platform(GAME_WIDTH, waterLanes.get(2).getY(), MovingSprite.DIRECTION_LEFT, Platform.LOG, 3));
    updateTime = true;
  }

  if (millis() - time > regen) {
    Platform platform = new Platform(0, waterLanes.get(3).getY(), MovingSprite.DIRECTION_RIGHT, Platform.TURTLE, 3);
    platform.setX(0 - platform.getWidth());
    platforms.add(platform);
    updateTime = true;
  }

  if (millis() - time > regen) {
    platforms.add(new Platform(GAME_WIDTH, waterLanes.get(4).getY(), MovingSprite.DIRECTION_LEFT, Platform.LILY, 3));
    updateTime = true;
  }

  if (millis() - time > regen) {
    vehicles.add(new Vehicle(GAME_WIDTH, roadLanes.get(0).getY(), MovingSprite.DIRECTION_LEFT, Vehicle.TRUCK, 2));
    updateTime = true;
  }

  if (millis() - time > regen) {
    Vehicle vehicle = generateRandomCar(0, roadLanes.get(1).getY(), MovingSprite.DIRECTION_RIGHT, 3);
    vehicle.setX(0 - vehicle.getWidth());
    vehicles.add(vehicle);
    updateTime = true;
  }

  if (millis() - time > regen) {
    vehicles.add(generateRandomCar(GAME_WIDTH, roadLanes.get(2).getY(), MovingSprite.DIRECTION_LEFT, 2));
    updateTime = true;
  }

  if (millis() - time > regen) {
    Vehicle vehicle = generateRandomCar(0, roadLanes.get(3).getY(), MovingSprite.DIRECTION_RIGHT, 1);
    vehicle.setX(0 - vehicle.getWidth());
    vehicles.add(vehicle);
    updateTime = true;
  }

  if (updateTime) {
    time = millis();
  }
}

Vehicle generateRandomCar(int _x, int _y, String _direction, int _length) {
  int r = (int) random(10);
  String car;
  if (r%2==0) {
    car = Vehicle.RED_CAR;
  } 
  else {
    car = Vehicle.BLUE_CAR;
  }
  return new Vehicle(_x, _y, _direction, car, _length);
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

void createFlys() {
  for (int i = 0; i < 4; i++) {
    flys.add(new Fly(i * 150, 0));
  }
}

void drawFlys() {
  for ( Fly fly : flys ) {
    fly.display();
  }
}

private void drawPlayerLives() {
  for (int i = 0; i < player.getLives(); i++) {
    image(loadImage("sprites/player/player-idle.gif"), 50 * i, GAME_HEIGHT - 50);
  }
}

public void playSoundEffect(final String soundEffect) {
  Minim minim = new Minim(this);
  AudioSnippet audioSnippet = minim.loadSnippet(soundEffect);
  if (audioSnippet.isPlaying()) {
    audioSnippet.play(0);
  } 
  else {
    audioSnippet.play();
  }
}

private void spawnPlayer(int _lives) {
  player.setX(playerStartX);
  player.setY(GAME_HEIGHT - (2 * LANE_HEIGHT));
  player.setLives(_lives);
  player.setAlive(true);
  player.setImage(loadImage(Player.IMAGE_IDLE));
}

private void processGameplay() {
  if (!player.isAlive() && player.getLives() > 0) {
    spawnPlayer(player.getLives());
  }

  // Checks if the game is over
  if (player.getLives() == 0) {
    fill(255, 0, 0);
    textSize(12);
    text("GAME OVER", 215, GAME_HEIGHT - 25);
    gameOver = true;
  }

  // Checks if the player wins the game.
  if (flysConsumed == 4) {
    fill(0, 0, 255);
    textSize(12);
    text("YOU WIN!", 215, GAME_HEIGHT - 25);
    gameWon = true;
  }

  // Keeps track of the score
  fill(0, 255, 0);
  textSize(12);
  text("SCORE: " + score, 415, GAME_HEIGHT - 25);
}

private void processPlayer() {
  player.display();

  /*
   * Keeps track of the next position the player must reach to gain
   * points. If player dies he must reach the last nextPointsPosition to
   * gain NEW_LANE_POINTS
   */
  if (player.getY() < nextPointsPosition) {
    score = score + NEW_LANE_POINTS;
    nextPointsPosition = nextPointsPosition - LANE_HEIGHT;
  }


  /*
     * Check if player has collided with a vehicle
   */
  for (int i = 0; i < vehicles.size(); i++) {
    if (vehicles.get(i).hasCollidedWith(player, 10)) {
      if (player.isAlive()) {
        playSoundEffect(COLLISION);
        player.kill();
      }
    }
  }


  /*
     * Only runs if the player has entered into the water lanes. This is set
   * up so if the player is not on a platform he is going to die.
   */
  if (player.getY() < waterLanes.get(4).getY()+50) {
    int currentPlatform = -1;
    for (int i = 0; i < platforms.size(); i++) {
      // Checks if player lands on platform, if so he will sail on it.
      if (platforms.get(i).hasCollidedWith(player, 0)) {
        player.sail(platforms.get(i), speed);
        currentPlatform = i;
      }
    }

    if (currentPlatform != -1) {
      // While sailing on the platform this checks if the player jumps
      // off a platform into water
      if (!player.isOnPlatform(platforms.get(currentPlatform)) && player.isAlive()) {
        playSoundEffect(SPLASH);
        player.kill();
      }
    } 
    else {
      int check = 0;
      for (int i = 0; i < flys.size(); i++) {
        check++;
        // Checks if the player has reached an accessible win zone.
        // If not, he dies.
        if (flys.get(i).hasCollidedWith(player, 15) && flys.get(i).isConsumed() == false) {
          flys.get(i).setConsumed(true);
          // add bonus points to player score for consuming a fly.
          score = score + CONSUME_FLY_BONUS;
          // reset the position at which the frog can gain more
          // points
          nextPointsPosition = 600;
          flysConsumed++;
          playSoundEffect(VICTORY);
          spawnPlayer(player.getLives());
          check = 0;
        } 
        else {
          if (check == 4) {
            if (player.isAlive()) {
              if (player.getY() == 0) {
                playSoundEffect(COLLISION);
              } 
              else {
                playSoundEffect(SPLASH);
              }
            }
            player.kill();
          }
        }
      }
    }
  }
}

