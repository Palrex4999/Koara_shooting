/* 2021須賀作成
 * 弾の抽象クラス
*/

//弾
abstract class Bullet{
  protected PVector position;
  protected PVector velocity;
  protected int damage;
  protected boolean is_player;
  protected int moving_pattern;
  protected PVector init_position;
  protected int counter;
  
  protected boolean explode;
  protected boolean homing;
  protected int b_timer;
  protected ArrayList<Enemy> enemies;

  public Bullet(PVector pos, PVector vel, int dam, boolean player) { //敵と自分の弾
    position = pos.copy();
    velocity = vel.copy();
    damage = dam;
    is_player = player;
    init_position = new PVector(pos.x, pos.y);
    counter = 0;
    explode = false;
    homing = false;
    b_timer = 0;
  }

  public void update() {
    if (is_player) {
      position.x += velocity.x;
      position.y += velocity.y;
    } else {
      position.add(velocity);
    }

    counter++;
  }

  abstract public void draw();

  public PVector getPosition() {
    return position;
  }

  public int getDamage() {
    return damage;
  }
}