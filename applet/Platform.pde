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
