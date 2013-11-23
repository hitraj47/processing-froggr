class Platform extends Sprite {
  
  /**
   * The type of Platform.
   */
  private int platformType;

  /**
   * Log platform value.
   */
  public static final int LOG = 0;
  
  /**
   * Lily platform value.
   */
  public static final int LILY = 1;
  
  /**
   * Turtle platform value.
   */
  public static final int TURTLE = 2;
  
  public Platform(int _platformType, int _x, int _y) {
    this.playformType = _platformType;
    PImage image;    
    if (_platformType == LOG) {
      image = loadImage("sprites/platform/log.gif");
    } else if (_platformType == LILY) {
    }
  }
  
}
