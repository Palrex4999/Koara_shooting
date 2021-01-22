/*
Enemy_Baseをextendして敵キャラを作っていく

move()とshoot()はOveride
敵キャラ固有の弾の撃ち方は拡張したクラスで今のところ書く

アクセス修飾子もまだ
*/

abstract class Enemy_Base {
  //フィールドはとりあえずここにおいてあるけど、移動するかも？
  PVector position;
  protected int hp, size;
  float heartbeat_phase,heartbeat_freq;
  protected boolean isShooted;//射撃したか保持する変数．
  protected int shootingTiming_ms;//射撃タイミングの設定
  protected int moveselect;//Enemyの動きを選択する
  protected int moveflag;//動きを変えるタイミング
  protected PVector velocity;//動きパターン1の速度
  protected PVector velocity2 = new PVector(0,0);//動きパターン2の速度
  protected long lastHitTime_ms;  //最後にBulletに当たった時刻(ms)
  public boolean is_dead; //死んだかどうか
  public boolean is_hit; //2021須賀追加:弾に当たっているかどうか
  public boolean is_absorb; //2021須賀追加：弾を吸収しているかどうか
  private int maxHP;
  final int INVINCIBLE_TERM_MS = 1000;  // 無敵期間(ms)

  protected int attribute;

  public Enemy_Base (PVector pos) {
    position = pos;
    isShooted = false;
    shootingTiming_ms = int(random(200,400));
    
    moveselect = int(random(2));
    moveflag = int(random(2,4));
    velocity = new PVector(random(-3,-1), 0); //矢野変更:Enemyの速さを変更
    
    for(Player player : world.getPlayers()){
      velocity2 = PVector.sub(player.getPosition(),position).div(100);
    }
    heartbeat_phase = random(2.0*PI);
    heartbeat_freq = 200.0;
    lastHitTime_ms = 0L;
    is_absorb=false;
  }

  //Enemy_Baseを継承したクラス内で↓をオーバーライドする
  abstract public void move(); //移動
  abstract public void shoot(); //弾を発射
  abstract public void draw(); //敵キャラと弾の描画
 
  //↓全敵共通
  protected void sethp(int hp){
    this.hp = hp;
    maxHP = hp;
  }
  protected void setsize(int size){
    this.size = size;
  }

  protected void drawhp(int len){
    fill(255, 0, 0);
    int hpLength = (int)map(hp, 0, maxHP, 0, len);
    rectMode(CENTER);
    rect(position.x-20, position.y-size/1.5, hpLength, 5);
    rectMode(CORNER);
  }

  // Player の Bullet に当たると Enemy の hp を1削る．
  protected void hit(){
    is_hit=isHitted();
    if(is_absorb){//同じ属性の弾に当たったときは回復してしまう
      hp=min(maxHP,hp+1);
      return;
    }
    if(!is_hit)return;
    //if(!isInvincible()){
      lastHitTime_ms = millis();
      is_dead = (--hp == 0);
    //}
  }

  // Bullet に当たったかを判定する
  protected Boolean isHitted(){
    for(Player player : world.getPlayers()) {
      ArrayList<Bullet> pBullets = player.getBullets();
      
      for(Bullet pBullet : pBullets){
        //モートン番号が異なる場合は衝突判定を計算しない
        int shiftnum=world.mt.getShiftNum(this.position,this.size);
        if(world.mt.getMortonNum(pBullet.getPosition())>>shiftnum!=world.mt.getMortonNum(new PVector(this.position.x+size,this.position.y+size))>>shiftnum)
          continue;

        float dist = PVector.sub(pBullet.getPosition(), this.position).mag();
        // 衝突判定
        if (dist < size/2+pBullet.explosionsize) {
          if(pBullet.explosionsize==0)pBullets.remove(pBullet);
          if(pBullet.getAttribute()==this.attribute){
            is_absorb=true;
            return false;
          }
          return true;
        }
      }
    }
    return false;
  }

  //Update
  public void update() {
    move();
    shoot();
    hit();
  }

  protected PVector getPosition() { return this.position; } //自分の位置を返す

  //閾値prob未満のとき反転した属性を返す
  protected int getAttributeRandomReverse(float prob){return random(0,1)>prob?this.attribute:~((this.attribute&0xffffff)+0xff00);}

} 
