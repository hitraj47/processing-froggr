class Player extends Sprite {

  private int lives;

  private boolean alive;

  public Player(int _x, int _y, int _lives) {
    super(loadImage("sprites/player/player-idle.gif"), _x, _y);
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
        setImage(loadImage("sprites/player/player-death.gif"));
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
  
}

