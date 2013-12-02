class Fly extends Sprite {
 
 private boolean consumed;
  
 public Fly(int _x, int _y) {
  super(loadImage("sprites/lane/fly.png"), _x, _y); 
  this.consumed = false;
 }
 
 public boolean isConsumed() {
   return this.consumed;
 }
 
 public void setConsumed(boolean _consumed) {
   this.consumed = _consumed;
    if (consumed) {
      setImage(loadImage("sprites/lane/fly-consumed.png"));
    } else {
      setImage(loadImage("sprites/lane/fly.png"));
    }
 }
 
}


