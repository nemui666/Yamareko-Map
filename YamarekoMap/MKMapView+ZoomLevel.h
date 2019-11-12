//
//  MKMapView+ZoomLevel.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/11/09.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
- (NSUInteger)getCurrentZoomLevel;
-(NSArray*)getMapTileUrl:(long)minLevel maxLevel:(long) maxLevel;
@end
