//
//  RCTBaiduMap.m
//  RCTBaiduMap
//
//  Created by lovebing on 4/17/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBaiduMapView.h"
#import "FFLoactionAnotation.h"
#import "ZKLoactionAnotation.h"
#import "JZLocationConverter.h"


@implementation RCTBaiduMapView {
    BMKMapView* _mapView;
    BMKPointAnnotation* _annotation;
    NSMutableArray* _annotations;
}

-(void)setZoom:(float)zoom {
    self.zoomLevel = zoom;
}

-(void)setCenterLatLng:(NSDictionary *)LatLngObj {
    double lat = [RCTConvert double:LatLngObj[@"lat"]];
    double lng = [RCTConvert double:LatLngObj[@"lng"]];
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake(lat, lng);
    self.centerCoordinate = point;
}
/*
-(void)setMarker:(NSDictionary *)option {
    NSLog(@"setMarker");
    if(option != nil) {
        if(_annotation == nil) {
            _annotation = [[BMKPointAnnotation alloc]init];
            [self addMarker:_annotation option:option];
        }
        else {
            [self updateMarker:_annotation option:option];
        }
    }
}
 */

-(void)setMarkers:(NSArray *)markers {
    
    if (_annotations == nil) {
        _annotations = [NSMutableArray array];
    }
    
    if (_annotations.count) {
        [self removeAnnotations:_annotations];
        [_annotations removeAllObjects];
    }
    
    for (int i = 0; i < markers.count; i++)  {
        NSDictionary *option = [markers objectAtIndex:i];
        
        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
        [self addMarker:annotation option:option];
    }
    
    /*
    int markersCount = [markers count];
    if(_annotations == nil) {
        _annotations = [[NSMutableArray alloc] init];
    }
    if(markers != nil) {
        for (int i = 0; i < markersCount; i++)  {
            NSDictionary *option = [markers objectAtIndex:i];
            
            BMKPointAnnotation *annotation = nil;
            if(i < [_annotations count]) {
                annotation = [_annotations objectAtIndex:i];
            }
            if(annotation == nil) {
                annotation = [[BMKPointAnnotation alloc]init];
                [self addMarker:annotation option:option];
                [_annotations addObject:annotation];
            }
            else {
                [self updateMarker:annotation option:option];
            }
        }
        
        int _annotationsCount = [_annotations count];
        
        NSString *smarkersCount = [NSString stringWithFormat:@"%d", markersCount];
        NSString *sannotationsCount = [NSString stringWithFormat:@"%d", _annotationsCount];
        NSLog(smarkersCount);
        NSLog(sannotationsCount);
        
        if(markersCount < _annotationsCount) {
            int start = _annotationsCount - 1;
            for(int i = start; i >= markersCount; i--) {
                BMKPointAnnotation *annotation = [_annotations objectAtIndex:i];
                [self removeAnnotation:annotation];
                [_annotations removeObject:annotation];
            }
        }
    }
    */
}


-(CLLocationCoordinate2D)getCoorFromMarkerOption:(NSDictionary *)option {
    double lat = [RCTConvert double:option[@"latitude"]];
    double lng = [RCTConvert double:option[@"longitude"]];
    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lng;
    
    return [JZLocationConverter gcj02ToBd09:coor];
}

-(void)addMarker:(BMKPointAnnotation *)annotation option:(NSDictionary *)option {
//    [self updateMarker:annotation option:option];
    
    if (_annotations == nil) {
        _annotations = [NSMutableArray array];
    }
    
    if (option[@"main_marker"] != nil && ![option[@"main_marker"] isEqualToString:@""]) {
        //从某一个职位进入地图添加标签
        CLLocationCoordinate2D coor = [self getCoorFromMarkerOption:option];
        NSString *title = [RCTConvert NSString:option[@"title"]];
        if(title.length == 0) {
            title = nil;
        }
        ZKLoactionAnotation *ann = [[ZKLoactionAnotation alloc] init];
        ann.coordinate = coor;
        ann.title = title;
        
        [_annotations addObject:ann];
        
        [self addAnnotation:ann];
    }else{
        //从地图模式加载标签
        CLLocationCoordinate2D coor = [self getCoorFromMarkerOption:option];
        NSString *title = [RCTConvert NSString:option[@"title"]];
        if(title.length == 0) {
            title = nil;
        }
        FFLoactionAnotation *ann = [[FFLoactionAnotation alloc] init];
        ann.coordinate = coor;
        ann.title = title;
        
        ann.companyId = option[@"companyId"];
        ann.address = option[@"address"];
        
        [_annotations addObject:ann];
        
        [self addAnnotation:ann];
    }
}

-(void)updateMarker:(BMKPointAnnotation *)annotation option:(NSDictionary *)option {
    CLLocationCoordinate2D coor = [self getCoorFromMarkerOption:option];
    NSString *title = [RCTConvert NSString:option[@"title"]];
    if(title.length == 0) {
        title = nil;
    }
    annotation.coordinate = coor;
    annotation.title = title;
}

- (void)dealloc{
    NSLog(@"aaa");
}

@end
