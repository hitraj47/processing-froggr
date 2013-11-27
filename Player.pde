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
      remove();
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
  
  public void moveForward() {
    setY(getY() - 50);
    setImage(loadImage(IMAGE_FORWARD));
  }
  
  public void moveBackward() {
    setY(getY() + 50);
    setImage(loadImage(IMAGE_BACK));
  }
  
  public void moveLeft() {
    setX(getX() - 50);
    setImage(loadImage(IMAGE_LEFT));
  }
  
  public void moveRight() {
    setX(getX() + 50);
    setImage(loadImage(IMAGE_RIGHT));
  }
  
}

