// プレイヤーを実装してください。ゲームバランスを考えた"良い"プレイヤーの実装をお願いします。

class Player {
  private PVector position; //位置
  private int HP; //HP
  private int life; //ライフ
  private int size; //プレイヤーの大きさ
  private ArrayList<Bullet> bullets; //弾
  private float angle; //プレイヤーの角度

  //////////////////////////////////////////
  //2021須賀修正分：
  //クラス下部で行われていた変数宣言を上部へ
  //NullPointerException防止でclushCountを-1で初期化
  private int hitCount, boostCount, shootCount;
  private int clushCount=-1;
  private PVector[] debris = new PVector[6];//xにrad, yに変位
  //////////////////////////////////////////


  public boolean is_dead; //プレイヤーの状態
  
  Minim minim;
  AudioPlayer shootSE, hitSE, clushSE;

  public Player(PVector pos) {
    position = pos;
    bullets = new ArrayList<Bullet>();
    size = 30;
    HP = 80;
    life = 3;
    minim = new Minim(getPApplet());    
    shootSE = minim.loadFile("shoot1.mp3");
    hitSE = minim.loadFile("glass-break4.mp3");
    clushSE = minim.loadFile("flee1.mp3");
  }

  //プレイヤーに敵の弾が当たった時の処理
  public void hit(int damage) {
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
    //雑魚敵の弾の衝突判定
    for (Enemy enemy : world.getEnemies()) {
      for (int b_idx = enemy.getBullets().size()-1; b_idx > 0; b_idx--) {
        Bullet e_bullet = enemy.getBullets().get(b_idx);
        
        //////////////////////////////////////////
        //2021須賀追記：
        //モートン番号が異なる場合は衝突判定を計算しない
        if(world.mt.getMortonNum(position)!=world.mt.getMortonNum(e_bullet.getPosition()))
          continue;
        //////////////////////////////////////////
        
        float dist = PVector.sub(e_bullet.getPosition(), position).mag();
        // 衝突判定
        if (dist < size/2 && millis() - hitCount > 1000) {
          int damage = e_bullet.getDamage();
          hit(damage);
          enemy.getBullets().remove(b_idx);
        }
      }
    }

    //////////////////////////////////////////
    //2021須賀追記：
    //ボスの弾の衝突判定
    Boss boss=world.getBoss();
    for (int b_idx = boss.getBullets().size()-1; b_idx > 0; b_idx--) {
      Bullet e_bullet = boss.getBullets().get(b_idx);

      //////////////////////////////////////////
      //2021須賀追記：
      //モートン番号が異なる場合は衝突判定を計算しない
      if(world.mt.getMortonNum(position)!=world.mt.getMortonNum(e_bullet.getPosition()))
        continue;
      //////////////////////////////////////////

      float dist = PVector.sub(e_bullet.getPosition(), position).mag();
      // 衝突判定
      if (dist < size/2 && millis() - hitCount > 1000) {
        int damage = e_bullet.getDamage();
        hit(damage);
        boss.getBullets().remove(b_idx);
      }
    }
    //////////////////////////////////////////
  }

  // hit処理、場所のアップデートなど
  public void update() {
    changePosition();
    hitCheck();
    animation();
    checkWall();
  }

  // 弾丸を発射する関数
  public void shoot() {
    float bulletVel = 3.0;
    for (int i = -1; i <= 1; i++) {
      int theta = int(degrees(3*PI/2 + i*PI/6.0 + this.angle))%360;
      float xDir = world.sc.cos[theta] * bulletVel;
      float yDir = world.sc.sin[theta] * bulletVel;
      bullets.add(new Bullet(this.position.copy(), new PVector(xDir, yDir), 10, true));
    }
    shootSE.rewind();
    shootSE.play();
    shootCount = millis();
  }

  // Playerを描画する関数
  public void draw() {
    push();
    this.angle = calcHeadingAngle(this.position, new PVector(mouseX, mouseY));
    translate(position.x, position.y);

    //////////////////////////////////////////
    //2021須賀修正分：
    //NullPointerException防止のためclushCount!=-1を条件に追加
    if(clushCount!=-1 && millis() - clushCount < 2000)
      drawDebri(millis() - clushCount);
    //////////////////////////////////////////
    
    rotate(this.angle);
    
    noStroke();
    //炎のゆらぎ
    fill(255, 100, 0);
    ellipse(0.0,size / 2, size / 4, size / 4 * (millis() - boostCount) / 20);
    //hit時の点滅
    if ((millis() - hitCount) / 100 % 2 == 0 && (millis() - hitCount) < 1000) fill(0);
    else fill(255, 255, 0);   
    // 機体の絵
    if(millis() - shootCount <= 100) translate(0, (millis() - shootCount) / 5);
    drawAircraft(this.size);
    
    pop();
    
    for (int b_idx = 0; b_idx < this.bullets.size(); b_idx++) {
      Bullet b = bullets.get(b_idx);
      b.update();
      if (b.getPosition().x > width || b.getPosition().x < 0
        || b.getPosition().y > height || b.getPosition().y < 0)
        bullets.remove(b_idx);
      else 
      b.draw();
    }
    
    //drawProperties();
  }
  
  private void drawProperties() {
    fill(255,255,0);
    noStroke();
    for(int i = 0; i < life; i++) {
      push();
      int x = 40 + 25 * i;
      int y = 40;
      
      translate(x, y);
      drawAircraft(15);
      pop();
    }
    
    
    fill(100, 200, 150);
    noStroke();
    float barSize = map(HP, 0, 100, 0, width - 200);
    rect(200, 30, barSize, 10);
    
    fill(255);
    textSize(20);
    text(str(this.HP), 160, 42.5);
  }
  
  // s: size, p: position
  private void drawAircraft(int s) {
    triangle(- s / 3, s / 2, 
      - s / 6, - s / 2, 
      - s * 2 / 3, s / 2);
    triangle(s / 3, s / 2, 
      s / 6, - s/ 2, 
      s * 2 / 3, s / 2);
    triangle(0.0, - s, 
      s / 3, 0.0, 
      - s / 3, 0.0);    
    ellipse(0.0, 0.0, s / 2, s);
  }
  
  private void drawDebri(int s){
    for(int idx = 0; idx < 6; idx++){
      fill(255, 255, 0);
      ellipse(s/10.0*debris[idx].y*world.sc.cos[int(degrees(debris[idx].x))%360], s/10.0*debris[idx].y*world.sc.sin[int(debris[idx].x)%360],
      10, 10);
    }
  }

  public void animation() {
    boostCount = (millis() - boostCount >= 200) ? millis() : boostCount ;
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


  public PVector getPosition() { 
    return this.position;
  }

  public ArrayList<Bullet> getBullets() { 
    return this.bullets;
  }

  private boolean key_a, key_w, key_d, key_s;
  public void keyPressed(int key) {
    
    for(Bullet bullet : this.bullets)
      bullet.keyPressed(key);


    if (key == 'a') key_a = true;
    if (key == 'w') key_w = true;
    if (key == 'd') key_d = true;
    if (key == 's') key_s = true;
  }
  
  public void keyReleased(int key){
    //if (key == 'a') println("releasing a");
    if (key == 'a') key_a = false;
    if (key == 'w') key_w = false;
    if (key == 'd') key_d = false;
    if (key == 's') key_s = false;
  }
  
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
