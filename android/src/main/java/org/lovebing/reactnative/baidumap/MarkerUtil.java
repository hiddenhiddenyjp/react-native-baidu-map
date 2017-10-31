package org.lovebing.reactnative.baidumap;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.InfoWindow;
import com.baidu.mapapi.map.MapView;
import com.baidu.mapapi.map.Marker;
import com.baidu.mapapi.map.MarkerOptions;
import com.baidu.mapapi.map.OverlayOptions;
import com.baidu.mapapi.map.TextureMapView;
import com.baidu.mapapi.model.LatLng;
import com.facebook.react.bridge.NoSuchKeyException;
import com.facebook.react.bridge.ReadableMap;

/**
 * Created by lovebing on Sept 28, 2016.
 */
public class MarkerUtil {

    public static void updateMaker(Marker maker, ReadableMap option,Context mReactContext) {
        LatLng position = getLatLngFromOption(option);
        maker.setPosition(position);
        maker.setTitle(option.getString("title"));
        Bundle mBundle = new Bundle();
//        DataBean dataBean=new DataBean();
        try {
            mBundle.putString(Constant.MAIN_MARKER, option.getString(Constant.MAIN_MARKER));
            mBundle.putString(Constant.ADDRESS, option.getString(Constant.ADDRESS));
            mBundle.putString(Constant.COMPANY_ID, option.getString(Constant.COMPANY_ID));
        } catch (NoSuchKeyException e) {
            e.printStackTrace();
        }

        maker.setExtraInfo(mBundle);

        if (!TextUtils.isEmpty(maker.getTitle()) && maker.getTitle().equals("my_location")) {
            //定位地址
            BitmapDescriptor bitmapLocation = BitmapDescriptorFactory.fromResource(R.mipmap.my_location);
            maker.setIcon(bitmapLocation);
        } else {
            TextView mTextView = (TextView) LayoutInflater.from(mReactContext).inflate(R.layout.item_marker, null);
            mTextView.setText(maker.getTitle());
            BitmapDescriptor bitmap1 = BitmapDescriptorFactory.fromView(mTextView);
            maker.setIcon(bitmap1);
        }
    }

    public static Marker addMarker(TextureMapView mapView, ReadableMap option, final  Context mContext) {
        BitmapDescriptor bitmap;

        if (!TextUtils.isEmpty(option.getString(Constant.MAIN_MARKER)) && option.getString(Constant.MAIN_MARKER).equals(Constant.MAIN_MARKER)) {
            LinearLayout mMainMarker = (LinearLayout) LayoutInflater.from(mContext).inflate(R.layout.item_location_main, null);
            TextView tv_content = (TextView) mMainMarker.findViewById(R.id.tv_content);
            tv_content.setText(option.getString("title"));
            LinearLayout ll_go_to= (LinearLayout) mMainMarker.findViewById(R.id.ll_go_to);
            ll_go_to.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Toast.makeText(mContext, "shijian dianji ", Toast.LENGTH_SHORT).show();
                }
            });
            bitmap = BitmapDescriptorFactory.fromView(mMainMarker);
        } else {
            if (!TextUtils.isEmpty(option.getString("title")) && option.getString("title").equals("my_location")) {
                bitmap = BitmapDescriptorFactory.fromResource(R.mipmap.my_location);
            } else {
                TextView mTextView = (TextView) LayoutInflater.from(mContext).inflate(R.layout.item_marker, null);
                mTextView.setText(option.getString("title"));
                bitmap = BitmapDescriptorFactory.fromView(mTextView);
            }
        }
        LatLng position = getLatLngFromOption(option);
        Bundle mBundle = new Bundle();
//        DataBean dataBean=new DataBean();
        try {
            mBundle.putString(Constant.MAIN_MARKER, option.getString(Constant.MAIN_MARKER));
            mBundle.putString(Constant.ADDRESS, option.getString(Constant.ADDRESS));
            mBundle.putString(Constant.COMPANY_ID, option.getString(Constant.COMPANY_ID));
        } catch (NoSuchKeyException e) {
            e.printStackTrace();
        }

        OverlayOptions overlayOptions = new MarkerOptions()
                .icon(bitmap)
                .position(position)
                .title(option.getString("title")).extraInfo(mBundle);


        Marker marker = (Marker) mapView.getMap().addOverlay(overlayOptions);

        return marker;
    }


    private static LatLng getLatLngFromOption(ReadableMap option) {
        double latitude = option.getDouble("latitude");
        double longitude = option.getDouble("longitude");
        return new LatLng(latitude, longitude);

    }
}
