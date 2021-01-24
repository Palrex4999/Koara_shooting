// ゾウさんチームが主に編集するところ
// 音楽やスタート演出、終了演出などがあるといい？シーン遷移があると、とてもいいと思います。
//ゲームシーンの遷移に関する
class World {
  //////////////////////////////////////////
  //2021須賀修正分：
  //変数宣言をクラス最上部にまとめた
  //アクセス修飾子を適切につけた
  //各変数にコメント追記・修正加えた
  public SinCos sc=new SinCos();//sin cosの計算済みデータ
  public Morton mt=new Morton();//モートン番号計算用クラス

  private int scene = 0; // 0: スタート画面，1: ゲーム画面，2: ゲームオーバー画面

  //スタート画面に用いる変数
  private int[] starsX_start, starsY_start;  //星の位置座標
  private final int starsNum_start = 300; //星の数
  private boolean shootingStarOn_start = false; //流れ星を流すか
  private int shootingStarX_start, shootingStarY_start;  //流れ星の位置座標

  private PImage titleImg_start_back; //スタート画面のタイトル画像
  private PImage titleImg_start; //スタート画面のタイトル画像
  private PImage pressEnter;

  //ゲーム画面に用いる変数
  private ArrayList<Player> players; //プレイヤー
  private ArrayList<Enemy> enemies; //敵
  public ArrayList<Bullet> enemybullets; //2021須賀追加：敵の弾を一括管理する
  private Boss boss; //ボス
  private int score;//得点
  private int lastHP_game = 0; //残りHP
  private int beated; //敵の撃破数
  private boolean boss_in = false; // true: boss出現
  private boolean isGameOver_game = false;//ゲームオーバーかどうか
  public boolean isGameClear_game = false;
  private int clearedCount=0;

  private PVector player_p;  //player座標

  //ゲームオーバー画面に用いる変数
  private int frameCount_over = 0;//ゲームオーバー画面の経過時間
  
  //ゲームクリア・ゲームオーバー画像
  private PImage gameclear;
  private PImage gameover;

  //2021須賀追加：弾UI
  private PImage e,q,r,f;
  private PImage e_fig,q_fig,r_fig,f_fig;
  private PImage frame,selectframe;
  private int transUI=255;
  
  //音
  private Minim minim;
  private AudioPlayer bgm_start, bgm_game, bgm_over;
  private AudioPlayer sound_pikin;

  //背景スクロール2020矢野追加
  final int SCROLL_SPEED = 1; //スクロールスピード
  private PImage haikei; //スクロール用画像
  private int sx = 0; //切り出し位置
  private int sy = 0; //切り出し位置
  
  //////////////////////////////////////////

  public ArrayList<Player> getPlayers() { return this.players; }
  public ArrayList<Enemy> getEnemies() { return this.enemies; }
  public Boss getBoss() { return this.boss; }  
  public ArrayList<Bullet> getEnemyBullets() {return this.enemybullets;}//2021須賀追加
  public void addEnemyBullets(Bullet b) {enemybullets.add(b);}//2021須賀追加：敵の弾を追加する

  public World() {
    players = new ArrayList<Player>();
    enemies = new ArrayList<Enemy>();
    enemybullets = new ArrayList<Bullet>();

    //日本語表示対応
    PFont font = createFont("MS Gothic",50);
    textFont(font);
    //サウンド関係
    minim = new Minim(getPApplet());
    bgm_start = minim.loadFile("opening.mp3");
    bgm_game = minim.loadFile("playing.mp3");
    bgm_over = minim.loadFile("clear.mp3");
    sound_pikin = minim.loadFile("button31.mp3");

    init();
  }

  void draw() {
    if(scene == 1){
      draw_game();
    }else if(scene == 2){
      draw_over();
    }else{
      draw_start();
    }
  }

  void init() {
    scene = 0;
    haikei = loadImage("night_sky.png");
    gameclear = loadImage("gameclear.png");
    gameover = loadImage("gameover.png");
    e=loadImage("e.png");
    q=loadImage("q.png");
    r=loadImage("r.png");
    f=loadImage("f.png");
    e_fig=loadImage("e_fig.png");
    q_fig=loadImage("q_fig.png");
    r_fig=loadImage("r_fig.png");
    f_fig=loadImage("f_fig.png");
    frame=loadImage("frame.png");
    selectframe=loadImage("selectframe.png");
    init_start();
  }

  /**************** スタート画面 **************************/
  private void init_start() {
    // スタート画面での初期化

    //星の位置をランダムで決定
    starsX_start = new int[starsNum_start];
    starsY_start = new int[starsNum_start];
    for(int i=0; i<starsNum_start; i++){
      starsX_start[i] = (int)random(0, width);
      starsY_start[i] = (int)random(0, height);
    }

    shootingStarOn_start = false;
    titleImg_start_back = loadImage("start_image.jpg");
    titleImg_start = loadImage("title.png");
    pressEnter = loadImage("pressEnter.png");
    
    //BGM
    bgm_start.rewind();
    bgm_start.loop();
  }

  private void draw_start() {
    // スタート画面での毎フレームの処理
    background(25, 25, 50);
    
    //タイトル画像を表示
    image(titleImg_start_back, width/2+40, height/2+15);

    //星を描画
    for(int i=0; i<starsNum_start; i++){
      int brightness = (int)random(100, 255);
      fill(brightness, brightness, 200);
      noStroke();
      rect(starsX_start[i], starsY_start[i], 1, 1);
    }

    if(shootingStarOn_start){
      // 流れ星があるならそれを流れさせる，確率で消す
      shootingStarX_start -= 4;
      shootingStarY_start += 3;
      fill(200);
      noStroke();
      rect(shootingStarX_start, shootingStarY_start, 3, 3);

      if(random(0, 1) < 0.02f){
        shootingStarOn_start = false;
      }
      if(shootingStarX_start < 0 || shootingStarY_start > height){
        shootingStarOn_start = false;
      }
    }else{
      // 流れ星が無いなら確率で流れ星を発生させる
      if(random(0, 1) < 0.01f){
        shootingStarX_start = (int)random(100, width);
        shootingStarY_start = (int)random(0, height-100);
        shootingStarOn_start = true;
      }
    }

    image(titleImg_start, width/2, 230, 600, 320);
    image(pressEnter, width/2, 400);
  }

  /***************** ゲーム画面 **************************/
  private void init_game() {
    // ゲーム画面での初期化
    players = new ArrayList<Player>(); 
    enemies = new ArrayList<Enemy>();
    enemybullets = new ArrayList<Bullet>();
    //プレイヤーの生成
    Player p = new Player(new PVector(width/2.0, height * (3/4.0)));
    players.add(p);
    isGameOver_game = false;
    isGameClear_game = false;
    //ボスの生成
    boss = new Boss(new PVector(width*1.2, height/2));  //矢野変更：ボスの位置を画面外右に
    boss_in = false;

    bgm_game.rewind();
    bgm_game.loop();

    for (Player player : players) {
      player_p = player.getPosition();
    }

    //////////////////////////////////////////
    //2021須賀追記分：
    //リトライ時にスコアや撃破数をリセットした真っ新な状態にする
    score=0;
    beated=0;
    clearedCount=0;
    //////////////////////////////////////////
  }

  private void draw_game() {
    // ゲーム画面での毎フレームの処理
    //image(back, -player_p.x, -player_p.y);
    PImage back = getDisplayImage(); //2020矢野追加
    background(back);

    lastHP_game = 0;
    //120フレームごとに敵を追加
    if(frameCount%120==0 && !boss_in) {
      Enemy e = new Enemy(new PVector(random(width, width*1.2), random(height*0.1, height*0.9))); //画面外に生成
      Enemy e2 = new Enemy(new PVector(random(width, width*1.2), random(height*0.1, height*0.9))); //画面外に生成
      enemies.add(e);
      enemies.add(e2);
    }
    //敵の毎フレームごとの処理
    for(int e_idx = 0; e_idx < enemies.size(); e_idx++) {
      Enemy enemy = enemies.get(e_idx);
      enemy.update();
      if(enemy.is_hit){ //弾がヒットしたら
        score+=10;
      }
      if(enemy.is_absorb){ //弾が吸収されたら
        score-=10;
        enemy.is_absorb=false;
      }
      if(enemy.is_dead){ //敵が死んだら
        enemies.remove(e_idx);
        score+=500;
        beated++;
      }
      else 
        enemy.draw();
    }

    //2021須賀追加：敵消滅後の弾の描画処理
    for(int b_idx = enemybullets.size()-1; b_idx >= 0 ; b_idx--) {
      Bullet b = enemybullets.get(b_idx);
      b.update(); 
      if(b.getPosition().x < 0 || b.getPosition().x > width
      || b.getPosition().y < 0 || b.getPosition().y > height){
        enemybullets.remove(b_idx);
      }
      else 
        b.draw();
    }

    if(boss_in){ //ボス登場
      if (boss.is_dead){ // Bossが倒されたらisGameClear_gameをtrueにする
        if(!isGameClear_game){
          score+=10000;//2021須賀追加：Bossが倒されたら10000点
          beated++;
        }
        isGameClear_game = true;
      }else{
        boss.update();
        boss.draw();
        if(boss.is_hit){ //弾がヒットしたら
        score+=10;
        }
      }
      if(boss.is_absorb){ //弾が吸収されたら
        score-=10;
        boss.is_absorb=false;
      }
    }else if(beated>=10){ // enemy撃破数でtrueに変更
      boss_in = true;
    }
    //プレイヤーの毎フレームごとの処理
    for(Player player : players) {
      player.update();
      player.draw();
      player_p = player.getPosition();

      //UIの表示
      drawHP(player);
      drawAbsorb(player);
      drawScore();

      //HP管理
      if(player.getHP()<=0){
        player.setHP(100);
        player.life--;
        fill(255);
        textSize(30);
        delay(500);
      }

      //弾吸収時
      if(player.absorbed){
        score+=100;
        player.absorbed=false;
      }

      //ライフ管理
      if(player.getLife()<=0)
        isGameOver_game = true;

      lastHP_game += player.getHP();
    }

    //弾UI描画
    drawBulletsUI();


    if(isGameOver_game || isGameClear_game)
      if(clearedCount<60 && isGameClear_game)clearedCount++;
      else changeSceneTo(2);
  }

 void drawHP(Player player){ //残りHPの描画
      fill(255);
      text("HP",10,35);
      fill(200);
      rect(60,8,200,30);
      fill(255,0,0);
      rect(60,8,player.getHP()*2,30);
  }

  void drawAbsorb(Player player){ //吸収数の描画
      fill(255);
      text("Absorb",10,65);
      fill(200);
      rect(60,70,200,10);
      fill(0,230,0);
      rect(60,70,player.getAbsorbNum()*20,10);
  }

 void drawLife(Player player){ //残りライフの描画
      fill(255);
      textSize(30);
      text("LIFE:"+player.getLife(),100,70);
  }

 void drawScore(){ //スコアの表示
    fill(255);
    textSize(30);
    text("SCORE:"+score,width/2.0,35);
  }

  void drawBulletsUI(){//弾UI描画
    //マウスカーソルやプレイヤーが近づくと半透明化
    if((mouseX<400 && mouseY>height-125) || (player_p.x<420 && player_p.y>height-125))transUI=max(transUI-(16+transUI/20),66);
    else transUI=min(transUI+16,255);

    tint(255,transUI);
    for(int i=0;i<4;i++){
      image(frame,50+100*i,height-48);
      for (Player player : players) {
        if(i==player.getBulletType()){
          image(selectframe,50+100*i,height-48);
        }
      }
    }
    
    image(e_fig,50,height-48);
    image(e,20,height-16);
    
    image(q_fig,150,height-48);
    image(q,120,height-16);

    image(r_fig,250,height-48);
    image(r,220,height-16);

    image(f_fig,350,height-48);
    image(f,320,height-16);
    tint(255,255);
  }

  /************* ゲームオーバー画面 ***********************/
  private void init_over() {
    // ゲームオーバー画面での初期化
    background(25, 25, 50);
    fill(255);
    rect(50, 50, width-100, height-100);
    frameCount_over = 0;

    bgm_over.setGain(-10);
    bgm_over.rewind();
    bgm_over.loop();
  }

  private void draw_over() {
    // ゲームオーバー画面での毎フレームの処理
    if(isGameClear_game) image(gameclear, width/2, 120);
    if(isGameOver_game) image(gameover, width/2, 120);
    
    textAlign(LEFT);
    text("Score : ", 100, 200, width-200, 100);
    text("Beated : ", 100, 300, width-200, 100);

    if(frameCount_over > 40){ // スコアを時間差で表示
      textAlign(RIGHT);
      text(str(score), 100, 200, width-200, 100);
    }

    if(frameCount_over > 80){ // 残りHPを時間差で表示
      textAlign(RIGHT);
      text(str(beated), 100, 300, width-200, 100);
    }

    if(frameCount_over > 60){ // RetryボタンとExitボタンを時間差で表示
      fill(200);
      noStroke();
      rect(width/2-100-125, 440, 125, 50);
      rect(width/2+100, 440, 125, 50);
      noFill();
      stroke(150);
      strokeWeight(4);
      rect(width/2-100-120, 445, 115, 40);
      rect(width/2+100+5, 445, 115, 40);
      fill(50);
      textAlign(CENTER);
      text("Retry", width/2-100-125, 450, 125, 100);
      text("Exit", width/2+100, 450, 125, 100);
    }

    textAlign(LEFT);
    strokeWeight(1);
    frameCount_over ++;
  }

  /********************************************************/

  void changeSceneTo(int sceneNo){ // 引数sceneNoのシーンへ遷移
    // sceneNo は 0:スタート画面，1:ゲーム画面，2:ゲームオーバー画面
    if(sceneNo == 1){
      
      bgm_start.pause();
      bgm_over.pause();
      
      score=1;

      scene = 1;
      init_game();
    }else if(sceneNo == 2){
      bgm_game.pause();
      scene = 2;
      init_over();
    }else{
      bgm_over.pause();
      scene = 0;
      init_start();
    }
  }

  //キーボード処理
  void keyPressed(int key) {
    if(scene == 0){ // スタート画面
      if(key == ENTER){
        sound_pikin.rewind();
        sound_pikin.play();
        changeSceneTo(1); //ゲーム画面に遷移
      }
    }


    if(scene == 1){ // ゲーム画面
      if(key == 'a'){
        //isGameOver_game = true; // デバッグ用
      }
    }

    if(scene == 2){ // ゲームオーバー画面
      if(key == ENTER){
        sound_pikin.rewind();
        sound_pikin.play();
        changeSceneTo(0); //タイトル画面に遷移
      }
    }

    for(Player player : players) player.keyPressed(key);
    for(Enemy enemy : enemies) enemy.keyPressed(key);
  }
  
  void keyReleased(int key){
    for(Player player : players) player.keyReleased(key);
  }
  
  //マウス処理
  void mousePressed(){
    if(scene == 1){
      for(Player player : players) player.mousePressed();
      for(Enemy enemy : enemies) enemy.keyPressed(key);
    }
    
    if(scene == 2){ // ゲームオーバー画面
      if(450 < mouseY && mouseY < 450+100){
        if(width/2-100-125 < mouseX && mouseX < width/2-100){ // Retryボタン
          changeSceneTo(1); //ゲーム画面に遷移
          sound_pikin.rewind();
          sound_pikin.play();
        }
        if(width/2+100 < mouseX && mouseX < width/2+100+125){ // Exitボタン
          sound_pikin.rewind();
          sound_pikin.play();
          getPApplet().stop();
          exit(); //アプリケーションを終了
        }
      }
    }
  }



  void stopMusic(){
    bgm_start.close();
    bgm_game.close();
    bgm_over.close();
    sound_pikin.close();
    minim.stop();
  }

  //---------------------------------------------
  //スクロール用画像から、画面に表示したい部分を
  //切り取って、表示用画像として生成する処理
  //---------------------------------------------
  PImage  getDisplayImage(){
    int  cutWidth = width;  //切り出せる幅
    int  overWidth = 0;     //飛び出し幅（解説の★幅）
    
    //表示用画像領域を作成
    PImage  map = createImage(width, height, ARGB);
  
    //切り出したい画像の幅が、スクロール用画像の左端からはみ出した時
    if(sx + width > haikei.width){
      //切り出せる幅と、飛び出した幅を計算
      overWidth = (sx + width) - haikei.width;  
      cutWidth = width - overWidth;
    }
  
    //スクロール用画像から、一部を切り出して、貼り付ける
    PImage  cutLeftImg = haikei.get( sx, 0, cutWidth, height );
    map.set( 0, 0, cutLeftImg );
  
    //もし飛び出していたら、スクロール用画像の左端から、
    //飛び出し幅分の画像を切りとって、mapの右側に貼り付ける
    if(overWidth > 0){
      PImage  cutRightImg = haikei.get( 0, 0, overWidth, height );
      map.set( cutWidth, 0, cutRightImg );
    }
  
    //次の切り出し位置を、右にずらす（スクロールする）
    sx = sx + SCROLL_SPEED;
    if(sx >= haikei.width){
      //切り出し位置が、スクロール用画像の右端になったので先頭に戻す
      sx = 0;
    }
  
    //作成した表示用画像を返却する
    return( map );
  }
}
