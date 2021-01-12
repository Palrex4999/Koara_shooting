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
  protected ArrayList<Bullet> bullets;
  float heartbeat_phase,heartbeat_freq;
  protected boolean isShooted;//射撃したか保持する変数．
  protected int shootingTiming_ms;//射撃タイミングの設定
  protected int moveselect;//Enemyの動きを選択する
  protected int moveflag;//動きを変えるタイミング
  protected PVector velocity;//動きパターン1の速度
  protected PVector velocity2 = new PVector(0,0);//動きパターン2の速度
  protected long lastHitTime_ms;  //最後にBulletに当たった時刻(ms)
  public boolean is_dead; //死んだかどうか
  public boolean is_hit; //2021須賀追加:たまに当たっているかどうか
  final int INVINCIBLE_TERM_MS = 1000;  // 無敵期間(ms)

  public Enemy_Base (PVector pos) {
    position = pos;
    bullets = new ArrayList<Bullet>();
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
  }

  //Enemy_Baseを継承したクラス内で↓をオーバーライドする
  abstract public void move(); //移動
  abstract public void shoot(); //弾を発射
  abstract public void draw(); //敵キャラと弾の描画
 
  //↓全敵共通
  protected void sethp(int hp){
    this.hp = hp;
  }
  protected void setsize(int size){
    this.size = size;
  }

  // Player の Bullet に当たると Enemy の hp を1削る．
  protected void hit(){
    is_hit=isHitted();
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

  //Update
  public void update() {
    move();
    shoot();
    hit();
  }

  //draw内にて呼んでいます．
  //梶本コメント：これはBulletクラス中で書いたほうが良い？Bulletチームに依頼？
  //2020矢野変更:private→protected
  protected void drawBullets(){

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

  protected ArrayList<Bullet> getBullets() { return bullets; } //弾の配列を得る
  protected PVector getPosition() { return this.position; } //自分の位置を返す

} 
