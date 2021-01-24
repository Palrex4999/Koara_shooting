import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

// mainの処理を行う.pdeファイルです。
// 基本的にここをいじらなくていいようにクラス分けした実装を行なっています。
// ここを変更するときは、他の人とコンフリクトが起きないように注意してください。

World world;
public PImage fish1,fish2,fish3,fish4;
public PImage mouse_white;
public PImage cheese;

void setup() {
  size(800, 600);
  frameRate(30);
  noSmooth();  
  world = new World();
  world.init();
  fish1 = loadImage("data/fish1.png");
  fish2 = loadImage("data/fish2.png");
  fish3 = loadImage("data/fish3.png");
  fish4 = loadImage("data/fish4.png");
  cheese = loadImage("data/cheese.png");
  mouse_white = loadImage("data/mouse_white.png");
  ellipseMode(CENTER);
  imageMode(CENTER);
}

void draw() {
  world.draw();
}

void keyPressed() {
  world.keyPressed(key);
}

void keyReleased() {
  world.keyReleased(key);
}

void mousePressed() {
  world.mousePressed(); 
}

PApplet getPApplet() { // Worldクラスで音再生に使用（Minimのインスタンスの引数）
  return this;
}

void stop(){
  world.stopMusic();
}
