//
//  MapViewController.h
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/04.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TileOverlay.h"
#import "TileOverlayView.h"
#import "MKMapView+ZoomLevel.h"
#import "CustomAnnotation.h"
#import "UIViewController+ECSlidingViewController.h"
#import "ZoomLevelView.h"
#import "ProgressView.h"

@interface MapViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate,NSURLSessionDownloadDelegate>
{
    CLLocationManager* locationManager;
    TileOverlayView *tileOverlay;
    BOOL manualRecoding;
    UIAlertView* manualAlert;
    BOOL firstFlg;
    NSMutableArray* ano100MeizanMin;
    NSMutableArray* ano200MeizanMin;
    NSMutableArray* ano300MeizanMin;
    BOOL minFlg;
    NSArray* downloadUrls;
    NSInteger downloadCount;
    NSURLSession* sessionConfig;
    ZoomLevelView *autoDownloadAlert;
    ProgressView* progressAlert;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *btnLocationImg;
- (IBAction)btnLocation:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnManualDownload;
@property (weak, nonatomic) IBOutlet UIImageView *btnManualDownloadImg;
- (IBAction)manualDownload:(id)sender;
- (IBAction)btnMapRouteList:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lbZoomLevel;
-(void)visibled100meizan:(BOOL)visibled;
-(void)visibled200meizan:(BOOL)visibled;
-(void)visibled300meizan:(BOOL)visibled;
- (void)startAutoDownloadMap;
@end
