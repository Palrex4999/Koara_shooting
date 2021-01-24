/* 2021須賀修正
 * 抽象クラスBulletを継承して弾の種類別にクラスを持つように修正
 */

//標準弾
class Bul_Normal extends Bullet {
  //Player用のコンストラクタ
  public Bul_Normal (PVector pos, PVector vel,int attribute) {
    super(pos,vel,10,true,attribute);
  }

  //Enemy用のコンストラクタ
  public Bul_Normal (PVector pos, PVector vel, int dam,boolean player,int attribute) {
    super(pos,vel,dam,player,attribute);
  }
  
  @Override
  public void draw() {
    noStroke();
    if(is_player){ //プレイヤー
      fill(attribute,200); 
      circle(position.x, position.y, 15);
      tint(attribute,200);
      image(fish1, position.x, position.y, 35, 45);
      tint(255,255);
      image(fish1, position.x, position.y, 25, 35);
    }else{ //敵
      tint(attribute,164);
      image(cheese, position.x, position.y, 38, 38);
      tint(255,255);
      image(cheese, position.x, position.y, 30, 30);
    }
  }
}

//高速弾
class Bul_Boost extends Bullet {
  //Player用のコンストラクタ
  public Bul_Boost (PVector pos, PVector vel,int attribute) {
    super(pos,new PVector(vel.x*3,vel.y*3),5,true,attribute);
  }
  
  @Override
  public void draw() {
    noStroke();
    if(is_player){ //プレイヤー
      fill(attribute,200);
      circle(position.x, position.y, 11);
      tint(attribute, 200);
      image(fish3, position.x, position.y, 40, 50);
      tint(255,255);
      image(fish3, position.x, position.y, 25, 35);
    }else{ //敵
      fill(attribute,200);
      circle(position.x, position.y, 5);
    }
  }
}

//爆発弾
class Bul_Explosion extends Bullet{
  private int cnt=0;//爆発するまでのカウント
  private int b_timer=0;//爆発時間のタイマー
  private int b_range;//爆発範囲

  //Player用のコンストラクタ
  public Bul_Explosion (PVector pos, PVector vel,int attribute) {
    super(pos,new PVector(vel.x*0.8,vel.y*0.8),0,true,attribute);
  }
  
  @Override
  public void draw() {
    noStroke();
    if(is_player){ //プレイヤー
      //発射後30フレーム後爆発開始
      if(cnt<30){
        cnt+=1;
        fill(attribute,200);
        circle(position.x, position.y, 14);
        tint(attribute, 200);
        image(fish2, position.x, position.y, 40, 50);
        tint(255,255);
        image(fish2, position.x, position.y, 25, 35);
      }else{
        this.damage=50;
        explosion(5,30);
      }
      
    }else{ //敵
      fill(attribute,200);
      circle(position.x, position.y, 5);
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
    explosionsize=b_range;
  }
}

//追尾弾
class Bul_Homing extends Bullet{
  //Player用のコンストラクタ
  public Bul_Homing (PVector pos, PVector vel,int attribute) {
    super(pos,vel,5,true,attribute);
  }
  
  @Override
  public void draw() {
    noStroke();
    if(is_player){ //プレイヤー
      fill(attribute,200);
      circle(position.x, position.y, 12);
      tint(attribute, 200);
      image(fish4, position.x, position.y, 35, 45);
      tint(255, 255);
      image(fish4, position.x, position.y, 25, 35);
    }else{ //敵
      fill(attribute,200); 
      circle(position.x, position.y, 5);
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
