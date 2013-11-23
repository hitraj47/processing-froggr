class Sprite {
  
  private PImage image;
  private int x;
  private int y;
  private boolean removed;
  
  public Sprite(PImage _image, int _x, int _y) {
    this.image = _image;
    this.x = _x;
    this.y = _y;
    this.removed = false;
  }
  
  public void remove() {
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
  
  public int getWidth() {
    return image.width;
  }
  
  public int getHeight() {
    return image.height;
  }
  
  public void display() {
    
    image(image, x, y);
    
  }
  
  public boolean hasCollidedWidth(Sprite _sprite, int _buffer) {
  
  }
}
