package org.lovebing.reactnative.baidumap;

import android.content.Context;
import android.graphics.Point;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.InfoWindow;
import com.baidu.mapapi.map.MapPoi;
import com.baidu.mapapi.map.MapStatus;
import com.baidu.mapapi.map.MapStatusUpdate;
import com.baidu.mapapi.map.MapStatusUpdateFactory;
import com.baidu.mapapi.map.TextureMapView;
import com.baidu.mapapi.SDKInitializer;
import com.baidu.mapapi.map.MapViewLayoutParams;
import com.baidu.mapapi.map.Marker;
import com.baidu.mapapi.map.TextureMapView;
import com.baidu.mapapi.model.LatLng;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by lovebing on 12/20/2015.
 */
public class BaiduMapViewManager extends ViewGroupManager<TextureMapView> {

    private static final String REACT_CLASS = "RCTBaiduMapView";

    public static ThemedReactContext mReactContext;

    private ReadableArray childrenPoints;
    private HashMap<String, Marker> mMarkerMap = new HashMap<>();
    private HashMap<String, List<Marker>> mMarkersMap = new HashMap<>();
    private TextView mMarkerText;

    public String getName() {
        return REACT_CLASS;
    }


    public void initSDK(Context context) {
        SDKInitializer.initialize(context);
    }

    public TextureMapView createViewInstance(ThemedReactContext context) {
        mReactContext = context;
        TextureMapView TextureMapView = new TextureMapView(context);
//        TextureMapView.clearAnimation();
        setListeners(TextureMapView);
//        mapListener.onInstance(TextureMapView);
        return TextureMapView;
    }

    @Override
    public void addView(TextureMapView parent, View child, int index) {
        if (childrenPoints != null) {
            Point point = new Point();
            ReadableArray item = childrenPoints.getArray(index);
            if (item != null) {
                point.set(item.getInt(0), item.getInt(1));
                MapViewLayoutParams mapViewLayoutParams = new MapViewLayoutParams
                        .Builder()
                        .layoutMode(MapViewLayoutParams.ELayoutMode.absoluteMode)
                        .point(point)
                        .build();
                parent.addView(child, mapViewLayoutParams);
            }
        }
        

    }

    @ReactProp(name = "zoomControlsVisible")
    public void setZoomControlsVisible(TextureMapView TextureMapView, String  zoomControlsVisible) {
//        TextureMapView.showZoomControls(zoomControlsVisible);
        if (!TextUtils.isEmpty(zoomControlsVisible)){
            if ("onPause".equals(zoomControlsVisible)){
                onPause(TextureMapView,true);
            }else if ("onResume".equals(zoomControlsVisible)){
                onResume(TextureMapView,true);
            }
        }


    }

    @ReactProp(name = "trafficEnabled")
    public void setTrafficEnabled(TextureMapView TextureMapView, boolean trafficEnabled) {
        TextureMapView.getMap().setTrafficEnabled(trafficEnabled);
    }

    @ReactProp(name = "baiduHeatMapEnabled")
    public void setBaiduHeatMapEnabled(TextureMapView TextureMapView, boolean baiduHeatMapEnabled) {
        TextureMapView.getMap().setBaiduHeatMapEnabled(baiduHeatMapEnabled);
    }

    @ReactProp(name = "mapType")
    public void setMapType(TextureMapView TextureMapView, int mapType) {
        TextureMapView.getMap().setMapType(mapType);
    }

    @ReactProp(name = "zoom")
    public void setZoom(TextureMapView TextureMapView, float zoom) {
        MapStatus mapStatus = new MapStatus.Builder().zoom(zoom).build();
        MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newMapStatus(mapStatus);
        TextureMapView.getMap().setMapStatus(mapStatusUpdate);
    }

    @ReactProp(name = "center")
    public void setCenter(TextureMapView TextureMapView, ReadableMap position) {
        if (position != null) {
            double latitude = position.getDouble("latitude");
            double longitude = position.getDouble("longitude");
            LatLng point = new LatLng(latitude, longitude);
            MapStatus mapStatus = new MapStatus.Builder()
                    .target(point)
                    .build();
            MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newMapStatus(mapStatus);
            TextureMapView.getMap().setMapStatus(mapStatusUpdate);
        }
    }

    @ReactProp(name = "marker")
    public void setMarker(TextureMapView TextureMapView, ReadableMap option) {
        if (option != null) {
            String key = "marker_" + TextureMapView.getId();
            Marker marker = mMarkerMap.get(key);
            BitmapDescriptor bitmap;
            if (!TextUtils.isEmpty(option.getString(Constant.MAIN_MARKER)) && option.getString(Constant.MAIN_MARKER).equals(Constant.MAIN_MARKER)) {
                LinearLayout mMainMarker = (LinearLayout) LayoutInflater.from(mReactContext).inflate(R.layout.item_location_main, null);
                TextView tv_content = (TextView) mMainMarker.findViewById(R.id.tv_content);
                tv_content.setText(option.getString("title"));
                bitmap = BitmapDescriptorFactory.fromView(mMainMarker);
            } else {
                if (!TextUtils.isEmpty(option.getString("title")) && option.getString("title").equals("my_location")) {
                    bitmap = BitmapDescriptorFactory.fromResource(R.mipmap.my_location);
                } else {
                    TextView mview = (TextView) LayoutInflater.from(mReactContext).inflate(R.layout.item_marker, null);
                    mview.setText(marker.getTitle());
                    bitmap = BitmapDescriptorFactory.fromView(mview);
                }
            }
            marker.setIcon(bitmap);

            if (marker != null) {
                MarkerUtil.updateMaker(marker, option,mReactContext);
            } else {
                marker = MarkerUtil.addMarker(TextureMapView, option, mReactContext);
                mMarkerMap.put(key, marker);
            }
        }
    }

    private List<Marker> markers;

    @ReactProp(name = "markers")
    public void setMarkers(TextureMapView TextureMapView, ReadableArray options) {
        String key = "markers_" + TextureMapView.getId();
        markers = mMarkersMap.get(key);
        if (markers == null) {
            markers = new ArrayList<>();
        }
        for (int i = 0; i < options.size(); i++) {
            ReadableMap option = options.getMap(i);
            if (markers.size() > i + 1 && markers.get(i) != null) {
                MarkerUtil.updateMaker(markers.get(i), option,mReactContext);
            } else {
                markers.add(i, MarkerUtil.addMarker(TextureMapView, option, mReactContext));
            }
        }
        if (options.size() < markers.size()) {
            int start = markers.size() - 1;
            int end = options.size();
            for (int i = start; i >= end; i--) {
                markers.get(i).remove();
                markers.remove(i);
            }
        }
        mMarkersMap.put(key, markers);
    }

    @ReactProp(name = "childrenPoints")
    public void setChildrenPoints(TextureMapView TextureMapView, ReadableArray childrenPoints) {
        this.childrenPoints = childrenPoints;
    }

    /**
     * @param TextureMapView
     */
    private void setListeners(final TextureMapView TextureMapView) {
        BaiduMap map = TextureMapView.getMap();

        if (mMarkerText == null) {
            mMarkerText = new TextView(TextureMapView.getContext());
            mMarkerText.setBackgroundResource(R.drawable.popup);
            mMarkerText.setPadding(32, 32, 32, 32);
        }
        map.setOnMapStatusChangeListener(new BaiduMap.OnMapStatusChangeListener() {

            private WritableMap getEventParams(MapStatus mapStatus) {
                WritableMap writableMap = Arguments.createMap();
                WritableMap target = Arguments.createMap();
                target.putDouble("latitude", mapStatus.target.latitude);
                target.putDouble("longitude", mapStatus.target.longitude);
                writableMap.putMap("target", target);
                writableMap.putDouble("zoom", mapStatus.zoom);
                writableMap.putDouble("overlook", mapStatus.overlook);
                return writableMap;
            }

            @Override
            public void onMapStatusChangeStart(MapStatus mapStatus) {
                sendEvent(TextureMapView, "onMapStatusChangeStart", getEventParams(mapStatus));
            }

            @Override
            public void onMapStatusChangeStart(MapStatus mapStatus, int i) {
                sendEvent(TextureMapView, "onMapStatusChangeStart", getEventParams(mapStatus));
            }

            @Override
            public void onMapStatusChange(MapStatus mapStatus) {
                sendEvent(TextureMapView, "onMapStatusChange", getEventParams(mapStatus));
            }

            @Override
            public void onMapStatusChangeFinish(MapStatus mapStatus) {
                if (mMarkerText.getVisibility() != View.GONE) {
                    mMarkerText.setVisibility(View.GONE);
                }
                sendEvent(TextureMapView, "onMapStatusChangeFinish", getEventParams(mapStatus));
            }
        });

        map.setOnMapLoadedCallback(new BaiduMap.OnMapLoadedCallback() {
            @Override
            public void onMapLoaded() {
                sendEvent(TextureMapView, "onMapLoaded", null);
            }
        });

        map.setOnMapClickListener(new BaiduMap.OnMapClickListener() {
            @Override
            public void onMapClick(LatLng latLng) {
                TextureMapView.getMap().hideInfoWindow();
                WritableMap writableMap = Arguments.createMap();
                writableMap.putDouble("latitude", latLng.latitude);
                writableMap.putDouble("longitude", latLng.longitude);
                sendEvent(TextureMapView, "onMapClick", writableMap);
            }

            @Override
            public boolean onMapPoiClick(MapPoi mapPoi) {
                WritableMap writableMap = Arguments.createMap();
                writableMap.putString("name", mapPoi.getName());
                writableMap.putString("uid", mapPoi.getUid());
                writableMap.putDouble("latitude", mapPoi.getPosition().latitude);
                writableMap.putDouble("longitude", mapPoi.getPosition().longitude);
                sendEvent(TextureMapView, "onMapPoiClick", writableMap);
                return true;
            }
        });
        map.setOnMapDoubleClickListener(new BaiduMap.OnMapDoubleClickListener() {
            @Override
            public void onMapDoubleClick(LatLng latLng) {
                WritableMap writableMap = Arguments.createMap();
                writableMap.putDouble("latitude", latLng.latitude);
                writableMap.putDouble("longitude", latLng.longitude);
                sendEvent(TextureMapView, "onMapDoubleClick", writableMap);
            }
        });

        map.setOnMarkerClickListener(new BaiduMap.OnMarkerClickListener() {
            @Override
            public boolean onMarkerClick(Marker marker) {
                if (!TextUtils.isEmpty(marker.getTitle()) && marker.getTitle().equals("my_location")) {
                    return true;
                }
                if (marker.getExtraInfo() != null && Constant.MAIN_MARKER.equals(marker.getExtraInfo().getString(Constant.MAIN_MARKER))) {
//                    return false;
                } else {
                    if (marker.getTitle().length() > 0) {
                        mMarkerText.setText(marker.getTitle());
                        InfoWindow infoWindow = new InfoWindow(mMarkerText, marker.getPosition(), -80);
                        mMarkerText.setVisibility(View.GONE);
//                    TextureMapView.getMap().showInfoWindow(infoWindow);
                    } else {
//                    TextureMapView.getMap().hideInfoWindow();
                    }


//                for (String s : mMarkerMap.keySet()) {
//
//                    marker.setIcon(bitmap1);
//                    mMarkerMap.get(s).setIcon(bitmap1);
//                }
                    for (int i = 0; i < markers.size(); i++) {
                        Marker markerChild = markers.get(i);
                        if (!TextUtils.isEmpty(markerChild.getTitle()) && markerChild.getTitle().equals("my_location")) {
                            //定位地址
                            BitmapDescriptor bitmapLocation = BitmapDescriptorFactory.fromResource(R.mipmap.my_location);
                            markerChild.setIcon(bitmapLocation);
                        } else {
                            TextView mTextView = (TextView) LayoutInflater.from(mReactContext).inflate(R.layout.item_marker, null);
                            mTextView.setText(markerChild.getTitle());
                            BitmapDescriptor bitmap1 = BitmapDescriptorFactory.fromView(mTextView);
                            markerChild.setIcon(bitmap1);
                        }
                    }
                    TextView mTextView = (TextView) LayoutInflater.from(mReactContext).inflate(R.layout.item_marker, null);
                    mTextView.setText(marker.getTitle());
                    mTextView.setBackgroundResource(R.drawable.select);
                    marker.setIcon(BitmapDescriptorFactory.fromView(mTextView));
                }


//                BitmapDescriptor bitmap = BitmapDescriptorFactory.fromResource(R.drawable.popup);
//                marker.setIcon(bitmap);


                WritableMap writableMap = Arguments.createMap();
                WritableMap position = Arguments.createMap();
                position.putDouble("latitude", marker.getPosition().latitude);
                position.putDouble("longitude", marker.getPosition().longitude);
                writableMap.putMap("position", position);
                writableMap.putString("title", marker.getTitle());
                if (marker.getExtraInfo() != null) {
                    writableMap.putString(Constant.ADDRESS, (String) marker.getExtraInfo().get(Constant.ADDRESS));
                    writableMap.putString(Constant.COMPANY_ID, (String) marker.getExtraInfo().get(Constant.COMPANY_ID));
                }
                sendEvent(TextureMapView, "onMarkerClick", writableMap);
                return true;
            }
        });

    }

    /**
     * @param eventName
     * @param params
     */
    private void sendEvent(TextureMapView TextureMapView, String eventName, @Nullable WritableMap params) {
        WritableMap event = Arguments.createMap();
        event.putMap("params", params);
        event.putString("type", eventName);
        mReactContext
                .getJSModule(RCTEventEmitter.class)
                .receiveEvent(TextureMapView.getId(),
                        "topChange",
                        event);
    }

    public interface  BDMapListener{
        void onInstance(TextureMapView textureMapView);
    }
    private BDMapListener mapListener;
    public void BDMapListener(BDMapListener listener){
        this.mapListener=listener;
    }
//    @ReactProp(name = "onPause")
    public void onPause(TextureMapView TextureMapView, boolean result){
        if (result&&TextureMapView!=null){
            TextureMapView.onPause();
        }

    }
//    @ReactProp(name = "onResume")
    public void onResume(TextureMapView TextureMapView, boolean result){
        if (result&&TextureMapView!=null){
            TextureMapView.onResume();
        }
    }

}
