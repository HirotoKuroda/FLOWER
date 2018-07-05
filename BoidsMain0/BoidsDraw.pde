/** BoidsDrawクラス（ボイドの描画に関するクラス）**/
class BoidsDraw {

  Boid[] b; //ボイドの配列
  Flower[] f; //花の配列
  
  int f_pop = 1500;
  int pop;  //ボイドの総数（コンストラクタで指定）
  int count = 0;
  int num = 0;

  float trace_width = 0.5;  //ボイドの軌跡の線幅

  PGraphics pg_body;  //ボイドの描画レイヤ
  PGraphics pg_trace; //移動軌跡の描画レイヤ
  PGraphics pg_flower; //flowerLayer
  PGraphics pg_connect;
  PGraphics pg_cluster;

  boolean MODE_RULE1 = false; //ルール1の適用の有無
  boolean MODE_RULE2 = false; //ルール2の適用の有無
  boolean MODE_RULE3 = false; //ルール3の適用の有無
  boolean MODE_RULE4 = false; //ルール４
  boolean MODE_RULE5 = false; //ルール5
  boolean MODE_ATTRACT = true; //マウスを押した際の作用（true：引力, false：斥力）

  /** コンストラクタ **/
  //引数（p：ボイドの総数, w：画面の幅, h：画面の高さ）
  BoidsDraw(int p, int w, int h) {

    this.pop = p; //個体数をフィールドに代入

    //ボイドの配列を初期化
    b = new Boid[pop];
    
    //flower
    f = new Flower[f_pop];
    for(int i=0; i<f_pop; i++){
      f[i] = new Flower();
    }
    
    for(int i=0; i<16; i++){
      f[i].Exit();
      num++;
    }

    //ボイドをpop分だけ生成したのち, 初期化
    //（位置と速度をランダムに与える）
    for (int i=0; i<pop; i++) {
      b[i] = new Boid();
    }
    
    for (int i=1; i<pop; i+=2) {
      b[i].pos.x = b[i-1].pos.x - 8;
      b[i].pos.y = b[i-1].pos.y - 8;
      b[i].pos1.x = b[i-1].pos1.x - 8;
      b[i].pos1.y = b[i-1].pos1.y - 8;
      b[i].body_color = b[i-1].body_color;
    }

    //描画用のレイヤの生成
    pg_body = createGraphics(w, h, JAVA2D);
    pg_trace = createGraphics(w, h, JAVA2D);
    pg_flower = createGraphics(w,h,JAVA2D);
    pg_connect = createGraphics(w, h, JAVA2D);
    pg_cluster = createGraphics(w, h, JAVA2D);
  }

  /** メソッド **/

  //初期化（位置と速度をシャッフル）
  void init() {
    for (int i=0; i<pop; i++) {
      b[i].init();
    }
  }

  //位置の更新
  void updCondition() {

    //ボイドのルールの適用
    if (MODE_RULE1) 	applyRule1();
    if (MODE_RULE2)	applyRule2();
    if (MODE_RULE3)	applyRule3();
    if (MODE_RULE4)  applyRule4();
    if (MODE_RULE5)  applyRule5();

    //マウスが押されたときの作用
    if (mousePressed) {
      if (MODE_ATTRACT) {
        ruleAttractor(); //引力の発生
      } else {
        ruleSeparator(); //斥力の発生
      }
    }		

    //全てのボイドの位置を更新します. 
    for (int i=0; i<pop; i++) {
      b[i].upd();
      b[i].vmax = 20;
      if(MODE_RULE5) b[i].vmax =2.7;
    }
  }

  //ボイドをレイヤに描画（本画面に出力されないことに注意）
  void drawBoidsLayer() {
    drawBodyLayer();	//ボイドレイヤの描画
    drawTraceLayer(); //トレース・レイヤの描画
    drawFlowerLayer(); //flower 
    drawConnectLayer();
    drawClusterLayer();
  }


  //　ボイドレイヤの描画（ボイドの本体）
  void drawBodyLayer() {

    pg_body.beginDraw();//描画の開始

    //描画ここから---------------------------
    pg_body.clear();	//画面をクリア
    pg_body.noStroke(); //線を描かない

    for (int i=0; i<pop; i++) {
      //色の設定
      pg_body.fill(b[i].body_color);
      //i番目のボイドのx座標・y座標
      float ix = b[i].pos.x; 
      float iy = b[i].pos.y; 
      //円の描画
      pg_body.ellipse(ix, iy, b[i].body_size, b[i].body_size);
    }
    //描画ここまで---------------------------

    pg_body.endDraw(); //描画の終了
  }

  //　トレースレイヤの描画（ボイドの軌跡）
  void drawTraceLayer() {

    pg_trace.beginDraw(); //描画の開始

    //描画ここから---------------------------
    pg_trace.strokeWeight(trace_width); //軌跡の線の幅の設定

    for (int i=0; i<pop; i++) {
      //線の色の設定
      pg_trace.stroke(b[i].body_color);

      //i番目のボイドのx座標・y座標
      float ix0 = b[i].pos.x; 	
      float iy0 = b[i].pos.y; 			
      //i番目のボイドの1フレーム前のx座標・y座標
      float ix1 = b[i].pos1.x; 	
      float iy1 = b[i].pos1.y; 		

      //1フレーム前の位置と線を結ぶ	     		
      pg_trace.line(ix0, iy0, ix1, iy1);
    }
    //描画ここまで---------------------------

    pg_trace.endDraw(); //描画の終了
  }
  
  void drawFlowerLayer() {
    
    pg_flower.beginDraw();
    pg_flower.clear();
    pg_flower.noStroke();
    
    for(int i=0; i<f_pop; i++){
      if(f[i].exit==true){
        pg_flower.fill(f[i].f_color);
        float ix = f[i].x;
        float iy = f[i].y;
        float size = f[i].f_size;
        
        pg_flower.ellipse(ix, iy, size, size);
      }
    }
    pg_flower.endDraw();
  }
    

  void drawConnectLayer() {

    int a = 1;
    
    pg_connect.beginDraw();
    pg_connect.clear();

    for (int i=0; i<pop; i++) {

          pg_connect.stroke(b[i].color_connect);
          pg_connect.line(b[i].pos.x, b[i].pos.y, b[i+a].pos.x, b[i+a].pos.y);
          
          a *= -1;
    }
    pg_connect.endDraw();
  }


  void drawClusterLayer() {

    pg_cluster.noStroke();
    pg_cluster.fill(b[0].body_color);

    pg_cluster.beginDraw();
    pg_cluster.clear();

    BoidsCluster bc = new BoidsCluster(b);

    int gsum = bc.countCluster(pop/12);

    for (int g=0; g<gsum; g++) {
      Pos cp = bc.getClusterPos(g);
      float cd = bc.getClusterDistance(g);
      int cs = bc.getClusterSize(g);

      pg_cluster.ellipse(cp.x, cp.y, cd*2, cd*2);
    }

    pg_cluster.endDraw();
  }

  //ボイドレイヤを本画面に出力
  void showBody() {
    image(pg_body, 0, 0);
  }

  //トレースレイヤを本画面に出力
  void showTrace() {
    image(pg_trace, 0, 0);
  }
  
  void showFlower(){
    image(pg_flower, 0, 0);
  }

  void showConnect() {
    image(pg_connect, 0, 0);
  }

  void showCluster() {
    image(pg_cluster, 0, 0);
  }

  //トレースレイヤを消去
  void clearTrace() {
    pg_trace.beginDraw();
    pg_trace.clear();
    pg_trace.endDraw();
  }

  //ルール1（結合ルール）をここに書きましょう。
  void applyRule1() {	
    
      for (int i=0; i<pop; i++) {
      int count = 0;
      float sumx = 0;
      float sumy = 0;

      for (int j=0; j<pop; j++) {
        if (j !=i && b[i].isVisible(b[j])) {

          count++;
          sumx += b[j].pos.x;
          sumy += b[j].pos.y;
        }
      }

      if (count>0) {
        float ax = sumx/count;
        float ay = sumy/count;

        float c = dist(b[i].pos.x, b[i].pos.y, ax, ay)*0.7;

        Vel avel = new Vel((ax - b[i].pos.x)/c, (ay - b[i].pos.y)/c);
        b[i].vel.x += avel.x;
        b[i].vel.y += avel.y;
      }
    }
  }	
  //ルール2（分離ルール）をここに書きましょう。
  void applyRule2() {

    for (int i=0; i<pop; i++) {

      for (int j=0; j<pop; j++) {
        if (j !=i && b[i].isNeighbor(b[j])) {

          //print("a");

          float D = dist(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y);

          Vel avel = new Vel((b[i].pos.x - b[j].pos.x)/D, (b[i].pos.y - b[j].pos.y)/D);

          b[i].vel.x += avel.x;
          b[i].vel.y += avel.y;
        }
      }
    }
  }
  //ルール3（整列ルール）をここに書きましょう. 
  void applyRule3() {

    for (int i=0; i<pop; i++) {
      int count = 0;
      float sumx = 0;
      float sumy = 0;

      for (int j=0; j<pop; j++) {
        if (j !=i && b[i].isVisible(b[j])) {

          count++;
          sumx += b[j].vel.x;
          sumy += b[j].vel.y;
        }
      }

      if (count>0) {
        float ax = sumx/count;
        float ay = sumy/count;

        //Vel avel = new Vel(0.1*(ax - b[i].pos.x), 0.1*(ay - b[i].pos.y));
        b[i].vel.x = 0.05*ax+(1-0.05)*b[i].vel.x;
        b[i].vel.y = 0.05*ay+(1-0.05)*b[i].vel.y;
      }
    }
  }
  
   void applyRule4() {    
     
       for(int i=0; i<pop; i+=2){
          if(b[i].atract == false){ 
            b[i].a = (int)random(0, f_pop-1);
          
            while(f[b[i].a].exit==false || f[b[i].a].dead==true){
              b[i].a = (int)random(0, f_pop-1);
            }
          }
          
          float ax = f[b[i].a].x;
          float ay = f[b[i].a].y;
          
          float c = dist(b[i].pos.x, b[i].pos.y, ax, ay)*5;
          float d = dist(b[i+1].pos.x, b[i+1].pos.y, ax, ay)*5;
  
          Vel avel1 = new Vel((ax - b[i].pos.x)/c, (ay - b[i].pos.y)/c);
          b[i].vel.x += avel1.x;
          b[i].vel.y += avel1.y;
          
          Vel avel2 = new Vel((ax - b[i+1].pos.x)/d, (ay - b[i+1].pos.y)/d);
          b[i+1].vel.x += avel2.x;
          b[i+1].vel.y += avel2.y;
          
          b[i].atract = true;
          
          if(b[i].VisibleFlower(f[b[i].a])){
            f[b[i].a].Color_Dead();
            
            if(f[b[i].a].f_color==color(255)){
              if(b[i].juhun==true){
                f[num].born(f[b[i].a]);
                num++;
                
                f[num].born(f[b[i].a]);
                num++;
                
                f[num].born(f[b[i].a]);
                num++;
                
                print(num);
                b[i].juhun = false;
              }  
            else{
              b[i].juhun = true;
            }
           }
          }
          
         if(f[b[i].a].f_color==color(255)){
           b[i].atract = false;
         }
       }
   }
    
    void applyRule5() {  
    
      int a = 1;

      for(int i=0; i<pop; i++){
        
        float ax = b[i+a].pos.x;
        float ay = b[i+a].pos.y;
        
        float c = dist(b[i].pos.x, b[i].pos.y, ax, ay)*1.5;

        Vel avel = new Vel((ax - b[i].pos.x)/c, (ay - b[i].pos.y)/c);
        b[i].vel.x += avel.x;
        b[i].vel.y += avel.y;
        
        a *= -1;
      }
  }  

  //マウスで押した点へと引き込まれるルールを書いてください. 
  void ruleAttractor() {

    float c = 0.1;

    for (int i=0; i<pop; i++) {
      //i番目のボイドの位置座標・速度
      Pos ipos = b[i].pos; 
      //Vel ivel = b[i].vel;

      Pos apos = new Pos(mouseX, mouseY);

      //ここから適切な処理を追加してください. 
      Vel avel = new Vel(c*(apos.x - ipos.x), c*(apos.y - ipos.y));

      b[i].vel.x += avel.x;
      b[i].vel.y += avel.y;
    }
  }

  //マウスで押した点から斥力が発生するようなルールを書いてください
  //ただし, 距離が100ピクセル未満となったときのみ斥力が発生するものとします. 
  void ruleSeparator() {
    for (int i=0; i<pop; i++) {
      //i番目のボイドの位置座標・速度
      Pos ipos = b[i].pos;	
      Vel ivel = b[i].vel;
      //i番目のボイドとクリックした位置の距離（ピクセル）
      float dis = dist(ipos.x, ipos.y, mouseX, mouseY);

      //ここから適切な処理を追加してください.
    }
  }
}
