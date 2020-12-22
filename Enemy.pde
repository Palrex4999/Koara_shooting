// 敵を実装してください。ゲームバランスなどを考えた、"良い"敵の実装をお願いします。
// 
// 出現タイミングなどは、worldクラスで統制することになっているので、
// 変更したい場合は、適宜worldクラスチームと相談してください。
// 勝手に変更するとmerge時にコンフリクトが起きる可能性があるので、ご注意ください。

class Enemy {
  PVector position;
  private ArrayList<Bullet> bullets;

  int size;
  int hp;
  float heartbeat_phase,heartbeat_freq;

  private boolean isShooted;//射撃したか保持する変数．
  private int shootingTiming_ms;//射撃タイミングの設定
  
  private int moveselect;//Enemyの動きを選択する
  private int moveflag;//動きを変えるタイミング
  private PVector velocity;//動きパターン1の速度
  private PVector velocity2 = new PVector(0,0);//動きパターン2の速度
  private long lastHitTime_ms;  //最後にBulletに当たった時刻(ms)

  public boolean is_dead;

  final int INVINCIBLE_TERM_MS = 1000;  // 無敵期間(ms)

  public Enemy(PVector pos) {
     position = pos;
     bullets = new ArrayList<Bullet>();

     isShooted = false;
     shootingTiming_ms = int(random(200,400));

     
     moveselect = int(random(2));
     moveflag = int(random(2,4));
     velocity = new PVector(random(0,3), random(3,5));
     
     for(Player player : world.getPlayers()){
       velocity2 = PVector.sub(player.getPosition(),position).div(100);
     }

     size = 100;
     heartbeat_phase = random(2.0*PI);
     heartbeat_freq = 200.0;
     hp = 3;
     lastHitTime_ms = 0L;
  }
  
  public Enemy(PVector pos, int size, int hp, long lastHitTime_ms){
    this(pos);
    this.size = size;
    this.hp = hp;
    this.lastHitTime_ms = lastHitTime_ms;
  }
  
  public void shoot() {
  threeWayShooter_addtiming(shootingTiming_ms);

  }

//星担当箇所↓
  public void move(){
    if(moveselect == 0){//動きパターン1　まっすぐ～ギザギザ
      if(millis()/1000 % moveflag == 0){
        position.add(velocity);
      }else{
        position.add(-velocity.x ,velocity.y);
      }
    }else{//動きパターン2　Playerに向けて動く
      position.add(velocity2);
    }
  }
  
  public void update() {
    move();
    shoot();
    hit();
  }
//星担当箇所↑  

  // Enemy を描画する関数
  public void draw() {

    int r = (int) (world.sc.sin[int(millis()/heartbeat_freq + heartbeat_phase)%360]*10.0);
    int c = (int) (world.sc.sin[int(millis()/heartbeat_freq + heartbeat_phase)%360]*50.0); //±50

    // ヒット直後，1sec間は100ms毎に点滅を繰り返す
    if(isInvincible() && (millis() / 100) % 2 == 0){
      fill(0, 0, 0, 0);
    }else{
      fill(200+c,50-c,50-c);
    }
    
    noStroke();
    circle(position.x,position.y,size+r);
   //弾を描画する処理を書く
    drawBullets();
  }
  
  // 内藤担当箇所
  // Player の Bullet に当たると Enemy の hp を1削る．
  // 連続攻撃に対処するため，攻撃を受けた後は一定時間攻撃を受けない
  private void hit(){
    if(!isHitted()) return;
    //if(!isInvincible()){
      lastHitTime_ms = millis();
      is_dead = (--hp == 0);
      divideSelf();
    //}
  }
  
  // 内藤担当箇所
  // Enemy が無敵かどうか
  private Boolean isInvincible(){
    return (millis() - lastHitTime_ms) < INVINCIBLE_TERM_MS;
  }
  
  // 内藤担当箇所
  // Bullet に当たったかを判定する
  private Boolean isHitted(){
    for(Player player : world.getPlayers()) {
      ArrayList<Bullet> pBullets = player.getBullets();
      
      for(Bullet pBullet : pBullets){
        //モートン番号が異なる場合は衝突判定を計算しない
        if(world.mt.getMortonNum(pBullet.getPosition())!=world.mt.getMortonNum(this.position))
          continue;

        float dist = PVector.sub(pBullet.getPosition(), this.position).mag();
        // 衝突判定
        if (dist < size/2) {
          pBullets.remove(pBullet);
          return true;
        }
      }
    }
    return false;
  }
  
  // 内藤担当箇所
  // Enemy を2つに分裂する
  protected void divideSelf(){
    if(hp == 0) return;
    size /= 2;
    Enemy brother = new Enemy(new PVector(this.position.x, this.position.y), this.size, this.hp, lastHitTime_ms);
    world.getEnemies().add(brother);
  }

  public ArrayList<Bullet> getBullets() { return bullets; }
  
  public PVector getPosition() { return this.position; }
  
  public void keyPressed(int key) {}
  public void mousePressed() {}

  //金子作成関数
  //自機方向を中心に30度角度をつけた三方向に射撃する関数．
  private void threeWayShoot(PVector playerPos){
    PVector toPlayerVec = PVector.sub( playerPos, this.position);
    
    //2021須賀修正分：PI/3→PI/6
    float deg = PI / 6; //これで30度角になる．

    for(int i=0 ; i<3 ; i++){
      float tmp_deg = -deg + deg * i;
      PVector tmp_Vec = toPlayerVec.copy().rotate(tmp_deg).normalize().mult(2.0);
      int damage = int(random(5,10));
      
      PVector bulletPos = new PVector();
      bulletPos = this.position.copy();
      bullets.add(new Bullet(bulletPos,tmp_Vec,damage,false));
//      bullets.add(new Bullet(position,tmp_Vec,damage)); //とりあえず動かすために戻しました。後でfalse入れる
    }
  }


  //Kaneko
  //threeWayshootのタイミング調整を行う関数．
  //ひたすらshoot内で呼べばタイミング通り打てる．
  private void threeWayShooter_addtiming(int timing_ms){
      int time = millis() / timing_ms;

    if(time % 2 == 0 && !this.isShooted){
      //梶本コメント。threeWayShootの引数がなかったので修正しました。
      for(Player player : world.getPlayers()) {
        threeWayShoot(player.position);

        //tmp++;
      }
      this.isShooted = true;

    }
    if(time%2 == 1){
      this.isShooted = false;

    }

  }



  //金子作成関数
  //弾の描画をするための関数．exampleブランチ内で木内くんが書いていたコードをそのまま援用．
  //draw内にて呼んでいます．
  //梶本コメント：これはBulletクラス中で書いたほうが良い？Bulletチームに依頼？
  private void drawBullets(){
      
      //for(int b_idx = 0; b_idx < bullets.size(); b_idx++) {
      for(int b_idx = bullets.size()-1; b_idx >= 0 ; b_idx--) { //removeがある場合のリストの扱い(Kajimoto)
        Bullet b = bullets.get(b_idx);
        //↓梶本コメント　これを入れると、bulletクラス中のupdate関数のthis.position.addが、
        //  Enemy本体に適用されてしまいます（ここではenemy = thisなので）。
        //  そのためenemy本体が吹っ飛んでいきます。
        //金子コメント　
        //Enemyを吹っ飛ばなくするために，新たにbullet用の座標クラスを作成しました．
        b.update(); 
        if(b.getPosition().x < 0 || b.getPosition().x > width
        || b.getPosition().y < 0 || b.getPosition().y > height){
          bullets.remove(b_idx);
        }
        else 
          b.draw();
    }
  }
}


class Boss extends Enemy{
  private boolean isShooted_Nway;
  private int numShoot_NWay;
  private int bulletSpeed_Nway;
  private int shootTiming_Nway;
  
  private int movespeed;

  public Boss(PVector pos){
    super(pos);
    
    movespeed = 2;
    isShooted_Nway = false;
    numShoot_NWay = 40;
    bulletSpeed_Nway =int(random(3,6));
    shootTiming_Nway = int(random(200,400));
    super.shootingTiming_ms= int(random(50,200));
       

    super.size = 150;
    super.heartbeat_phase = random(2.0*PI);
    super.heartbeat_freq = 400.0;
    super.hp = 10;
  }
  
  public void move(){//ボスの動き
    position.y = size+(size-10)*world.sc.sin[millis()/10%360];
    position.x += movespeed;
    if(position.x > width || position.x < 0){
      movespeed *= -1;
    }
  }
  
  // 内藤担当箇所
  // Boss を分裂させない
  protected void divideSelf(){
  }

  public void shoot(){
    super.shoot();
    Nwayshooter_addtiming(shootTiming_Nway);

  }
  

  //金子作成関数，ボス用
  //敵を中心に360度で全方向に打つ関数．射撃する密度は numWayから設定可能．  
  private void NwayShoot(int numWay,int bulletSpeed){
    PVector stdVec = new PVector(0,bulletSpeed);
    float deg = TWO_PI / numWay;

    for(int i=0; i<numWay; i++){
      PVector tmp_Vec = stdVec.copy().rotate(deg * i);
      int damage = int(random(5,10));//とりあえず設定．player側の体力と相談？
      PVector bulletPos = new PVector();
      bulletPos = this.position.copy();
      super.bullets.add(new Bullet(bulletPos,tmp_Vec,damage,false));
      //super.bullets.add(new Bullet(position,tmp_Vec,damage));//後々falseを入れて修正．

    }

  }

  private void Nwayshooter_addtiming(int timing_ms){
     int time = millis() / timing_ms;

    if(time % 2 == 0&& !this.isShooted_Nway){
      NwayShoot(numShoot_NWay,bulletSpeed_Nway);
      this.isShooted_Nway = true;

    }
    
    if(time%2 == 1){
      this.isShooted_Nway = false;

    }
  }

}
