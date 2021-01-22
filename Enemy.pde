class Enemy extends Enemy_Base{
  public Enemy(PVector pos) {
    super(pos);
    sethp(10);
    setsize(100);
    attribute=random(0,1)>0.5f?#ff0000:#0000ff;
  }

  //Override
  // Enemy を描画する関数
  public void draw() {
    //int r = (int) (world.sc.sin[int(millis()/heartbeat_freq + heartbeat_phase)%360]*10.0);
    //int c = (int) (world.sc.sin[int(millis()/heartbeat_freq + heartbeat_phase)%360]*50.0); //±50
    //fill(200+c,50-c,50-c);
    //noStroke();
    //circle(position.x,position.y,size+r);

    push();
    imageMode(CENTER);
    tint(attribute,128);
    image(mouse_white, position.x, position.y, size*2+30, size*2+30);
    tint(255,255);

    //2020矢野変更:敵を赤丸からネズミの画像に置き換え
    image(mouse_white, position.x, position.y, size*2, size*2);
    drawhp(80);
    pop();
  }
  //Override
  public void move(){
    if(moveselect == 0){//矢野変更:動きパターン1　まっすぐ
      /*if(millis()/1000 % moveflag == 0){*/
        position.add(velocity);
      /*}else{
        position.add(-velocity.x ,velocity.y);
      }*/
    }else{//動きパターン2　Playerに向けて動く
      position.add(velocity2);
    }
  }

  //Override
  public void shoot() {
    threeWayShooter_addtiming(shootingTiming_ms);
  }

  //自機方向を中心に30度角度をつけた三方向に射撃する関数．
  private void threeWayShoot(PVector playerPos){
    PVector toPlayerVec = PVector.sub( playerPos, this.position);
    float deg = PI / 6; //これで30度角になる．

    for(int i=0 ; i<3 ; i++){
      float tmp_deg = -deg + deg * i;
      PVector tmp_Vec = toPlayerVec.copy().rotate(tmp_deg).normalize().mult(2.0);
      int damage = int(random(10,15));
      
      PVector bulletPos = new PVector();
      bulletPos = this.position.copy();
      world.addEnemyBullets(new Bul_Normal(bulletPos,tmp_Vec,damage,false,getAttributeRandomReverse(0.8)));
      //bullets.add(new Bullet(position,tmp_Vec,damage)); //とりあえず動かすために戻しました。後でfalse入れる
    }
  }

  //threeWayshootのタイミング調整を行う関数．
  //ひたすらshoot内で呼べばタイミング通り打てる．
  private void threeWayShooter_addtiming(int timing_ms){
    int time = millis() / timing_ms;
    if(time % 2 == 0 && !this.isShooted){
      //梶本コメント。threeWayShootの引数がなかったので修正しました。
      for(Player player : world.getPlayers()) {
        threeWayShoot(player.position);
      }
      this.isShooted = true;
    }
    if(time%2 == 1){
      this.isShooted = false;
    }
  }

  public void keyPressed(int key) {}
  public void mousePressed() {}
}

class Boss extends Enemy_Base{
  private boolean isShooted_Nway;
  private int numShoot_NWay;
  private int bulletSpeed_Nway;
  private int shootTiming_Nway;
  private int movespeed;
  private PImage img;
  private int cnt;

  public Boss(PVector pos){
    super(pos);
    sethp(30);
    setsize(150);
    movespeed = -1;
    isShooted_Nway = false;
    numShoot_NWay = 40;
    bulletSpeed_Nway =int(random(3,6));
    shootTiming_Nway = int(random(1000,2000)); //矢野変更:タイミングを変更
    super.shootingTiming_ms= int(random(200,500));
    super.heartbeat_phase = random(2.0*PI);
    super.heartbeat_freq = 400.0;
    img = loadImage("data/mouse.png");
    attribute=random(0,1)>0.5f?#ff0000:#0000ff;
  }

  //Override
  // Enemy を描画する関数
  public void draw() {
    //int r = (int) (world.sc.sin[int(millis()/heartbeat_freq + heartbeat_phase)%360]*10.0);
    //int c = (int) (world.sc.sin[int(millis()/heartbeat_freq + heartbeat_phase)%360]*50.0); //±50
    //fill(200+c,50-c,50-c);
    //noStroke();
    push();
    ellipseMode(CENTER);
    imageMode(CENTER);
    fill(attribute,128);
    noStroke();
    circle(position.x,position.y,size*1.1);
    fill(235);
    circle(position.x,position.y,size);
    //2020矢野変更:敵を赤丸からネズミの画像に置き換え
    image(img, position.x, position.y, size*1.8, size*1.8);
    drawhp(200);
    pop();

    //150frame毎に属性が反転する
    if(cnt++>150){
      attribute=~((attribute&0xffffff)+0xff00);
      cnt=0;
    }
  }
  //Override
  public void move(){//ボスの動き
    //position.y = size+(size-10)*world.sc.sin[millis()/10%360];
    //矢野変更:ボスが右から入ってきて静止する
    if(position.x > width * 0.7){
      position.x += movespeed;
    }
    /*
    position.x += movespeed; //
    if(position.x > width || position.x < 0){
      movespeed *= -1;
    }
    */
  }

  //Override
  public void shoot(){
    threeWayShooter_addtiming(shootingTiming_ms);
    Nwayshooter_addtiming(shootTiming_Nway);
  }

  //自機方向を中心に30度角度をつけた三方向に射撃する関数．
  private void threeWayShoot(PVector playerPos){
    PVector toPlayerVec = PVector.sub( playerPos, this.position);
    float deg = PI / 6; //これで30度角になる．

    for(Player player : world.getPlayers()) {
      for(int i=0 ; i<3 ; i++){
        int randattribute=random(0,1)>0.6f?player.getPlayerAttribute():~((player.getPlayerAttribute()&0xffffff)+0xff00);
        float tmp_deg = -deg + deg * i;
        PVector tmp_Vec = toPlayerVec.copy().rotate(tmp_deg).normalize().mult(2.0);
        int damage = int(random(10,15));
        
        PVector bulletPos = new PVector();
        bulletPos = this.position.copy();
        world.addEnemyBullets(new Bul_Normal(bulletPos,tmp_Vec,damage,false,randattribute));
        //bullets.add(new Bullet(position,tmp_Vec,damage)); //とりあえず動かすために戻しました。後でfalse入れる
      }
    }
  }

  //threeWayshootのタイミング調整を行う関数．
  //ひたすらshoot内で呼べばタイミング通り打てる．
  private void threeWayShooter_addtiming(int timing_ms){
    int time = millis() / timing_ms;
    if(time % 2 == 0 && !this.isShooted){
      //梶本コメント。threeWayShootの引数がなかったので修正しました。
      for(Player player : world.getPlayers()) {
        threeWayShoot(player.position);
      }
      this.isShooted = true;
    }
    if(time%2 == 1){
      this.isShooted = false;
    }
  }

  //敵を中心に360度で全方向に打つ関数．射撃する密度は numWayから設定可能．  
  private void NwayShoot(int numWay,int bulletSpeed){
    PVector stdVec = new PVector(0,bulletSpeed);
    float deg = TWO_PI / numWay;

    for(Player player : world.getPlayers()) {
      for(int i=0; i<numWay; i++){
        int randattribute=random(0,1)>0.8f?player.getPlayerAttribute():~((player.getPlayerAttribute()&0xffffff)+0xff00);
        PVector tmp_Vec = stdVec.copy().rotate(deg * i);
        int damage = int(random(5,10));//とりあえず設定．player側の体力と相談？
        PVector bulletPos = new PVector();
        bulletPos = this.position.copy();
        world.addEnemyBullets(new Bul_Normal(bulletPos,tmp_Vec,damage,false,randattribute));
        //super.bullets.add(new Bullet(position,tmp_Vec,damage));//後々falseを入れて修正．

      }
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
