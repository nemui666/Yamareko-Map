//
//  MKMapView+ZoomLevel.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/11/09.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import "MKMapView+ZoomLevel.h"
#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395
@implementation MKMapView (ZoomLevel)
#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}

- (NSUInteger)getCurrentZoomLevel {
    // get longitude of right edge and left edge;
    CLLocationDegrees longitudeMax = self.region.center.longitude + self.region.span.longitudeDelta /2.0;
    CLLocationDegrees longitudeMin = self.region.center.longitude - self.region.span.longitudeDelta /2.0;
    
    // calc get longitude delta in pixel
    double longitudeMaxInPixel = [self longitudeToPixelSpaceX:longitudeMax];
    double longitudeMinInPixel = [self longitudeToPixelSpaceX:longitudeMin];
    double scaledMapWidth = longitudeMaxInPixel - longitudeMinInPixel;
    
    // calc zoom scale
    double mapSizeInPixels = self.bounds.size.width;
    double zoomScale = scaledMapWidth / mapSizeInPixels;
    NSUInteger zoomLevel = 20 - log2(zoomScale);
   
    return (zoomLevel > 0)? zoomLevel+2 : 0;
}

-(NSArray*)getMapTileUrl:(long)minLevel maxLevel:(long) maxLevel {
    
    NSMutableArray* downloadUrls = [NSMutableArray array];
    
    // 現在の座標位置取得
    MKMapRect visibleRect = self.visibleMapRect;
    
    // 右下の座標位置
    CGPoint maxPoint = CGPointMake(
                                   visibleRect.origin.x + visibleRect.size.width,
                                   visibleRect.origin.y + visibleRect.size.height);
    
    for (long zoomLevel = minLevel;zoomLevel <= maxLevel;zoomLevel++){
    //NSLog(@"Min [x=%f][y=%f]",visibleRect.origin.x,visibleRect.origin.y);
    //NSLog(@"Max [x=%f][y=%f]",maxPoint.x,maxPoint.y);
    
    NSInteger wkZoom = 20 - zoomLevel;
    double result = pow(2, wkZoom);
    //NSLog(@"Zoom [%lu]",(unsigned long)zoomLevel);
    //NSLog(@"wkZoom [%f]",result);
    
    // 座標値とズームレベルからタイル番号を計算
    CGPoint MinTilePoint = CGPointMake(
                                       (visibleRect.origin.x/256)/result,
                                       (visibleRect.origin.y/256)/result);
    CGPoint MaxTilePoint = CGPointMake(
                                       (maxPoint.x/256)/result,
                                       (maxPoint.y/256)/result);
    //NSLog(@"MinTile [x=%f][y=%f]",MinTilePoint.x,MinTilePoint.y);
    //NSLog(@"MaxTile [x=%f][y=%f]",MaxTilePoint.x,MaxTilePoint.y);
    
    NSInteger minX = MinTilePoint.x;
    NSInteger maxX = MaxTilePoint.x;
    NSInteger minY = MinTilePoint.y;
    NSInteger maxY = MaxTilePoint.y;
    
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            if (downloadUrls.count >= 3000) {
                return downloadUrls;
            }
            // ダウンロードURLの作成
            NSString *strUrl = [[NSString alloc] initWithFormat:@"http://cyberjapandata.gsi.go.jp/xyz/std/%ld/%ld/%ld.png", (long)zoomLevel, (long)x, (long)y];
            NSURL* url = [NSURL URLWithString:strUrl];
            [downloadUrls addObject:url];
            //NSLog(@"%@",strUrl);
            //[self downloadFile:url];
        }
    }
    }
    return downloadUrls;
}

@end
