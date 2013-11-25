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
  
}
