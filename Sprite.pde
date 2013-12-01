class Sprite {
  
  private PImage image;
  private int x;
  private int y;
  private boolean removed;
  private boolean animated;
  private Gif animatedImage;
  
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
  
  public void setAnimatedImage(Gif _animatedImage) {
    this.animatedImage = _animatedImage;
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
    return image.width;
  }
  
  public int getHeight() {
    return image.height;
  }
  
  public void display() {
    image(image, x, y);    
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
