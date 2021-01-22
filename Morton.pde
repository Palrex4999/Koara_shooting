//////////////////////////////////////////
//2021須賀作成：
//当たり判定高速化のための4分木空間分割・モートン番号算出
class Morton{
    //座標pのモートン番号算出
    public int getMortonNum(PVector p){
        int xud=int(p.x)/(width>>3),yud=int(p.y)/(height>>3);
        return ((xud|(xud<<2))&0x33)|((yud|(yud<<2))&0x33<<1);
    }

    //オブジェクトのモートン番号算出のためのシフト数算出
    public int getShiftNum(PVector p,int size){
        //オブジェクトの始点(左上)st,終点(右下)edのモートン番号のxorをとってシフト数を求める
        PVector st=new PVector(p.x-size,p.y-size);
        PVector ed=new PVector(p.x+size,p.y+size);
        int stedxor=getMortonNum(st)^getMortonNum(ed);
        if(stedxor>>4!=0)return 6;
        if(stedxor>>2!=0)return 4;
        return 2;
    }
}