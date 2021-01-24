// プレイヤーを実装してください。ゲームバランスを考えた"良い"プレイヤーの実装をお願いします。

class Player {
  private PVector position; //位置
  private int HP; //HP
  private int life; //ライフ
  private int size; //プレイヤーの大きさ
  private ArrayList<Bullet> bullets; //弾
  private int bultype=0; //弾の種類
  private int bulway=1; //発射する弾のWAY数:1→3WAY 0→1WAY
  private float angle; //プレイヤーの角度

  private int attribute; //プレイヤーの属性
  private int absorb=0; //弾吸収数
  public boolean absorbed=false; //弾を吸収したかどうか

  //////////////////////////////////////////
  //2021須賀修正分：
  //クラス下部で行われていた変数宣言を上部へ
  //NullPointerException防止でclushCountを-1で初期化
  private int hitCount;
  private int clushCount=-1;
  private PVector[] debris = new PVector[6];//xにrad, yに変位
  //////////////////////////////////////////


  public boolean is_dead; //プレイヤーの状態
  
  private PImage cat;

  Minim minim;
  AudioPlayer shootSE, hitSE, clushSE;

  public Player(PVector pos) {
    position = pos;
    bullets = new ArrayList<Bullet>();
    size = 30;
    HP = 100;
    life = 1;

    attribute=#ff0000;

    cat = loadImage("data/cat.png");
    minim = new Minim(getPApplet());    
    shootSE = minim.loadFile("shoot1.mp3");
    hitSE = minim.loadFile("glass-break4.mp3");
    clushSE = minim.loadFile("flee1.mp3");
  }

  //プレイヤーに敵の弾が当たった時の処理
  public void hit(int damage) {
    //damageが負の時＝同属性の弾に当たった時
    if(damage<0){
      absorbed=true;
      absorb++;
      if(absorb==10){//10回目のとき回復
        HP=min(100,HP-damage);
        absorb=0;
      }
      hitCount=0;
      return;
    }

    HP -= damage;
    if(HP < 0) {
      is_dead = (life-- == 0);
      
      if (is_dead){
        return;
      }else{
        HP = 80;
        clushSE.rewind();
        clushSE.play();
        clushCount = millis();
        for(int idx = 0; idx < 6; idx++){
          debris[idx] = new PVector(idx + random((float)0, (float)1), random((float)1));
        }
      }
    }
    hitSE.rewind();
    hitSE.play();
    hitCount = millis();
  }

  public void hitCheck() {
    //敵の弾の衝突判定
    //2021須賀修正：敵・ボスの弾をworldで一元管理
    for (int b_idx = world.getEnemyBullets().size()-1; b_idx > 0; b_idx--) {
      Bullet e_bullet = world.getEnemyBullets().get(b_idx);
      //////////////////////////////////////////
      //2021須賀追記：
      //モートン番号が異なる場合は衝突判定を計算しない
      if(world.mt.getMortonNum(position)!=world.mt.getMortonNum(e_bullet.getPosition()))
        continue;
      //////////////////////////////////////////
      
      float dist = PVector.sub(e_bullet.getPosition(), position).mag();
      // 衝突判定
      if (dist < size/2 && millis() - hitCount > 1000) {
        int damage = e_bullet.getDamage()*(this.attribute==e_bullet.getAttribute()?-1:1);
        hit(damage);
        world.getEnemyBullets().remove(b_idx);
      }
    }
  }

  //////////////////////////////////////////
  //2021須賀作成：
  //弾の種類の切り替え
  private Bullet setBullet(PVector pos, PVector vel){
    switch (bultype) {
      case 0:
        return new Bul_Normal(pos,vel,attribute);
      case 1:
        return new Bul_Boost(pos,vel,attribute);
      case 2:
        return new Bul_Explosion(pos,vel,attribute);
      case 3:
        return new Bul_Homing(pos,vel,attribute);
      default :
        return new Bul_Normal(pos,vel,attribute);
    }
  }
  //////////////////////////////////////////

  // hit処理、場所のアップデートなど
  public void update() {
    changePosition();
    hitCheck();
    checkWall();
  }

  // 弾丸を発射する関数
  public void shoot() {
    float bulletVel = 3.0;
    for (int i = -bulway; i <= bulway; i++) {
      int theta = int(degrees(3*PI/2 + i*PI/6.0 + this.angle))%360;
      float xDir = world.sc.cos[theta] * bulletVel;
      float yDir = world.sc.sin[theta] * bulletVel;
      bullets.add(setBullet(this.position.copy(), new PVector(xDir, yDir)));
    }
    shootSE.rewind();
    shootSE.play();
  }

  // Playerを描画する関数
  public void draw() {
    this.angle = calcHeadingAngle(this.position, new PVector(mouseX, mouseY));
    //////////////////////////////////////////
    //2021須賀修正分：
    //NullPointerException防止のためclushCount!=-1を条件に追加
    if(clushCount!=-1 && millis() - clushCount < 2000)
      drawDebri(millis() - clushCount);
    //////////////////////////////////////////
    
    // 2020矢野変更 プレイヤーを画像に変更

    tint(attribute,200);
    image(cat, position.x, position.y, 110, 110);
    tint(255,255);

    //2020矢野追加:プレイヤーの画像
    image(cat, position.x, position.y, 100, 100);

    //当たり判定を薄く表示
    fill(attribute,32);
    noStroke();
    circle(position.x,position.y,10);
    
    //弾の描画
    for (int b_idx = 0; b_idx < this.bullets.size(); b_idx++) {
      Bullet b = bullets.get(b_idx);
      b.update();
      if (b.getPosition().x > width || b.getPosition().x < 0
        || b.getPosition().y > height || b.getPosition().y < 0)
        bullets.remove(b_idx);
      else 
      b.draw();
    }
  }
  
  private void drawDebri(int s){
    for(int idx = 0; idx < 6; idx++){
      fill(255, 255, 0);
      ellipse(s/10.0*debris[idx].y*world.sc.cos[int(degrees(debris[idx].x))%360], s/10.0*debris[idx].y*world.sc.sin[int(debris[idx].x)%360],
      10, 10);
    }
  }
  
  private void checkWall() {
    position.x = position.x < 50 ? 50 : position.x;
    position.x = position.x > width - 50 ? width - 50 : position.x;
    
    position.y = position.y < 50 ? 50 : position.y;
    position.y = position.y > height - 50 ? height - 50 : position.y;
  }
  
  private float calcHeadingAngle(PVector p, PVector target) {
    PVector dir = PVector.sub(target, p).normalize();
    float angle = atan2(dir.y, dir.x) + PI/2;
    return angle;
  }

  public void setHP(int HP) { 
    this.HP = HP;
  }
  public int getHP() { 
    return this.HP;
  }

  public void setLife(int life) { 
    this.life = life;
  }
  public int getLife() { 
    return this.life;
  }

  public int getAbsorbNum(){
    return this.absorb;
  }


  public PVector getPosition() { 
    return this.position;
  }

  public ArrayList<Bullet> getBullets() { 
    return this.bullets;
  }

  public int getBulletType(){return bultype;}
  public int getPlayerAttribute(){return attribute;}

  private boolean key_a, key_w, key_d, key_s;
  public void keyPressed(int key) {
    //自機移動
    if (key == 'a') key_a = true;
    if (key == 'w') key_w = true;
    if (key == 'd') key_d = true;
    if (key == 's') key_s = true;

    //弾の種類変更
    if(key == 'e'){
      bultype=0;
      bulway=1;
    }
    if(key == 'q'){
      bultype=1;
      bulway=0;
    }
    if(key == 'r'){
      bultype=2;
      bulway=0;
    }
    if(key == 'f'){
      bultype=3;
      bulway=0;
    }

    //属性反転
    if(key == ' '){
      attribute=~((attribute&0xffffff)+0xff00);
    }
  }
  
  public void keyReleased(int key){
    if (key == 'a') key_a = false;
    if (key == 'w') key_w = false;
    if (key == 'd') key_d = false;
    if (key == 's') key_s = false;
  }
  
  //自機移動
  private void changePosition(){
    if(key_a) position.x -= 5;
    if(key_w) position.y -= 5;
    if(key_d) position.x += 5;
    if(key_s) position.y += 5;
  }
  
  public void mousePressed() {
    shoot();    
  }
}
