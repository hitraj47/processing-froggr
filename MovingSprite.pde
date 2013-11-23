class MovingSprite extends Sprite {
  
  /**
   * The direction the Sprite moves in.
   */
  private int direction;

  /**
   * Value for moving left.
   */
  public static final int DIRECTION_LEFT = 0;
  
  /**
   * Value for moving right.
   */
  public static final int DIRECTION_RIGHT = 1;
  
  public MovingSprite(PImage _image, int _x, int _y, int _direction) {
    this.direction = _direction;
    super(_image, _x, _y);
  }
  
  public int getDirection() {
    return this.direction;
  }
  
  public void setDirection(int _direction) {
    this.direction = _direction;
  }
  
  public void update() {
    if (this.direction == DIRECTION_LEFT) {
      this.setX(this.getX()-1);
    } else {
      this.setX(this.getX()+1);
    }
  }
  
}
