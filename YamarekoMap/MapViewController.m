//
//  MapViewController.m
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/04.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // mapViewの設定
    [self.mapView setDelegate:self];
    
    // 位置情報サービス作成
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //_locationManager = appDelegate.locationManager;
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 10.0;
        locationManager.delegate = self;
        
        [locationManager startUpdatingLocation];
    }
    if ([CLLocationManager headingAvailable] == YES) {
        //[locationManager startUpdatingHeading];
    }
    
    // OSM
    TileOverlay *overlay = [[TileOverlay alloc] initOverlay];
    [_mapView addOverlay:overlay level:MKOverlayLevelAboveRoads];
    MKMapRect visibleRect = [_mapView mapRectThatFits:overlay.boundingMapRect];
    visibleRect.size.width /= 2;
    visibleRect.size.height /= 2;
    visibleRect.origin.x += visibleRect.size.width / 2;
    visibleRect.origin.y += visibleRect.size.height / 2;
    _mapView.visibleMapRect = visibleRect;
    // END OSM
    
    // Remove Legal link
    for (UIView *v in [self.mapView subviews]) {
        //NSLog(@"%@", NSStringFromClass([v class]));
        if ([NSStringFromClass([v class]) isEqualToString:@"MKAttributionLabel"]) {
            v.hidden = YES;
        }
    }
    
    manualRecoding = NO;
    firstFlg = YES;
    
    // 百名山読み込み
    ano100MeizanMin = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"100meizan" ofType:@"csv"];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    // 1行ずつ文字列を列挙
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSArray *phrases = [line componentsSeparatedByString:@","];
        
        // 小さい倍率用
        CustomAnnotation* annotationMin = [[CustomAnnotation alloc] initWithLocationCoordinate:CLLocationCoordinate2DMake([phrases[2] doubleValue], [phrases[3] doubleValue]) title:phrases[1] subtitle:[NSString stringWithFormat:@"標高：%@m" ,phrases[5] ]];
        annotationMin.tag = 1;
        [ano100MeizanMin addObject:annotationMin];
    }];
    
    // 200名山
    ano200MeizanMin = [NSMutableArray array];
    path = [[NSBundle mainBundle] pathForResource:@"200meizan" ofType:@"csv"];
    str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    // 1行ずつ文字列を列挙
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSArray *phrases = [line componentsSeparatedByString:@","];
        
        // 小さい倍率用
        CustomAnnotation* annotationMin = [[CustomAnnotation alloc] initWithLocationCoordinate:CLLocationCoordinate2DMake([phrases[2] doubleValue], [phrases[3] doubleValue]) title:phrases[1] subtitle:[NSString stringWithFormat:@"標高：%@m" ,phrases[5] ]];
        annotationMin.tag = 2;
        [ano200MeizanMin addObject:annotationMin];
    }];
    
    // 300名山
    ano300MeizanMin = [NSMutableArray array];
    path = [[NSBundle mainBundle] pathForResource:@"300meizan" ofType:@"csv"];
    str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    // 1行ずつ文字列を列挙
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSArray *phrases = [line componentsSeparatedByString:@","];
        
        if([phrases[0] doubleValue]>0) {
            //NSLog(@"%@",phrases[1]);
        // 小さい倍率用
        CustomAnnotation* annotationMin = [[CustomAnnotation alloc] initWithLocationCoordinate:CLLocationCoordinate2DMake([phrases[2] doubleValue], [phrases[3] doubleValue]) title:phrases[1] subtitle:[NSString stringWithFormat:@"標高：%@m" ,phrases[5] ]];
        annotationMin.tag = 3;
        [ano300MeizanMin addObject:annotationMin];
        }
    }];
    
    [_mapView addAnnotations:ano100MeizanMin];
    [_mapView addAnnotations:ano200MeizanMin];
    [_mapView addAnnotations:ano300MeizanMin];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (firstFlg) {
    // mapViewの設定
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(37.68664111, 136.6948839);
        MKCoordinateSpan span = MKCoordinateSpanMake(25, 25);
        MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
        [self.mapView setDelegate:self];
        [self.mapView setShowsBuildings:YES];
        [self.mapView setShowsPointsOfInterest:YES];
        [self.mapView setShowsUserLocation:YES];
        [self.mapView setRegion:region];
        [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        [self updateUserTrackingModeBtn:self.mapView.userTrackingMode];
        firstFlg = NO;
    }
    
    [_mapView removeOverlay:tileOverlay.overlay];
    TileOverlay *overlay = [[TileOverlay alloc] initOverlay];
    [_mapView addOverlay:overlay level:MKOverlayLevelAboveRoads];
    
    // シャドウ
    self.view.layer.shadowOpacity = 0.5f;
    self.view.layer.shadowRadius = 5.0f;
    self.view.layer.shadowColor = [UIColor grayColor].CGColor;
    
    [self.slidingViewController setAnchorRightRevealAmount:250.0f];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark MKMapViewDelegate methods
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{

    tileOverlay = [[TileOverlayView alloc] initWithOverlay:overlay];
    tileOverlay.tileAlpha = 1.0; // e.g. 0.6 alpha for semi-transparent overlay
        
    // 表示されている
    if (manualRecoding) {
        tileOverlay.manualRecoding = YES;
    }
    return tileOverlay;
}
- ( void ) mapView: ( MKMapView * ) mapView
regionWillChangeAnimated: ( BOOL ) animated {
    [self updateUserTrackingModeBtn:self.mapView.userTrackingMode];
    int zoomlevel = (int)[mapView getCurrentZoomLevel];
    _lbZoomLevel.text = [NSString stringWithFormat:@"ズームレベル：%d",zoomlevel];
    
}
- (void)mapView:(MKMapView *)mapView
regionDidChangeAnimated:(BOOL)animated {
    [self updateUserTrackingModeBtn:self.mapView.userTrackingMode];
    int zoomlevel = (int)[mapView getCurrentZoomLevel];
    _lbZoomLevel.text = [NSString stringWithFormat:@"ズームレベル：%d",zoomlevel];
    
    if (zoomlevel >= 10) {
        if (!minFlg) {
            minFlg = YES;
            [self annotationChangeImage:minFlg];
        }
    } else {
        if (minFlg) {
            minFlg = NO;
            [self annotationChangeImage:minFlg];
        }
    }
    
}
-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // ①ユーザの現在地はデフォルトの青丸マークを使いたいのでreturn: nil
    if (annotation == mapView.userLocation) {
        return nil;
    } else {
        MKAnnotationView *annotationView;
        
        // ②再利用可能なannotationがあるかどうかを判断するための識別子を定義
        NSString* identifier = @"Pin";
        
        // ③dequeueReusableAnnotationViewWithIdentifierで"Pin"という識別子の使いまわせるannotationがあるかチェック
        annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        // ④使い回しができるannotationがない場合、annotationの初期化
        if(annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        int zoomlevel = (int)[mapView getCurrentZoomLevel];
        
        if (((CustomAnnotation*)annotation).tag == 1) {
            // 指定のレベルになったら画像を変える
            if (zoomlevel < 10) {
                annotationView.image = [UIImage imageNamed:@"map_100pin_min"];
                annotationView.centerOffset = CGPointMake(0, 0);
                annotationView.canShowCallout = YES;
            } else {
                // 好きな画像をannotationとして設定
                annotationView.image = [self getMeizanImage:1 text:[self getAnnotationTitle:annotation.title]];
                annotationView.centerOffset = [self getAnnotationLSizeOffsetValue:annotationView.image];
                annotationView.canShowCallout = YES;
            }
        } else if (((CustomAnnotation*)annotation).tag == 2) {
            // 指定のレベルになったら画像を変える
            if (zoomlevel < 10) {
                annotationView.image = [UIImage imageNamed:@"map_200pin_min"];
                annotationView.centerOffset = CGPointMake(0, 0);
                annotationView.canShowCallout = YES;
            } else {
                // 好きな画像をannotationとして設定
                annotationView.image = [self getMeizanImage:2 text:[self getAnnotationTitle:annotation.title]];
                annotationView.centerOffset = [self getAnnotationLSizeOffsetValue:annotationView.image];
                annotationView.canShowCallout = YES;
            }
        } else if (((CustomAnnotation*)annotation).tag == 3) {
            // 指定のレベルになったら画像を変える
            if (zoomlevel < 10) {
                annotationView.image = [UIImage imageNamed:@"map_300pin_min"];
                annotationView.centerOffset = CGPointMake(0, 0);
                annotationView.canShowCallout = YES;
            } else {
                // 好きな画像をannotationとして設定
                annotationView.image = [self getMeizanImage:3 text:[self getAnnotationTitle:annotation.title]];
                annotationView.centerOffset = [self getAnnotationLSizeOffsetValue:annotationView.image];
                annotationView.canShowCallout = YES;
            }
        } else if (((CustomAnnotation*)annotation).tag == 4) {
            // 指定のレベルになったら画像を変える
            if (zoomlevel < 10) {
                annotationView.image = [UIImage imageNamed:@"map_100pin_min"];
                annotationView.centerOffset = CGPointMake(0, 0);
                annotationView.canShowCallout = YES;
            } else {
                // 好きな画像をannotationとして設定
                annotationView.image = [self getMeizanImage:4 text:[self getAnnotationTitle:annotation.title]];
                annotationView.centerOffset = [self getAnnotationLSizeOffsetValue:annotationView.image];
                annotationView.canShowCallout = YES;
            }
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = btn;
        }
        annotationView.annotation = annotation;
        return annotationView;
    }
}
#pragma mark ViewController methods
- (void) execAutoDownload{
    NSString* identifier = @"BackgroundSessionConfiguration";
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    //tasksArray = [[NSMutableArray alloc] init];
    //config.HTTPMaximumConnectionsPerHost = 3;
    //config.timeoutIntervalForResource = 600;
    //config.timeoutIntervalForRequest = 600;
    sessionConfig = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(globalQueue, ^{
        downloadCount = 0;
        for (NSURL* url in downloadUrls){
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            NSURLSessionDownloadTask* task = [sessionConfig downloadTaskWithRequest:request];
            //[tasksArray addObject:task];
            //[task addObserver:self forKeyPath:@"countOfBytesReceived" options:NSKeyValueObservingOptionOld context:nil];
            [task resume];
            //NSLog(@"%@",url);
            [NSThread sleepForTimeInterval:0.3];
        }
        dispatch_async(main, ^{
            
        });
    });
}
-(void)annotationHidden:(NSInteger)kind hidden:(BOOL)hidden{
    /*
    for (CustomAnnotation* annotation in _mapView.annotations) {
        MKAnnotationView* av = [_mapView viewForAnnotation:annotation];
        if ([av class] == [MKAnnotationView class]) {
            if (annotation.tag == kind) {
                av.hidden = !av.hidden;
            }
        }
    }
     */
    if (kind == 1) {
        if (hidden) {
            [_mapView removeAnnotations:ano100MeizanMin];
        } else {
            [_mapView addAnnotations:ano100MeizanMin];
        }
    }
    if (kind == 2) {
        if (hidden) {
            [_mapView removeAnnotations:ano200MeizanMin];
        } else {
            [_mapView addAnnotations:ano200MeizanMin];
        }
    }
    if (kind == 3) {
        if (hidden) {
            [_mapView removeAnnotations:ano300MeizanMin];
        } else {
            [_mapView addAnnotations:ano300MeizanMin];
        }
    }
}
-(void)annotationChangeImage:(BOOL)kind{
    for (CustomAnnotation* annotation in _mapView.annotations) {
        MKAnnotationView* av = [_mapView viewForAnnotation:annotation];
        if ([av class] == [MKAnnotationView class]) {
            if (!kind) {
                if (annotation.tag == 1)
                    av.image = [UIImage imageNamed:@"map_100pin_min"];
                if (annotation.tag == 2)
                    av.image = [UIImage imageNamed:@"map_200pin_min"];
                if (annotation.tag == 3)
                    av.image = [UIImage imageNamed:@"map_300pin_min"];
                if (annotation.tag == 4)
                    av.image = [UIImage imageNamed:@"map_100pin_min"];
                
                av.centerOffset = CGPointMake(0, 0);
            } else {
                av.image = [self getMeizanImage:annotation.tag text:[self getAnnotationTitle:annotation.title]];
                av.centerOffset = [self getAnnotationLSizeOffsetValue:av.image];
            }
        }
    }
}
-(NSString*)getAnnotationTitle:(NSString*)title{
    NSRange searchResult = [title rangeOfString:@"（"];
    NSString *bufTitle = title;
    if (searchResult.length > 0){
        bufTitle = [title substringWithRange:NSMakeRange(0,searchResult.location)];
    }
    return bufTitle;
}
-(CGPoint)getAnnotationLSizeOffsetValue:(UIImage*)image{
    UIImage* dummy = [UIImage imageNamed:@"map_100pin_min"];
    return CGPointMake(
                image.size.width/2 - dummy.size.width/2,
                image.size.height/2 - dummy.size.height/2);
}
-(void)visibled100meizan:(BOOL)visibled{
    [self annotationHidden:1 hidden:!visibled];
}
-(void)visibled200meizan:(BOOL)visibled{
    [self annotationHidden:2 hidden:!visibled];
}
-(void)visibled300meizan:(BOOL)visibled{
    [self annotationHidden:3 hidden:!visibled];
}

- (IBAction)btnLocation:(id)sender {
    MKUserTrackingMode mode;
    switch (self.mapView.userTrackingMode) {
        case MKUserTrackingModeNone:
        default:
            mode = MKUserTrackingModeFollow;
            break;
        case MKUserTrackingModeFollow:
            mode = MKUserTrackingModeFollowWithHeading;
            break;
        case MKUserTrackingModeFollowWithHeading:
            mode = MKUserTrackingModeNone;
            break;
    }
    
    [self updateUserTrackingModeBtn:mode];
    [_mapView setUserTrackingMode:mode animated:YES];
}
- (void)updateUserTrackingModeBtn:(MKUserTrackingMode)mode {
    
    NSString *filename = nil;
    
    switch (mode) {
        case MKUserTrackingModeNone:
        default:
            filename = @"map_btn_loc_off";
            break;
        case MKUserTrackingModeFollow:
            filename = @"map_btn_loc_on";
            break;
        case MKUserTrackingModeFollowWithHeading:
            filename = @"map_btn_loc_hdup";
            break;
    }
    
    _btnLocationImg.image = [UIImage imageNamed:filename];
}
- (IBAction)manualDownload:(id)sender {

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"jp.nemui666.yamarecomap"]){
        [self showKakinErrAlert];
        return;
    }
    if (manualRecoding) {
        _btnManualDownloadImg.image = [UIImage imageNamed:@"map_btn_menu"];
        manualRecoding = NO;
        tileOverlay.manualRecoding = manualRecoding;
    } else {
        [self showManualAlert];
    }
}
- (void)startAutoDownloadMap{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"jp.nemui666.yamarecomap"]){
        [self showKakinErrAlert];
        return;
    }
    
    // クリア
    downloadUrls = nil;
    
    if ([_mapView getCurrentZoomLevel] > 18) {
        [self showSliderErrAlert];
    } else {
        [self showAutoAlert];
    }
}
- (IBAction)btnMapRouteList:(id)sender {
    if (manualRecoding) {
        [self manualDownload:self];
        return;
    }
    
    if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered) {
        // スライド
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    } else {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
    // 以前は anchorTopViewTo:ECRight だったが
    // anchorTopViewToRightAnimated:YES になった(たぶんあってる)
}
-(UIImage*)getMeizanImage:(NSInteger)pinKbn text:(NSString*)text{

    // 文字描画に使用するフォントの指定
    UIFont *font = [UIFont boldSystemFontOfSize:11.0f];
    UIImage* image = nil;
    if (pinKbn == 1) {
        image = [UIImage imageNamed:@"map_100pin_min"];
    } else if (pinKbn == 2) {
        image = [UIImage imageNamed:@"map_200pin_min"];
    } else if (pinKbn == 3) {
        image = [UIImage imageNamed:@"map_300pin_min"];
    } else if (pinKbn == 4) {
        image = [UIImage imageNamed:@"map_100pin_min"];
    }
    
    CGFloat width = 80;  // リサイズ後幅のサイズ
    CGFloat height = 15;  // リサイズ後高さのサイズ
    
    // ビットマップ形式のグラフィックスコンテキストの生成
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), 0.f, 0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:rect];
    
    // 描画する文字列の情報を指定する
    //--------------------------------------
    
    // 文字描画時に反映される影の指定
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(5.f, -5.f);
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowBlurRadius = 5.f;
    
    // パラグラフ関連の情報の指定
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByClipping;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 //NSShadowAttributeName: shadow,
                                 NSForegroundColorAttributeName: [UIColor redColor],
                                 NSBackgroundColorAttributeName: [UIColor clearColor]
                                 };
    
    // 文字列を描画する
    CGSize size = CGSizeMake(50, 18);
    [text drawInRect:CGRectMake(13,-1, size.width, size.height)
      withAttributes:attributes];
    //NSLog(@"%@",text);
    // 現在のグラフィックスコンテキストの画像を取得する
    UIImage *resultImage = nil;
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return resultImage;
}
#pragma mark Alert methods
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == manualAlert) {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            _btnManualDownloadImg.image = [UIImage imageNamed:@"map_d_end"];
            manualRecoding = YES;
            [_mapView removeOverlay:tileOverlay.overlay];
            TileOverlay *overlay = [[TileOverlay alloc] initOverlay];
            [_mapView addOverlay:overlay level:MKOverlayLevelAboveRoads];
        }
        if(buttonIndex == alertView.cancelButtonIndex)
        {
            NSLog(@"キャンセル");
        }
    }else if (alertView == autoDownloadAlert) {
        if(buttonIndex != alertView.cancelButtonIndex){

            [self showProgressAlert];

            [self execAutoDownload];
        }
    } else if (alertView == progressAlert) {
        if(buttonIndex == alertView.cancelButtonIndex){
            
            [sessionConfig invalidateAndCancel];
        }
    }
}
-(void)showKakinErrAlert{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.delegate = self;
    alert.title = @"地図ダウンロード";
    alert.message = @"ダウンロード機能をご利用いただくには制限解除が必要です。設定から制限解除を行ってください。";
    [alert addButtonWithTitle:@"OK"];
    alert.cancelButtonIndex = 0;
    [alert show];
}
-(void)showManualAlert{
    manualAlert = [[UIAlertView alloc] init];
    manualAlert.delegate = self;
    manualAlert.title = @"手動地図ダウンロード";
    manualAlert.message = @"表示されている場所の地図をダウンロードします。";
    // いいえボタンとはいボタンを設定
    [manualAlert addButtonWithTitle:@"キャンセル"];
    [manualAlert addButtonWithTitle:@"OK"];
    // alert.cancelButtonIndexに0を代入
    manualAlert.cancelButtonIndex = 0;
    [manualAlert show];
}
-(void)showAutoAlert{
    
    autoDownloadAlert = [[ZoomLevelView alloc]init];
    autoDownloadAlert.delegate = self;
    autoDownloadAlert.zoomLevelSlider.minimumValue = (int)[_mapView getCurrentZoomLevel];
    autoDownloadAlert.zoomLevelSlider.value = (int)[_mapView getCurrentZoomLevel];
    [autoDownloadAlert.zoomLevelSlider addTarget:self action:@selector(sliderAlert:)forControlEvents:UIControlEventValueChanged];
    long zoomLevel = [_mapView getCurrentZoomLevel];
    downloadUrls = [_mapView getMapTileUrl:zoomLevel maxLevel:zoomLevel];
    autoDownloadAlert.label.text = [NSString stringWithFormat:@"ズームレベル：%d",(int)zoomLevel];
    autoDownloadAlert.label2.text = [NSString stringWithFormat:@"ページ数：%d",(int)downloadUrls.count];
    [autoDownloadAlert show];
}

-(void)sliderAlert:(UISlider*)slider{
    int val = round(slider.value);
    slider.value = val;
    downloadUrls = [_mapView getMapTileUrl :[_mapView getCurrentZoomLevel] maxLevel:val];
    autoDownloadAlert.label.text = [NSString stringWithFormat:@"ズームレベル：%d",(int)val];
    autoDownloadAlert.label2.text = [NSString stringWithFormat:@"ページ数：%d",(int)downloadUrls.count];
}

-(void)showProgressAlert{
    progressAlert = [[ProgressView alloc]init];
    progressAlert.delegate = self;
    [progressAlert show];
}

-(void)showSliderErrAlert{
    manualAlert = [[UIAlertView alloc] init];
    manualAlert.delegate = self;
    manualAlert.title = @"一括地図ダウンロード";
    manualAlert.message = @"このレベルの地図は存在しません。";
    [manualAlert addButtonWithTitle:@"OK"];
    manualAlert.cancelButtonIndex = 0;
    [manualAlert show];
}
#pragma mark -NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"expectedTotalBytes");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"totalBytesExpectedToWrite");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSArray* path = [downloadTask.currentRequest.URL.path pathComponents];
    
    // 保存ディレクトリ作成
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    NSString *newDirPath = [documentPath stringByAppendingPathComponent:
                            [NSString stringWithFormat:@"yamareko_map/cache/%@/%@/",path[3],path[4]]];
    //NSLog(@"%@",newDirPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL created = [fileManager createDirectoryAtPath:newDirPath
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:&error];
    if (!created) {
        NSLog(@"failed to create directory. reason is %@ - %@", error, error.userInfo);
    }
    
    // 保存先の取得
    NSString* filePath = [newDirPath stringByAppendingPathComponent:path[5]];
    NSURL* dstURL = [NSURL fileURLWithPath:filePath];
    //NSLog(@"%@",[newDirPath stringByAppendingPathComponent:path[5]]);
    //return;
    // ファイルが存在するか?
    if ([fileManager fileExistsAtPath:filePath]) { // yes
        // NSLog(@"%@は既に存在しています", filePath);
    } else {
        error = nil;
        [fileManager moveItemAtURL:location toURL:dstURL error:&error];
        if (error != nil) {
            NSLog(@"failed to move file. reason is %@ - %@", error, error.userInfo);
        }
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // 必ず呼ばれる
    //NSLog(@"didCompleteWithError");
    
    downloadCount++;
    
    // 進捗通知
    //[self setProgress:downloadCount :downloadUrls.count];
    progressAlert.progressView.progress = (float)downloadCount/downloadUrls.count;
    progressAlert.label.text = [NSString stringWithFormat:@"%d/%d",(int)downloadCount,(int)downloadUrls.count];
    // 全てのタスクが終了した
    if (downloadUrls.count == downloadCount) {
        [session invalidateAndCancel];
        [_mapView removeOverlay:tileOverlay.overlay];
        TileOverlay *overlay = [[TileOverlay alloc] initOverlay];
        [_mapView addOverlay:overlay level:MKOverlayLevelAboveRoads];
        
        //[self setComplete];
        progressAlert.progressView.progress = 1.0;
        [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
    //NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
    if (!error) {
        //NSLog(@"task %d: finished!", (int)[tasksArray indexOfObject:task]);
    } else if (error.code == NSURLErrorTimedOut) {
        NSLog(@"task %d: timed out!", (int)[downloadUrls indexOfObject:task]);
    }
    
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
}

@end
