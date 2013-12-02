import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import gifAnimation.*; 
import SimpleOpenNI.*; 
import java.util.Map; 
import ddf.minim.*; 
import java.util.Iterator; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class froggr extends PApplet {








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
public final int GAME_BACKGROUND_COLOR = color(0, 0, 0);

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
long regen = 6000;

// kinect stuff
SimpleOpenNI context;
int handVecListSize = 20;
Map<Integer, ArrayList<PVector>>  handPathList = new HashMap<Integer, ArrayList<PVector>>();
int[]       userClr = new int[] { 
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

public void setup() {
  applet = this;
  // set time to negative regen so it draws stuff when game loads
  time = -regen;
  kinectTime = millis();
  size(GAME_WIDTH+300, GAME_HEIGHT);

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
  context = new SimpleOpenNI(this);
  if (context.isInit() == false) {
    println("Can't init SimpleOpenNI, maybe the camera isn't connected!");
    // set speed to 2 to compensate for kinect
    speed = 1;
  } else {
    speed = 2;
  }
  context.enableDepth();
  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_WAVE);
}

public void draw() {
  // update kinect cam
  context.update();

  background(GAME_BACKGROUND_COLOR);
  drawLanes();
  drawFlys();
  generateMovingSprites();
  drawMovingPlatforms();
  processPlayer();
  drawMovingVehicles();
  drawPlayerLives();
  processGameplay();


  drawInputInfo();
  drawTrackedHands();
}

public void drawInputInfo() {
  noStroke();
  fill(GAME_BACKGROUND_COLOR);
  rect(GAME_WIDTH, 0, width-GAME_WIDTH, height);
}

public void drawTrackedHands() {
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

public void drawMovementBounds(PVector origin, float buffer) {

  ellipseMode(CENTER);
  noFill();
  stroke(0, 255, 0);
  ellipse(origin.x+350, origin.y, buffer*2, buffer*2);
}

public void onNewHand(SimpleOpenNI curContext, int handId, PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);

  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);

  handPathList.put(handId, vecList);
}

public void onTrackedHand(SimpleOpenNI curContext, int handId, PVector pos)
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

public void onLostHand(SimpleOpenNI curContext, int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

public void onCompletedGesture(SimpleOpenNI curContext, int gestureType, PVector pos)
{
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);

  int handId = context.startTrackingHand(pos);
  println("hand stracked: " + handId);

  origin = pos;
}

public void keyPressed() {
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

public void drawMovingPlatforms() {
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

public void drawMovingVehicles() {
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

public boolean isOffScreen(int x, int w) {

  if (x > GAME_WIDTH || (x+w) < 0) 
  {
    return true;
  } 
  else {
    return false;
  }
}

public void generateMovingSprites() {

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

public Vehicle generateRandomCar(int _x, int _y, String _direction, int _length) {
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


public void setupLanes(int _numWaterLanes, int _numSafeLanes, int _numRoadLanes) {

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

public void drawLanes() {

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

public void createFlys() {
  for (int i = 0; i < 4; i++) {
    flys.add(new Fly(i * 150, 0));
  }
}

public void drawFlys() {
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
  this.player = new Player(playerStartX, GAME_HEIGHT - (2 * LANE_HEIGHT), _lives);
}

private void processGameplay() {
  if (!player.isAlive() && player.getLives() > 0) {
    spawnPlayer(player.getLives());
  }

  // Checks if the game is over
  if (player.getLives() == 0) {
    fill(255, 0, 0);
    text("GAME OVER", 225, GAME_HEIGHT - 25);
    gameOver = true;
  }

  // Checks if the player wins the game.
  if (flysConsumed == 4) {
    fill(0, 0, 255);
    text("YOU WIN!", 225, GAME_HEIGHT - 25);
    gameWon = true;
  }

  // Keeps track of the score
  fill(0, 255, 0);
  text("SCORE: " + score, 400, GAME_HEIGHT - 25);
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
        image(player.getImage(), player.getX(), player.getY());
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
        player.sail(platforms.get(i));
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

class Fly extends Sprite {
 
 private boolean consumed;
  
 public Fly(int _x, int _y) {
  super(loadImage("sprites/lane/fly.png"), _x, _y); 
  this.consumed = false;
 }
 
 public boolean isConsumed() {
   return this.consumed;
 }
 
 public void setConsumed(boolean _consumed) {
   this.consumed = _consumed;
    if (consumed) {
      setImage(loadImage("sprites/lane/fly-consumed.png"));
    } else {
      setImage(loadImage("sprites/lane/fly.png"));
    }
 }
 
}


class Lane extends Sprite {
  
  private String laneType;
  
  public static final String LANE_WATER = "water.gif";
  public static final String LANE_GRASS = "grass.png";
  public static final String LANE_WIN = "win.png";
  public static final String LANE_ROAD_TOP = "road-top.png";
  public static final String LANE_ROAD_MIDDLE = "road-middle.png";
  public static final String LANE_ROAD_BOTTOM = "road-bottom.png";
  
  public Lane(int _x, int _y, String _laneType) {
    super(loadImage("sprites/lane/" + _laneType), _x, _y);
    this.laneType = _laneType;
    if (laneType.equals(LANE_WATER)) {
      this.setAnimated(true);
      this.setAnimatedImage("sprites/lane/" + LANE_WATER);
    }
  }
  
}
class MovingSprite extends Sprite {
  
  /**
   * The direction the Sprite moves in.
   */
  private String direction;

  /**
   * Value for moving left.
   */
  public static final String DIRECTION_LEFT = "0";
  
  /**
   * Value for moving right.
   */
  public static final String DIRECTION_RIGHT = "1";
  
  public MovingSprite(PImage _image, int _x, int _y, String _direction) {
    super(_image, _x, _y);
    this.direction = _direction;
  }
  
  public MovingSprite(String _image, int _x, int _y, String _direction) {
    super(_image, _x, _y);
    this.direction = _direction;
  }
  
  public String getDirection() {
    return this.direction;
  }
  
  public void setDirection(String _direction) {
    this.direction = _direction;
  }
  
  public void update() {
    if (this.direction == DIRECTION_LEFT) {
      this.setX(this.getX()-1);
    } else {
      this.setX(this.getX()+1);
    }
  }
  
  public int getOffScreenXPosition() {
    if (getDirection() == MovingSprite.DIRECTION_LEFT) {
      return 0 - getWidth();
    } else {
      return froggr.GAME_WIDTH;
    }
  }
  
  public void move(int _speed) {
    if (direction.equals(DIRECTION_LEFT)) {
      setX(getX() - _speed);
    } else {
      setX(getX() + _speed);
    }      
  }
  
}
class Platform extends MovingSprite {
  
  /**
   * The type of Platform.
   */
  private String platformType;
  
  /**
   * The length of the platform
   */
  private int length;
  
  /**
   * Log platform value.
   */
  public static final String LOG = "log";
  
  /**
   * Lily platform value.
   */
  public static final String LILY = "lily";
  
  /**
   * Turtle platform value.
   */
  public static final String TURTLE = "turtle";
  
  public Platform(int _x, int _y, String _direction, String _platformType, int _length) {
    super("sprites/platform/" + _platformType + "-" + _direction + "-" + _length + ".gif", _x, _y, _direction);
    this.platformType = _platformType;
    this.length = _length;    
  }
  
}
class Player extends Sprite {

  private int lives;

  private boolean alive;
  
  private static final String IMAGE_FORWARD = "sprites/player/player-forward.gif";
  private static final String IMAGE_BACK = "sprites/player/player-back.gif";
  private static final String IMAGE_LEFT = "sprites/player/player-left.gif";
  private static final String IMAGE_RIGHT = "sprites/player/player-right.gif";
  private static final String IMAGE_IDLE = "sprites/player/player-idle.gif";
  private static final String IMAGE_DEATH = "sprites/player/player-death.gif";

  public Player(int _x, int _y, int _lives) {
    super(loadImage(IMAGE_IDLE), _x, _y);
    this.lives = _lives;
    this.alive = true;
  }

  public int getLives() {
    return this.lives;
  }

  public void setLives(int _lives) {
    this.lives = _lives;
  }

  public boolean isAlive() {
    return alive;
  }

  public void setAlive(boolean _alive) {
    this.alive = _alive;
  }

  public boolean isOnPlatform(Platform platform) {
    int buffer = getWidth()/2; // Half of the player.
    if (getX() >= platform.getX() - buffer && getX() + getWidth() <= platform.getX() + platform.getWidth() + buffer) {
      return true;
    } 
    else {
      return false;
    }
  }
  
  public void kill() {
    if (isAlive()) {
      removeSprite();
      if (getLives() == 1) {
        setImage(loadImage(IMAGE_DEATH));
      }
      setLives(getLives() - 1);
      setAlive(false);
    }
  }
  
  public void sail(Platform platform) {
    if (platform.getDirection() == MovingSprite.DIRECTION_LEFT) {
      setX(getX() - 1);
    } else if (platform.getDirection() == MovingSprite.DIRECTION_RIGHT) {
      setX(getX() + 1);
    }

    if (getX() == platform.getOffScreenXPosition()) {
      kill();
    }
  }
  
  public void moveForward(int _amount) {
    if (alive) {
      setY(getY() - _amount);
      setImage(loadImage(IMAGE_FORWARD));
      playSoundEffect(HOP);
    }
  }
  
  public void moveBack(int _amount) {
    if (alive) {
      setY(getY() + _amount);
      setImage(loadImage(IMAGE_BACK));
      playSoundEffect(HOP);
    }
  }
  
  public void moveLeft(int _amount) {
    if (alive) {
      setX(getX() - _amount);
      setImage(loadImage(IMAGE_LEFT));
      playSoundEffect(HOP);
    }
  }
  
  public void moveRight(int _amount) {
    if (alive) {
      setX(getX() + _amount);
      setImage(loadImage(IMAGE_RIGHT));
      playSoundEffect(HOP);
    }
  }
  
}

class Sprite {
  
  private PImage image;
  private int x;
  private int y;
  private boolean removed;
  private boolean animated;
  private Gif animatedImage;
  private PImage[] frames;
  
  public Sprite(PImage _image, int _x, int _y) {
    this.image = _image;
    this.x = _x;
    this.y = _y;
    this.removed = false;
    this.animated = false;
  }
  
  public Sprite(String _imageLocation, int _x, int _y) {
    this.animatedImage = new Gif(froggr.applet, _imageLocation);
    this.animatedImage.loop();
    this.frames = Gif.getPImages(froggr.applet, _imageLocation);
    this.x = _x;
    this.y = _y;
    this.removed = false;
    this.animated = true;
  }
  
  public void setAnimated(boolean _animated) {
    this.animated = _animated;
  }
  
  public boolean isAnimated() {
    return this.animated;
  }
  
  public void removeSprite() {
    this.removed = true;
  }
  
  public boolean isRemoved() {
    return removed;
  }
  
  public PImage getImage() {
    return this.image;
  }
  
  public void setImage(PImage _image) {
    this.image = _image;
  }
  
  public Gif getAnimatedImage() {
    return this.animatedImage;
  }
  
  public void setAnimatedImage(String _animatedImage) {
    this.animatedImage = new Gif(froggr.applet, _animatedImage);
    this.animatedImage.loop();
    this.frames = Gif.getPImages(froggr.applet, _animatedImage);
  }
  
  public int getX() {
    return this.x;
  }
  
  public void setX(int _x) {
    this.x = _x;
  }
  
  public int getY() {
    return this.y;
  }
  
  public void setY(int _y) {
    this.y = _y;
  }
  
  public void setPosition(int _x, int _y) {
    this.x = _x;
    this.y = _y;
  }
  
  public int getWidth() {
    if (animated) {
      return frames[0].width;
    } else {
      return image.width;
    }
  }
  
  public int getHeight() {
    if (animated) {
      return frames[0].height;
    } else {
      return image.height;
    }
  }
  
  public void display() {
    if (animated) {
      image(animatedImage, x, y);
    } else {
      image(image, x, y);
    }    
  }
  
  public boolean hasCollidedWith(Sprite _sprite, int _buffer) {
    
    int xmin = this.getX()-_sprite.getWidth()+_buffer;
    int xmax = this.getX()+this.getWidth()-_buffer;
    
    if ( _sprite.getX() >= xmin
      && _sprite.getX() <= xmax
      && _sprite.getY() == this.getY() )
    {
      return true;
    } else {
      return false;
    }
      
  }
}
class Vehicle extends MovingSprite {
  
  /**
   * The type of Vehicle.
   */
  private String vehicleType;
  
  /**
   * The length of the vehicle
   */
  private int length;
  
  /**
  *  The red car
  */
  public static final String RED_CAR = "car-red";
  
  /**
  *  The blue car
  */
  public static final String BLUE_CAR = "car-blue";
  
  /**
   * Truck vehicle value.
   */
  public static final String TRUCK = "truck";
  
  public Vehicle(int _x, int _y, String _direction, String _vehicleType, int _length) {
    super("sprites/vehicle/" + _vehicleType + "-" + _direction + "-" + _length + ".gif", _x, _y, _direction);
    this.vehicleType = _vehicleType;
    this.length = _length;    
  }
  
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "froggr" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
