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
    super(loadImage("sprites/vehicle/" + _vehicleType + "-" + _direction + "-" + _length + ".gif"), _x, _y, _direction);
    this.vehicleType = _vehicleType;
    this.length = _length;    
  }
  
}
