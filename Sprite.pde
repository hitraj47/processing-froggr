class Sprite {
  
  private PImage image;
  private int x;
  private int y;
  
  public Sprite(PImage _image, int _x, int _y) {
    this.image = _image;
    this.x = _x;
    this.y = _y;
  }
  
  public PImage getImage() {
    return this.image;
  }
  
  public void setImage(PImage _image) {
    this.image = _image;
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
  
  public display() {
    
    image(image, x, y);
    
  }
  
}
