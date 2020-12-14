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

void setup() {
  size(800, 600);
  frameRate(60);
  world = new World();
  world.init();
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
