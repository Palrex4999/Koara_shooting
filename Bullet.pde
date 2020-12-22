// 弾丸の実装をしてください。追従システムとかがあるといいのかも？

class Bullet {
  private PVector position;
  private PVector velocity;
  private int damage;
  private boolean is_player;
  private int moving_pattern;
  private PVector init_position;
  private int counter;
  private SubBullet subBullet;
  
  private boolean explode;
  private boolean homing;
  private int b_timer;
  private ArrayList<Enemy> enemies;

  

  public Bullet(PVector pos, PVector vel, int dam, boolean player) { //敵と自分の弾
    position = pos.copy();
    velocity = vel.copy();
    damage = dam;
    is_player = player;
    moving_pattern = floor(random(0, 100));
    init_position = new PVector(pos.x, pos.y);
    counter = 0;
    if (is_player) {
      subBullet = new PlayerSubBullet(int(random(1, 5)));
    } else {
      subBullet = new EnemySubBullet(int(random(1, 5)));
    }
    explode = false;
    homing = false;
    b_timer = 0;
  }

  public void update() {
    if (is_player) {
      position.x += velocity.x;
      position.y += velocity.y;
    } else {
      if (moving_pattern == 0) { //まっすぐ
        position.add(velocity);
      } else if (moving_pattern == 1) {
        position.x += velocity.x * world.sc.sin[int(degrees(1000.0 * millis()/1000000.0))%360]; //回転？
        position.y += velocity.y;
      } else { //
        position.add(velocity);
        ArrayList<Player> players = world.getPlayers();
        for (Player p : players) {
          PVector p_pos = p.getPosition().copy();
          velocity.add(p_pos.sub(position).div(100000.0).mult(noise(init_position.x + random(0.1, 0.5), init_position.y)));
        }
      }
    }

    subBullet.draw();
    counter++;
  }

  public void draw() {
    noStroke();
    if(is_player){ //プレイヤー
      for(int i=-6; i<=6; i=i+6){
        fill(255, 0, 0, 150);
        circle(position.x+i, position.y, 12);
        circle(position.x, position.y+i, 12);
      }
    }else{ //敵
      if(((millis())%400) > 200) fill(0, 0, 155, 400 - ((millis())%400));
      else fill(0, 0, 155, (millis())%200);
      for(int i=-4; i<=4; i=i+2){
        circle(position.x+i, position.y, 5+(i*i));
        circle(position.x, position.y+i, 5+(i*i));
      } 
    }
    if(explode){
      explosion(5, 30);
    }
    if(homing){
      homing();
    }
    
  }

  public PVector getPosition() {
    return position;
  }

  public int getDamage() {
    return damage;
  }

  void keyPressed(int key) {
    if(key == 'q'){
      moving_pattern = 3;
      println("boost");
      velocity.x *= 1.3;
      velocity.y *= 1.3;
    }
    if(key == 'r'){
      moving_pattern = 3;
      println("explosion");
      explode = true;
    }
    if(key == 'f'){
      moving_pattern = 3;
      println("homing");
      homing = !homing;
    }
  }

//爆発して消える
  void explosion(int speed, int time){
    velocity.x = 0;
    velocity.y = 0;
    damage += speed;
    b_timer++;
    if(b_timer > time){
      if(damage > 20){
        damage -= 30;
      }else{
        damage = 0;
        velocity.y = 500;
      }
    }
    fill(255,100, 0);
    circle(this.position.x, this.position.y, this.damage);
  }
    //一番近い敵にホーミング
  void homing(){
    PVector tmpVec = new PVector(0, 0);
    PVector minVec = velocity;
    float tmpDistance;
    float minDistance = 100000;

    for(Enemy enemy: world.getEnemies()){
      tmpVec = PVector.sub(enemy.position, this.position);
      tmpDistance = PVector.dist(enemy.position, this.position);
      if(minDistance > tmpDistance){
        minDistance = tmpDistance;
        minVec = tmpVec;
      }
    }
    velocity = PVector.mult(minVec.normalize(), velocity.mag());
  }


 abstract class SubBullet {
    protected int bullet_num;
    public abstract void draw();
  }
  // 弾の周りを飛ぶ "子弾"
  // 特に攻撃はしない. 演出用
  class EnemySubBullet extends SubBullet {
    // まわりに飛ばす弾の数
    protected float arg;
    protected color c;

    public EnemySubBullet(int bn) {
      bullet_num = bn;
      arg = 0;
      colorMode(HSB);
      c = color(random(80, 255), 255, 255);
      colorMode(RGB);
    }

    public void draw() {
      float theta = arg;
      for (int j = 5; j > 0; j--) {
        for (int i = 0; i < bullet_num; i++) {
          float x = 30 * world.sc.cos[int(degrees(i * TWO_PI/bullet_num + theta))%360] + position.x;
          float y = 30 * world.sc.sin[int(degrees(i * TWO_PI/bullet_num + theta))%360] + position.y;
          drawShape(x, y, j + 50, (100 - j*10)/10.0);
        }
        theta += j/TWO_PI + 5 * PI/180;
      }
      arg += PI / 180;
    }

    protected void drawShape(float x, float y, float alpha, float s) {
      noStroke();
      fill(c, alpha);
      circle(x, y, s);
    }
  }

  class PlayerSubBullet extends SubBullet {
    protected color c;
    protected float arg;

    public PlayerSubBullet(int bn) {
      bullet_num = bn;
      arg = 0.0;
      colorMode(HSB);
      c = color(100 + random(150), 255, 255);
      colorMode(RGB);
    }

    public void draw() {
      pushMatrix();
      translate(position.x, position.y);
      scale(8);
      rotate(arg);
      noStroke();
      fill(c, 100);
      for (int i=0;i < bullet_num;i++) {
        star(3 * world.sc.cos[int(degrees(i * TWO_PI/bullet_num))%360], 3 * world.sc.sin[int(degrees(i * TWO_PI/bullet_num))%360]);
      }
      popMatrix();
      arg += PI/180;
    }

    protected void star(float ox, float oy) {
      float or = 1;
      float ir = 0.6;
      float[] r = {or, ir, or, ir, or, ir, or, ir, or, ir};
      beginShape();
      for (int i=0;i < r.length;i++) {
        float x = r[i] * world.sc.cos[int(degrees(i * TWO_PI/10 + arg * 2))%360] + ox;
        float y = r[i] * world.sc.sin[int(degrees(i * TWO_PI/10 + arg * 2))%360] + oy;
        vertex(x, y);
      }
      endShape(CLOSE);
    }
  }
}
