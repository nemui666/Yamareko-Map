//
//  FileDetailViewController.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/19.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TileOverlay.h"
#import "TileOverlayView.h"
#import "CustomAnnotation.h"
#import "GradientPolylineRenderer.h"
#import "GradientPolylineOverlay.h"
//#import "SlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "GPXFile.h"
#import "MKMapView+ZoomLevel.h"
#import "ZoomLevelView.h"
#import "ProgressView.h"

@interface FileDetailViewController : UIViewController<NSXMLParserDelegate,CLLocationManagerDelegate,MKMapViewDelegate,NSURLSessionDownloadDelegate>
{
    NSXMLParser* parser;
    NSMutableArray *coordList;
    MKCoordinateRegion firstRegion;
    BOOL isTime;
    BOOL isTrkpt;
    BOOL isEle;
    BOOL manualRecoding;
    //NSMutableArray* tasksArray;
    NSArray* downloadUrls;
    NSInteger downloadCount;
    NSURLSession* sessionConfig;
    ZoomLevelView *autoDownloadAlert;
    //UISlider *zoomLevelSlider;
    UIAlertView * manualAlert;
    ProgressView* progressAlert;
    //UIProgressView* progressView;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *btnLocation;
@property (nonatomic, strong)NSMutableArray* hourAnnotations;
@property (nonatomic, strong)NSMutableArray* disAnnotations;
@property (nonatomic, strong)NSMutableArray* stEdAnnotations;
@property (nonatomic, strong)NSMutableArray* minMaxAnnotations;
@property (weak, nonatomic) IBOutlet UILabel *lbDistance;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbAscAlt;
@property (weak, nonatomic) IBOutlet UILabel *lbDscAlt;
@property (nonatomic, strong)GPXFile* gpxFile;
@property (weak, nonatomic) IBOutlet UIView *mapInfoView;
@property (nonatomic, assign)CLLocationCoordinate2D startCoodinate;
@property (weak, nonatomic) IBOutlet UIImageView *btnManualStopImg;
@property (weak, nonatomic) IBOutlet UIButton *btnManualStop;
//@property (assign, nonatomic)BOOL manualDownload;
@property (strong,nonatomic)CLLocationManager* locationManager;
@property (strong,nonatomic)TileOverlayView *tileOverlay;
@property (strong,nonatomic)GradientPolylineOverlay* polyline;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIImageView *btnMenuImg;
@property (weak, nonatomic) IBOutlet UILabel *lbTosaym;
@property (weak, nonatomic) IBOutlet UILabel *lbZoomLevel;


- (BOOL)visbibleHour:(BOOL)visbibled;
- (BOOL)visbibleDistance:(BOOL)visbibled;
- (BOOL)visbibleMaxMin:(BOOL)visbibled;
- (BOOL)visbibleStartEnd:(BOOL)visbibled;

- (IBAction)userTrackingModeBtnTapped:(id)sender;
- (IBAction)btnHome:(id)sender;
- (IBAction)menuButtonTapped:(id)sender;
- (IBAction)btnMapRouteList:(id)sender;
- (IBAction)btnBack:(id)sender;
- (IBAction)btnManualStop:(id)sender;

//-(void)initMapLine:(NSString*)fileName; // ファイル名からマップデータを読み込む
- (void)startManualDownloadMap;
- (void)startAutoDownloadMap;
@end
