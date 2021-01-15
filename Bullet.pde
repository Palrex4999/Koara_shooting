/* 2021須賀修正
 * 抽象クラスBulletを継承して弾の種類別にクラスを持つように修正
 */

//標準弾
class Bul_Normal extends Bullet {
  //Player用のコンストラクタ
  public Bul_Normal (PVector pos, PVector vel) {
    super(pos,vel,10,true);
  }

  //Enemy用のコンストラクタ
  public Bul_Normal (PVector pos, PVector vel, int dam,boolean player) {
    super(pos,vel,dam,player);
  }
  
  @Override
  public void draw() {
    noStroke();
    if(is_player){ //プレイヤー
      for(int i=-6; i<=6; i=i+6){
        //circle(position.x, position.y, 12);
        image(fish1, position.x-15, position.y-20, 25, 35);
      }
    }else{ //敵
      //if(((millis())%400) > 200) fill(0, 0, 155, 400 - ((millis())%400));
      //else //fill(0, 0, 155, (millis())%200);
      for(int i=-4; i<=4; i=i+2){
        //circle(position.x, position.y, 5+(i*i));
        image(cheese, position.x-15, position.y-15, 30, 30);
      } 
    }
  }
}

//高速弾
class Bul_Boost extends Bullet {
  //Player用のコンストラクタ
  public Bul_Boost (PVector pos, PVector vel) {
    super(pos,new PVector(vel.x*3,vel.y*3),5,true);
  }
  
  @Override
  public void draw() {
    noStroke();
    if(is_player){ //プレイヤー
      for(int i=-6; i<=6; i=i+6){
        fill(255, 0, 0, 150);
        circle(position.x, position.y, 12);
        image(fish3, position.x-15, position.y-20, 25, 35);
      }
    }else{ //敵
      if(((millis())%400) > 200) fill(0, 0, 155, 400 - ((millis())%400));
      else fill(0, 0, 155, (millis())%200);
      for(int i=-4; i<=4; i=i+2){
        circle(position.x+i, position.y, 5+(i*i));
        circle(position.x, position.y+i, 5+(i*i));
      } 
    }
  }
}

//爆発弾
class Bul_Explosion extends Bullet{
  private int cnt=0;//爆発するまでのカウント
  private int b_timer;//爆発時間のタイマー
  private int b_range;//爆発範囲

  //Player用のコンストラクタ
  public Bul_Explosion (PVector pos, PVector vel) {
    super(pos,new PVector(vel.x*0.8,vel.y*0.8),0,true);
  }
  
  @Override
  public void draw() {
    noStroke();
    if(is_player){ //プレイヤー
      for(int i=-6; i<=6; i=i+6){
        fill(255, 0, 0, 150);
        circle(position.x, position.y, 12);
        image(fish2, position.x-15, position.y-20, 25, 35);
      }
    }else{ //敵
      if(((millis())%400) > 200) fill(0, 0, 155, 400 - ((millis())%400));
      else fill(0, 0, 155, (millis())%200);
      for(int i=-4; i<=4; i=i+2){
        circle(position.x+i, position.y, 5+(i*i));
        circle(position.x, position.y+i, 5+(i*i));
      } 
    }

    //発射後30フレーム後爆発開始
    if(cnt<30)cnt+=1;
    else{
      this.damage=50;
      explosion(5,30);
    }
  }

  //爆発して消える
  private void explosion(int speed, int time){
    velocity.x = 0;
    velocity.y = 0;
    b_range += speed;
    b_timer++;
    if(b_timer > time){
      if(b_range > 20){
        b_range -= 30;
      }else{
        b_range = 0;
        this.damage = 0;
        velocity.y = 500;
      }
    }
    fill(255,100, 0);
    circle(this.position.x, this.position.y, b_range);
  }
}

//追尾弾
class Bul_Homing extends Bullet{
  //Player用のコンストラクタ
  public Bul_Homing (PVector pos, PVector vel) {
    super(pos,vel,5,true);
  }
  
  @Override
  public void draw() {
    noStroke();
    if(is_player){ //プレイヤー
      for(int i=-6; i<=6; i=i+6){
        fill(255, 0, 0, 150);
        circle(position.x, position.y, 12);
        image(fish4, position.x-15, position.y-20, 25, 35);
      }
    }else{ //敵
      if(((millis())%400) > 200) fill(0, 0, 155, 400 - ((millis())%400));
      else fill(0, 0, 155, (millis())%200);
      for(int i=-4; i<=4; i=i+2){
        circle(position.x+i, position.y, 5+(i*i));
        circle(position.x, position.y+i, 5+(i*i));
      } 
    }
    homing();
  }

  //一番近い敵にホーミング
  private void homing(){
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

    //////////////////////////////////////////
    //2021須賀追記：
    //bossもホーミングの対象にする
    Boss boss=world.getBoss();
    tmpVec = PVector.sub(boss.position, this.position);
    tmpDistance = PVector.dist(boss.position, this.position);
    if(minDistance > tmpDistance){
      minDistance = tmpDistance;
      minVec = tmpVec;
    }
    //////////////////////////////////////////

    velocity = PVector.mult(minVec.normalize(), velocity.mag());
  }
}
