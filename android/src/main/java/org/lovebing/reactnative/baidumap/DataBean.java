package org.lovebing.reactnative.baidumap;

import java.io.Serializable;

/**
 * Created by yangjipeng on 2017/9/28.
 */

public class DataBean  implements Serializable{
    private String main_marker;
    public void setMain_marker(String main_marker ){
        this.main_marker=main_marker;
    }
    public String getMain_marker(){
        return  main_marker;
    }


}
