# それぞれのクラス

## Player

- プレイヤが操作するオブジェクト
- HPを持っていて敵からの攻撃によって, HPが減っていきます．
  - 0になってしまったら GAMEOVER

### member

- `private PVector position`         : 位置座標
- `private int HP`                   : Hit Point
- `private int size`                 : 当たり判定領域
- `private ArrayList<Bullet> bullets`: 発射した弾たち
- `private float angle`              : プレイヤーの角度
- `public boolean is_dead`           : プレイヤーの状態
- `private int hitCount, boostCount, shootCount, clushCount` 
- `private PVector[] debris`         : xにrad, yに変位

### `public void draw()`

- World からから呼ばれます．ここにPlayerを描画する処理を書いてください
  - 他の関数を実行したい場合は `draw`関数の中で実行するようにしてください.

### `public void keyPresssed(int key)`

- World からキーボード入力がそのまま渡されます

### 攻撃

### `public void shoot()`

- 弾を発射する関数 (例えば，何かキーが入力された時)
  - この弾はEnemyにダメージを与えることができる
  - 位置 (`pos`)，速度 (`vel`)，ダメージ量 (`dam`) で初期化します.
  - 発射した弾はリストとしてはPlayerのオブジェクトが持っています.
- `Bullet` の描画は Playerクラスが行います.

### 当たり判定

### `public void hitCheck()`

- `radius` が当たり判定エリアで, この領域内に弾が入ってきたら`当たり`になります.

### `public void hit(int damage)`

- 弾(`Bullet`)が当たった際の処理

### ゲッターやセッター

### `public ArrayList<Bullet> getBullets`

- 現在有効な発射した弾リストを返す

### `public PVector getPositon()`

- Player の現在位置を返す

### `public void setHP(int HP)`

- PlayerのHPをセットする

### `public int getHP()`

- Playerの現在のHPを返す

### `setLife()`

- Playerの現在のライフをセットする


### `getLife()`

- Playerの現在のライフを返す

### `drawProperties()`

- 

### `drawAircraft()`

-

### `drawDebri()`

-

### `animation()`

-

### `checkWall()`

-

### `calcHeadingAngle()`

-

### `changePosition()`

-

## Enemy

- 敵のクラス
- Worldクラスにenemy全体を管理する enemies というリストがあります．
- キーボードの`e` が押されるとEnemyが生成されます．
- 基本設計は守りつつ自由に実装しましょう！
  - アイコンを変えたり，弾から逃げる動きをしたり...

### member

- `private PVector position`         : 位置座標
- `private ArrayList<Bullet> bullets`: 発射した弾たち
- `private int size`                 : 当たり判定領域
- `public boolean is_dead`           : Dead or Alive
- `int hp`                           : HP
- `float heartbeat_phase,heartbeat_freq` :
- `private boolean isShooted`        :射撃したか保持する変数．
- `private int shootingTiming_ms`    :射撃タイミングの設定
- `private int moveselect`           :Enemyの動きを選択する
- `private int moveflag`             :動きを変えるタイミング
- `private PVector velocity`         :動きパターン1の速度
- `private PVector velocity2`        :動きパターンの速度
- `private long lastHitTime_ms`      :最後にBulletに当たった時刻(ms)
- `final int INVINCIBLE_TERM_MS = 1000`  : 無敵期間(ms)

### `public void draw()`

- `draw` 関数がWorldクラスから呼ばれます．ここにEnemyを描画する処理を書いてください
  - 他の関数を実行したい場合は `draw`関数の中で実行するようにしてください.

### `drawBulltes()`

- 弾の描画

### `public void keyPresssed(int key)`

- World からキーボード入力がそのまま渡されます

### 攻撃

### `public void shoot()`

- Enemyは弾 (`Bullet`) を発射します
  - この弾は Player にダメージを与えることができます
  - 位置 (`pos`)，速度 (`vel`)，ダメージ量 (`dam`) で初期化します.
  - 自分の発射した弾はリストとして各オブジェクトが持っています
- `Bullet` の描画は各Enemyが行います．

### `threewayShoot()`

- 

### `threeWayShooter_addtiming()`

-

### 移動

### `public void move()`

- 移動


### 当たり判定

- `update` 内部で当たり判定の処理をしています．
- `radius` が当たり判定のエリアで，この領域とPlayerが発射した弾が重なると`当たり`になります．

### `private void hit()`

- Player の弾が当たったときの処理
- `is_dead` フラグを立てると，そのEnemyはWorldクラスの中で死亡判定されオブジェクトが削除されます

### `Boolean isInvincible()`

-

### `private Bpplean isHitted()`

-

### `protected void divideSelf()`

-

### セッターゲッター
### `ArrayList<Bullet> getBullets()`

- 

## Bullet

- 弾のクラス
- `Player`と`Enemy`はこの`Bullet`クラスを利用して弾を発射します.
- 各`Bullet`オブジェクトはダメージ量 (`dam`)を持っていて，敵やプレイヤにあたった場合，その分だけダメージを与えます
- 爆発させよう！！

### member

- `private PVector position`: 位置座標
- `private PVector velocity`: 弾の速度
- `private int damage`      : 与えるダメージ量
- `private boolean is_player`: プレイヤーかどうか
- `private int moving_pattern`: 弾の軌道パターン
- `private PVector init_position`: 弾の位置
- `private int counter` : 
- `private SubBullet subBullet`
- `
- `private boolean explode` :爆発弾か
- `private boolean homing`: ホーミング弾か
- `private int b_timer` : 
- `private ArrayList<Enemy> enemies` : 

### 描画
### `public void draw()`

- `draw` 関数によって弾の描画を行います．この関数は発射したオブジェクト(PlayerかEnemy)によって呼び出されます

### `void explosion()`

- 爆発して消える弾

### `void homing()`

- ホーミングする弾


### 移動

### `void update()`

- `velocity`に合わせて位置 (`position`) を更新します.

### ゲッターセッター

### `public PVector getPosition()`

- 弾の位置をPVectorで返す

### `public int getDamage`

-　弾が与えるダメージ量を返す


## World

- Player や Enemy，及び背景の描画を担当するクラスです．
- `draw`関数がmainループから呼ばれており，Enemy.draw や Player.draw の呼び出しも行ってください
- なんでもできるゲームの支配者 _The World_

### member

- `int score`                        : スコア
- `private ArrayList<Player> players`: プレイヤーのリスト
- `private ArrayList<Enemy> ememies` : 敵のリスト
- `private Boss boss` : ボス
- `private PVector player_p` : player座標
- `private PImage back` : プレイ画面の背景
- `private int scene` 0: スタート画面，1: ゲーム画面，2: ゲームオーバー画面
- `private boolean boss_in` : true: boss出現

### `void init()`

- ゲーム開始時の処理

###　スタート画面
### `private void init_start()`

- スタート画面での初期化

### `draw_start()`

- スタート画面での毎フレームの処理

### ゲーム画面
### `private void init_game()`

- ゲーム画面の初期化

### `private void draw_game`

- ゲーム画面でのマイフレームの初期化

### `void drawHP()`

- プレイヤーのHPの描画

### `void drawLife()`

- プレイヤーのライフの描画

### `void drawScore`

- スコアの表示

### ゲームオーバー画面
### `private void init_over()`

- ゲームオーバー画面の初期化

### `private void draw_over()`

- ゲームオーバー画面でのマイフレームの処理

### `void changeSceneTo()`

- シーン遷移関数





### ゲッターセッター
### `ArrayList<Player> getPlayers()`

- 現在アクティブのPlayerのリストを返す

### `ArrayList<Enemy> getEnemies()`

- 現在アクティブのEnemeyのリストを返す

### `void draw()`

- Playerなどを含めた全体の描画

### `void keyPressed(int key)`

- main ループから key が渡されてきます
- enemies と players にkey をそのまま流し込みます．
- また，key に対応した処理も実装します

### `void keyReleased(int key)`

- main ループから key が渡されてきます
- players にkey をそのまま流し込みます．
- また，key に対応した処理も実装します



# その他
- Masterで使う機能は表示したい内容によって変えても構いません。

