//
//  RCTBaiduMapViewManager.m
//  RCTBaiduMap
//
//  Created by lovebing on Aug 6, 2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBaiduMapViewManager.h"
#import "FFLoactionAnotation.h"
#import "FFCustomAnnotationView.h"
#import "FFMyLocationView.h"

@interface RCTBaiduMapViewManager ()<customAnnotationViewDelegate>
@property (nonatomic, strong) NSMutableArray *annotions;
@property (nonatomic,strong) RCTBaiduMapView *mapView;
@end
@implementation RCTBaiduMapViewManager;

RCT_EXPORT_MODULE(RCTBaiduMapView)

RCT_EXPORT_VIEW_PROPERTY(mapType, int)
RCT_EXPORT_VIEW_PROPERTY(zoom, float)
RCT_EXPORT_VIEW_PROPERTY(trafficEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(baiduHeatMapEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(marker, NSDictionary*)
RCT_EXPORT_VIEW_PROPERTY(markers, NSArray*)

RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(center, CLLocationCoordinate2D, RCTBaiduMapView) {
    [view setCenterCoordinate:json ? [RCTConvert CLLocationCoordinate2D:json] : defaultView.centerCoordinate];
}

-(NSMutableArray *)annotions{
    if (!_annotions) {
        _annotions = [NSMutableArray new];
    }
    return _annotions;
}
+(void)initSDK:(NSString*)key {
    
    BMKMapManager* _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:key  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

- (UIView *)view {
    if (_mapView) {
        return nil;
    }
    RCTBaiduMapView* mapView = [[RCTBaiduMapView alloc] init];
    mapView.delegate = self;
    _mapView = mapView;
//    FFLoactionAnotation *firstTation = [[FFLoactionAnotation alloc] initWithtitle:@"hanzhifeng" latitude:@"39.91553168" longtitude:@"116.43575629"];
//    FFLoactionAnotation *secondTation = [[FFLoactionAnotation alloc] initWithtitle:@"hanzhifengwnwnw" latitude:@"39.91553168" longtitude:@"106.43575629"];
//    [self.annotions addObject:firstTation];
//    [self.annotions addObject:secondTation];
//    [_mapView addAnnotations:[self.annotions copy]];
    return mapView;
}

-(void)mapview:(BMKMapView *)mapView
 onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onDoubleClick");
    NSDictionary* event = @{
                            @"type": @"onMapDoubleClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapView:(BMKMapView *)mapView
onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onClickedMapBlank");
    NSDictionary* event = @{
                            @"type": @"onMapClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    NSDictionary* event = @{
                            @"type": @"onMapLoaded",
                            @"params": @{}
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapView:(BMKMapView *)mapView
didSelectAnnotationView:(BMKAnnotationView *)view {
    
    if ([view isKindOfClass:[FFCustomAnnotationView class]]) {
        FFCustomAnnotationView *fView = (FFCustomAnnotationView *)view;
        [fView upDateWithSelectState:YES];
        
        FFLoactionAnotation *ann = (FFLoactionAnotation *)fView.annotation;
        NSDictionary* event = @{
                                @"type": @"onMarkerClick",
                                @"params": @{
                                        @"title": [[view annotation] title],
                                        @"companyId":ann.companyId,
                                        @"address":ann.address,
                                        @"position": @{
                                                @"latitude": @([[view annotation] coordinate].latitude),
                                                @"longitude": @([[view annotation] coordinate].longitude)
                                                }
                                        }
                                };
        
        [self sendEvent:mapView params:event];
    }
    
}

- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view{
    if ([view isKindOfClass:[FFCustomAnnotationView class]]) {
        FFCustomAnnotationView *fView = (FFCustomAnnotationView *)view;
        [fView upDateWithSelectState:NO];
    }
}

- (void) mapView:(BMKMapView *)mapView
 onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSLog(@"onClickedMapPoi");
    NSDictionary* event = @{
                            @"type": @"onMapPoiClick",
                            @"params": @{
                                    @"name": mapPoi.text,
                                    @"uid": mapPoi.uid,
                                    @"latitude": @(mapPoi.pt.latitude),
                                    @"longitude": @(mapPoi.pt.longitude),
//                                    @""
                                    }
                            };
    [self sendEvent:mapView params:event];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
//    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
//        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
//        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
//        newAnnotationView.animatesDrop = YES;
//        return newAnnotationView;
//    }
//    return nil;
    if ([annotation isKindOfClass:[FFLoactionAnotation class]])
    {
        FFLoactionAnotation *locationAnotaion = (FFLoactionAnotation *)annotation;
        
        if ([locationAnotaion.title isEqualToString:@"my_location"]) {
            static NSString *reuseIndetifier = @"mylocation";
            FFMyLocationView *myLoc = [[FFMyLocationView alloc] initWithAnnotation:locationAnotaion reuseIdentifier:reuseIndetifier];
            
            myLoc.canShowCallout = 0;
            return myLoc;
        }
        
        static NSString *reuseIndetifier = @"annotation";
        FFCustomAnnotationView *annotationView = [[FFCustomAnnotationView alloc] initWithAnnotation:locationAnotaion reuseIdentifier:reuseIndetifier];
        annotationView.paopaoView = nil;
        annotationView.canShowCallout = 0;
        annotationView.delegate = self;
        [annotationView updateCustomAnnotationView:locationAnotaion];
        return annotationView;
    }
    return nil;
}

#pragma mark -FFCustomAnnotationView Delegate
- (void)customViewDidSelected:(id<BMKAnnotation>)anntation annotationView:(FFCustomAnnotationView *)annotationView{
    if ([anntation isKindOfClass:[FFLoactionAnotation class]]) {
        FFLoactionAnotation *locationAnotion = (FFLoactionAnotation *)anntation;
        NSMutableArray *newArray = [NSMutableArray new];
        for (FFLoactionAnotation *oldAnotation in self.annotions) {
            BOOL ifEqual = [oldAnotation.title isEqualToString:locationAnotion.title];
            oldAnotation.selected = ifEqual ? YES : NO;
            [newArray addObject:oldAnotation];
        }
        [_mapView removeAnnotations:self.annotions];
        [self.annotions removeAllObjects];
        self.annotions = newArray;
        [_mapView addAnnotations:self.annotions];
    }
}
-(void)mapStatusDidChanged: (BMKMapView *)mapView	 {
    NSLog(@"mapStatusDidChanged");
    CLLocationCoordinate2D targetGeoPt = [mapView getMapStatus].targetGeoPt;
    NSDictionary* event = @{
                            @"type": @"onMapStatusChange",
                            @"params": @{
                                    @"target": @{
                                            @"latitude": @(targetGeoPt.latitude),
                                            @"longitude": @(targetGeoPt.longitude)
                                            },
                                    @"zoom": @"",
                                    @"overlook": @""
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)sendEvent:(RCTBaiduMapView *) mapView params:(NSDictionary *) params {
    if (!mapView.onChange) {
        return;
    }
    mapView.onChange(params);
}

@end
