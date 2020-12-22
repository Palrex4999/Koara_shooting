//////////////////////////////////////////
//2021須賀作成：
//当たり判定高速化のための4分木空間分割・モートン番号算出
class Morton{
    //座標pのモートン番号算出
    public int getMortonNum(PVector p){
        int xud=int(p.x)/(width>>3),yud=int(p.y)/(height>>3);
        return ((xud|(xud<<2))&0x33)|((yud|(yud<<2))&0x33<<1);
    }
}