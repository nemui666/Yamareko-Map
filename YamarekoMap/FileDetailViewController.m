//
//  FileDetailViewController.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/19.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import "FileDetailViewController.h"

@interface GPX : NSObject
@property(nonatomic,strong)NSString* lat;
@property(nonatomic,strong)NSString* lon;
@property(nonatomic,strong)NSString* time;
@property(nonatomic,strong)NSString* ele;
@end
@implementation GPX

@end
@interface FileDetailViewController ()

@end

/*
@implementation NSDate(Utils)

-(NSDate *) toLocalTime
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

-(NSDate *) toGlobalTime
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

@end

@implementation NSString(Utils)
- (NSDate *)dateFromStringWithFormat:(NSString *)format
{
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    [inputDateFormatter setDateFormat:format];
    return [inputDateFormatter dateFromString:self];
    //return self;
}
@end
*/
@implementation FileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 地図のデリゲート設定
    [_mapView setDelegate:self];
    
    // 位置情報サービス作成
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //_locationManager = appDelegate.locationManager;
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10.0;
        _locationManager.delegate = self;
        
        [_locationManager startUpdatingLocation];
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
    
    [self initMapLine:_gpxFile.name];
    
    // 手動ダウンロードオフ
    _btnManualStop.hidden = YES;
    _btnManualStopImg.hidden = YES;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUserTrackingModeBtn:self.mapView.userTrackingMode];
    
    // シャドウ
    self.view.layer.shadowOpacity = 0.5f;
    self.view.layer.shadowRadius = 5.0f;
    self.view.layer.shadowColor = [UIColor grayColor].CGColor;
    
    [self.slidingViewController setAnchorRightRevealAmount:250.0f];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    _btnManualStop.hidden = NO;
    _btnManualStopImg.hidden = NO;
    _tileOverlay.manualRecoding = NO;
    [super viewWillDisappear:animated];
}
- (void)dealloc
{
    manualRecoding = NO;
    _tileOverlay.manualRecoding = NO;
    NSLog(@"dealloc");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark MapController methods
-(void)initMapLine:(NSString*)fileName{
    // ファイルのパスを取得
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cacheDirPath = [array objectAtIndex:0];
    NSString *filePath = [cacheDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"gpxfiles/%@", fileName]];
    
    // ファイルハンドルを作成する
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (!fileHandle) {
        NSLog(@"ファイルがありません．");
        CLLocationCoordinate2D center = _locationManager.location.coordinate;
        MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
        firstRegion = MKCoordinateRegionMake(center, span);
        [_mapView setRegion:[_mapView regionThatFits:firstRegion] animated:YES];
        return;
    }
    
    // ファイルから10バイト分のデータを取得
    NSData *data = [fileHandle readDataToEndOfFile];
    // データを文字列に変換
    /*
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%lu",(unsigned long)[str lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"%@", str);
    */
    
    // ファイルを閉じる
    [fileHandle closeFile];
    // 空のリストを生成する
    coordList = [NSMutableArray array];
    
    //NSURL *url = [NSURL URLWithString:filePath];
    dispatch_queue_t reentrantAvoidanceQueue = dispatch_queue_create("reentrantAvoidanceQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(reentrantAvoidanceQueue, ^{
        parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        if (![parser parse]) {
            NSLog(@"There was an error=%@ parsing the xml. with data %@", [parser parserError], [[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding]);
        }
        //[parser release];
    });
    dispatch_sync(reentrantAvoidanceQueue, ^{});
    
    //[HUD setProgress:.30 animated:YES];
    
   

    // ルートを表示する
    
    CustomAnnotation *annotation;
    CLLocationDistance distance_pin = 0;
    NSInteger anoNumber = 0; // アノテーション用
    float allTime = 0; // 合計時間
    float time_pin = 0; // 時間アノテーション用
    NSInteger anoTimeNumber = 0; // 時間アノテーション用
    CLLocationDistance allDistance = 0; // 合計距離
    int ascAlt = 0; // 累積上がり標高
    int dscAlt = 0; // 累積下り標高
    int preAlt = 0; // 標高計測用
    GPX* maxAlt; // 最高標高
    GPX* minAlt; // 最低標高
    _minMaxAnnotations = [NSMutableArray array];
    _stEdAnnotations = [NSMutableArray array];
    _hourAnnotations = [NSMutableArray array];
    _disAnnotations = [NSMutableArray array];
    
    CLLocationCoordinate2D coors[[coordList count]];
    float velocity[[coordList count]];
    NSMutableArray* dates = [NSMutableArray array];
    for (int i = 0;i < [coordList count];i++) {
        GPX *gpx = [coordList objectAtIndex:i];
        coors[i] = CLLocationCoordinate2DMake([gpx.lat doubleValue], [gpx.lon doubleValue]);
        velocity[i] = [gpx.ele floatValue];
        
        // UTCな時間（文字列）をNSDateなローカル時間に変換する
        NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
        [inputDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSDate *date = [inputDateFormatter dateFromString:gpx.time];
        if (date == nil) {
            [inputDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            date = [inputDateFormatter dateFromString:gpx.time];
        }
        if (date == nil) {
            // 時間を格納
            date = [NSDate date];
        }
        [dates addObject:date];
        @try {
        // 踏査年月日を表示
        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
        NSString *outputDateFormatterStr = @"yyyy年MM月dd日";
        [outputDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
        [outputDateFormatter setDateFormat:outputDateFormatterStr];
        NSString *outputDateStr = [outputDateFormatter stringFromDate:date];
        _lbTosaym.text = outputDateStr;
        }
        
        @catch (NSException *exception) {
            //NSLog(@"[ERROR]\nstr[%@]\nexception[%@]", str, exception);
            NSLog(@"[ERROR]\nexception[%@]", exception);
            _lbTosaym.hidden = YES;
        }
        
        /*
         NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
         NSString *outputDateFormatterStr = @"yyyy/MM/dd HH:mm:ss";
         [outputDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
         [outputDateFormatter setDateFormat:outputDateFormatterStr];
         NSString *outputDateStr = [outputDateFormatter stringFromDate:date];
         //NSLog(@"[in]%@ -> [out]%@(%@)", gpx.time, outputDateStr, outputDateFormatterStr);
         */
        
        // 最高、最低標高を求める
        if (maxAlt == nil || [gpx.ele floatValue] >= [maxAlt.ele floatValue]) {
            maxAlt = gpx;
        }
        if (minAlt == nil || [gpx.ele floatValue] <= [minAlt.ele floatValue]) {
            minAlt = gpx;
        }
        
        // 距離の計測
        if (i != 0){
            CLLocation *oldLocation = [[CLLocation alloc] initWithLatitude:coors[i-1].latitude longitude:coors[i-1].longitude];
            CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:coors[i].latitude longitude:coors[i].longitude];
            
            allDistance += [oldLocation distanceFromLocation:newLocation];
            distance_pin += [oldLocation distanceFromLocation:newLocation];
            
            // １キロごとにピンを配置
            if (distance_pin > 1000){
                anoNumber++;
                annotation = [[CustomAnnotation alloc] initWithLocationCoordinate:CLLocationCoordinate2DMake(coors[i].latitude, coors[i].longitude) title:@"Distance" subtitle:[NSString stringWithFormat:@"%d",(int)anoNumber]];
                
                //[_mapView addAnnotation:route];
                [_disAnnotations addObject:annotation];
                distance_pin = 0;
            }
            
            //allDistance += [oldLocation distanceFromLocation:newLocation];
            if (dates != nil) {
            // 時間の計測
            allTime += [dates[i] timeIntervalSinceDate:dates[i-1]];
            time_pin += [dates[i] timeIntervalSinceDate:dates[i-1]];
            if (time_pin > 3600) {
                anoTimeNumber++;
                annotation = [[CustomAnnotation alloc] initWithLocationCoordinate:CLLocationCoordinate2DMake(coors[i].latitude, coors[i].longitude) title:@"Hour" subtitle:[NSString stringWithFormat:@"%d",(int)anoTimeNumber]];
                
                //[_mapView addAnnotation:route];
                [_hourAnnotations addObject:annotation];
                time_pin = 0;
            }
            }
            
            // 標高の累積
            int alt_sa = [gpx.ele floatValue] - preAlt;
            if((abs(alt_sa)/[dates[i] timeIntervalSinceDate:dates[i-1]]) > 1.0f || [oldLocation distanceFromLocation:newLocation] == 0){
                
            } else {
                
            if (alt_sa > 0) {
                ascAlt += alt_sa;
            } else {
                dscAlt += alt_sa * -1;
            }
            
            /*
            int alt_sa;
            int elevation = [gpx.ele floatValue];
            if (preAlt < elevation) {
                alt_sa = elevation - preAlt;
                ascAlt += alt_sa;
            } else if (preAlt > elevation){
                alt_sa = preAlt - elevation;
                dscAlt += alt_sa;
            }
            */
            //NSLog(@"標高：%@",gpx.ele);
            
            //NSLog(@"時間（秒）：%f 標高差：%d 割合：%f",[dates[i] timeIntervalSinceDate:dates[i-1]],abs(alt_sa),abs(alt_sa)/[dates[i] timeIntervalSinceDate:dates[i-1]]);
            //NSLog(@"標高+：%d 標高-：%d",ascAlt,dscAlt);
            }
            
        }
        
        preAlt = [gpx.ele floatValue];
        //[HUD setProgress:0.30+(i+1/[coordList count]) animated:YES];思いの外速かったため今は使わない
        
    }
    
    
    _lbDistance.text = [NSString stringWithFormat:@"%.0f",allDistance/1000];
    //NSLog(@"合計距離:%f", allDistance);
    
    int hh = (int)(allTime / 3600);
    int mm = (int)((allTime-hh*3600) / 60);
    //float ss = allTime - (float)(hh*3600+mm*60);
    _lbTime.text = [NSString stringWithFormat:@"%d:%02d",hh,mm];
    //NSLog(@"所要時間:%d時%d分%f秒", hh,mm,ss);
    
    
    if (_gpxFile.ascending != nil) {
        _lbAscAlt.text = _gpxFile.ascending;
        _lbDscAlt.text = _gpxFile.descending;
    } else {
        _lbAscAlt.text = [NSString stringWithFormat:@"%d",ascAlt];
        _lbDscAlt.text = [NSString stringWithFormat:@"%d",dscAlt];
    }
    
    /*旧
     _line = [MKPolyline polylineWithCoordinates:coors count:[coordList count]];
     status = 1;
     [_mapView addOverlay:_line];
     */
    _polyline = [[GradientPolylineOverlay alloc] initWithPoints:coors velocity:velocity count:[coordList count]];
    [_mapView addOverlay:_polyline];
    
    
    /*
     _startRegion = _mapView.region;
     _startRegion.span.latitudeDelta = 0.05; // 地図の表示倍率
     _startRegion.span.longitudeDelta = 0.05;
     _startRegion.center = coors[0]; // 原宿を画面中央に表示
     _endRegion = _startRegion;
     _endRegion.center = coors[[coordList count]-1];
     [_mapView setRegion:_startRegion animated:YES];
     */
    
    // 開始地点の座標を記録
    _startCoodinate = coors[0];
    
    // 開始のピン
    annotation = [[CustomAnnotation alloc] initWithLocationCoordinate:CLLocationCoordinate2DMake(coors[0].latitude, coors[0].longitude) title:@"Start" subtitle:nil];
    //[_mapView addAnnotation:annotation];
    [_stEdAnnotations addObject:annotation];
    // 終了のピン
    annotation = [[CustomAnnotation alloc] initWithLocationCoordinate:CLLocationCoordinate2DMake(coors[[coordList count]-1].latitude, coors[[coordList count]-1].longitude) title:@"End" subtitle:nil];
    [_stEdAnnotations addObject:annotation];
    [_mapView addAnnotations:_stEdAnnotations];
    
    // 最大標高のピン
    annotation = [[CustomAnnotation alloc] initWithLocationCoordinate:CLLocationCoordinate2DMake([maxAlt.lat doubleValue], [maxAlt.lon doubleValue]) title:@"MaxAltitude" subtitle:[NSString stringWithFormat:@"%.0f", [maxAlt.ele floatValue]]];
    //[_mapView addAnnotation:annotation];
    [_minMaxAnnotations addObject:annotation];
    // 最大標高のピン
    annotation = [[CustomAnnotation alloc] initWithLocationCoordinate:CLLocationCoordinate2DMake([minAlt.lat doubleValue], [minAlt.lon doubleValue]) title:@"MinAltitude" subtitle:[NSString stringWithFormat:@"%.0f", [minAlt.ele floatValue]]];
    [_minMaxAnnotations addObject:annotation];
    [_mapView addAnnotations:_minMaxAnnotations];
    
    // 時間ピン
    [_mapView addAnnotations:_hourAnnotations];
    // 距離ピン
    [_mapView addAnnotations:_disAnnotations];
    
    // 地図の設定
    [self locationHome];
    
    // アノテーションの設定
    //[self hiddenDistance];
    //[self hiddenHour];
    
}
/*
-(void)getMapTileUrl:(NSInteger)zoomLevel{
    //NSMutableArray* downloadUrl = [NSMutableArray array];
    
    // 現在の座標位置取得
    MKMapRect visibleRect = _mapView.visibleMapRect;
    
    // 右下の座標位置
    CGPoint maxPoint = CGPointMake(
            visibleRect.origin.x + visibleRect.size.width,
            visibleRect.origin.y + visibleRect.size.height);
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
            if (downloadUrls.count >= 3000) return;
            // ダウンロードURLの作成
            NSString *strUrl = [[NSString alloc] initWithFormat:@"http://cyberjapandata.gsi.go.jp/xyz/std/%ld/%ld/%ld.png", (long)zoomLevel, (long)x, (long)y];
            NSURL* url = [NSURL URLWithString:strUrl];
            [downloadUrls addObject:url];
            //NSLog(@"%@",strUrl);
            //[self downloadFile:url];
        }
    }
    //downloadlist = downloadUrl;
}
 */
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
            [NSThread sleepForTimeInterval:0.15];
        }
        dispatch_async(main, ^{
            
        });
    });
}
/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([[change objectForKey:@"old"] integerValue] == 0){
        NSLog(@"task %d: started", (int)[tasksArray indexOfObject: object]);
    }
}
 */
#pragma mark MKMapViewDelegate methods

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[GradientPolylineOverlay class]]) {
        GradientPolylineRenderer *polylineRenderer = [[GradientPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRenderer.lineWidth = 8.0f;
        polylineRenderer.alpha = 0.6;
        return polylineRenderer;
    } else {
        _tileOverlay = [[TileOverlayView alloc] initWithOverlay:overlay];
        _tileOverlay.tileAlpha = 1.0; // e.g. 0.6 alpha for semi-transparent overlay

        // 表示されている
        if (manualRecoding) {
            _tileOverlay.manualRecoding = YES;
        }
        return _tileOverlay;
    }
    return nil;
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
        
        if ([annotation.title isEqualToString:@"Start"]) {
            // 好きな画像をannotationとして設定
            //annotationView.image = [self getStartImage];
            annotationView.image = [UIImage imageNamed:@"pin_start.png"];
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        else if ([annotation.title isEqualToString:@"End"]) {
            //annotationView.image = [self getEndImage];
            annotationView.image = [UIImage imageNamed:@"pin_end.png"];
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        else if ([annotation.title isEqualToString:@"Distance"]) {
            // 好きな画像をannotationとして設定
            //NSInteger num = [annotation.subtitle integerValue];
            //annotationView.image = [self getRouteImage:@"dis" number:num];
            annotationView.image = [self getMaxAltImage:3 text:annotation.subtitle];
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        else if ([annotation.title isEqualToString:@"Hour"]) {
            // 好きな画像をannotationとして設定
            //NSInteger num = [annotation.subtitle integerValue];
            //annotationView.image = [self getRouteImage:@"hour" number:num];
            annotationView.image = [self getMaxAltImage:4 text:annotation.subtitle];
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        else if ([annotation.title isEqualToString:@"MaxAltitude"]) {
            annotationView.image = [self getMaxAltImage:1 text:annotation.subtitle];
            annotationView.centerOffset = CGPointMake(0, -20);
            //annotationView.canShowCallout = YES;
        }
        else if ([annotation.title isEqualToString:@"MinAltitude"]) {
            //annotationView.image = [self getMinAltImage];
            annotationView.image = [self getMaxAltImage:2 text:annotation.subtitle];
            annotationView.centerOffset = CGPointMake(0, -20);
            //annotationView.canShowCallout = YES;
        }
        annotationView.annotation = annotation;
        //annotationView.alpha = 0.3f;
    
        //annotationView.alpha = 0.3;debug
        return annotationView;
    }
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
}
#pragma mark sub map tool
-(UIImage*)getStartImage{
    
    CGRect rect;
    float ritu = 0.1;
    
    UIImage* image = [UIImage imageNamed:@"ano_start.png"];
    
    CGFloat width = image.size.width * ritu;  // リサイズ後幅のサイズ
    CGFloat height = image.size.height * ritu;  // リサイズ後高さのサイズ
    
    // ビットマップ形式のグラフィックスコンテキストの生成
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), 0.f, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, ritu, ritu);
    
    rect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:rect];
    
    
    
    // 現在のグラフィックスコンテキストの画像を取得する
    image = nil;
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return image;
}
-(UIImage*)getEndImage{
    
    CGRect rect;
    float ritu = 0.1;
    
    UIImage* image = [UIImage imageNamed:@"ano_goal.png"];
    
    CGFloat width = image.size.width * ritu;  // リサイズ後幅のサイズ
    CGFloat height = image.size.height * ritu;  // リサイズ後高さのサイズ
    
    // ビットマップ形式のグラフィックスコンテキストの生成
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), 0.f, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, ritu, ritu);
    
    rect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:rect];
    
    
    
    // 現在のグラフィックスコンテキストの画像を取得する
    image = nil;
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return image;
}
-(UIImage*)getMaxAltImage:(NSInteger)pinKbn text:(NSString*)text{
    /*
    CGRect rect;
    float ritu = 1;
    
    UIImage* image = [UIImage imageNamed:@"pin_h_hyoko.png"];
    
    CGFloat width = image.size.width * ritu;  // リサイズ後幅のサイズ
    CGFloat height = image.size.height * ritu;  // リサイズ後高さのサイズ
    
    // ビットマップ形式のグラフィックスコンテキストの生成
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), 0.f, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, ritu, ritu);
    
    rect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:rect];
    
    
    
    // 現在のグラフィックスコンテキストの画像を取得する
    image = nil;
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return image;
    */
    // 描画するサイズ
    //CGSize size = CGSizeMake(34, 18);
    
    // ビットマップ形式のグラフィックスコンテキストの生成
    // 第2引数のopaqueを`NO`にすることで背景が透明になる
    //UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    NSString* text2;
    // 文字描画に使用するフォントの指定
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    UIImage* image = nil;
    if (pinKbn == 1) {
        image = [UIImage imageNamed:@"pin_h_hyoko.png"];
        font = [UIFont boldSystemFontOfSize:9.5f];
        text2 = [NSString stringWithFormat:@"m"];
    }else if (pinKbn == 2){
        image = [UIImage imageNamed:@"pin_l_hyoko.png"];
        font = [UIFont boldSystemFontOfSize:9.5f];
        text2 = [NSString stringWithFormat:@"m"];
    }else if (pinKbn == 3){
        image = [UIImage imageNamed:@"pin_km.png"];
        text2 = [NSString stringWithFormat:@"km"];
    }else if (pinKbn == 4){
        image = [UIImage imageNamed:@"pin_hour.png"];
        text2 = [NSString stringWithFormat:@"h"];
    }
    
    
    CGFloat width = image.size.width;  // リサイズ後幅のサイズ
    CGFloat height = image.size.height;  // リサイズ後高さのサイズ
    
    // ビットマップ形式のグラフィックスコンテキストの生成
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), 0.f, 0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:rect];
    
    // 描画する文字列の情報を指定する
    //--------------------------------------
    
    // 文字描画時に反映される影の指定
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0.f, -0.5f);
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowBlurRadius = 0.f;
    
    
    
    // パラグラフ関連の情報の指定
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByClipping;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 NSShadowAttributeName: shadow,
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSBackgroundColorAttributeName: [UIColor clearColor]
                                 };
    
    // 文字列を描画する
    CGSize size = CGSizeMake(34, 18);
    [text drawInRect:CGRectMake(4, 6, size.width, size.height)
      withAttributes:attributes];
    
    font = [UIFont boldSystemFontOfSize:8.0f];
    attributes = @{
                   NSFontAttributeName: font,
                   NSParagraphStyleAttributeName: style,
                   NSShadowAttributeName: shadow,
                   NSForegroundColorAttributeName: [UIColor blackColor],
                   NSBackgroundColorAttributeName: [UIColor clearColor]
                   };
    size = CGSizeMake(34, 18);
    [text2 drawInRect:CGRectMake(4, 16, size.width, size.height)
      withAttributes:attributes];
    
    // 現在のグラフィックスコンテキストの画像を取得する
    UIImage *resultImage = nil;
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return resultImage;
}
-(UIImage*)getMinAltImage{
    
    CGRect rect;
    float ritu = 0.1;
    
    UIImage* image = [UIImage imageNamed:@"ano_pin_min.png"];
    
    CGFloat width = image.size.width * ritu;  // リサイズ後幅のサイズ
    CGFloat height = image.size.height * ritu;  // リサイズ後高さのサイズ
    
    // ビットマップ形式のグラフィックスコンテキストの生成
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), 0.f, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, ritu, ritu);
    
    rect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:rect];
    
    
    
    // 現在のグラフィックスコンテキストの画像を取得する
    image = nil;
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return image;
}
#pragma mark NSXMLParserDelegate methods
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"trkpt"]) {
        isTrkpt = YES;
        /*
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [attributeDict objectForKey:@"lat"], @"lat",
                             [attributeDict objectForKey:@"lon"], @"lon",nil];
         */
        /*
        NSDictionary *dic = [[NSDictionary alloc]
                              initWithObjectsAndKeys:[attributeDict objectForKey:@"lat"], @"lat",
                              [attributeDict objectForKey:@"lon"], @"lon", nil];
        */
        GPX *gpx = [[GPX alloc]init];
        gpx.lat = [attributeDict objectForKey:@"lat"];
        gpx.lon = [attributeDict objectForKey:@"lon"];
        [coordList addObject:gpx];
    }
    else if ([elementName isEqualToString:@"time"]) {
        isTime = YES;
    }
    else if ([elementName isEqualToString:@"ele"]) {
        isEle = YES;
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"trkpt"]) {
        isTrkpt = NO;
    }
    else if ([elementName isEqualToString:@"time"]) {
        isTime = NO;
    }
    else if ([elementName isEqualToString:@"ele"]) {
        isEle = NO;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (isTrkpt) {
        if (isTime) {
            GPX *gpx = [coordList objectAtIndex:[coordList count]-1];
            gpx.time = string;
        } else if (isEle) {
            GPX *gpx = [coordList objectAtIndex:[coordList count]-1];
            gpx.ele = string;
        }
    }
}
#pragma mark CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    //if ([newLocation.timestamp timeIntervalSinceNow] > 3.0) return;
    //if (newLocation.horizontalAccuracy > 10.0) return;
    
    // 位置情報終了
    //[_locationManager stopUpdatingLocation];
    
    _mapView.showsUserLocation = YES;
}

#pragma mark MapViewAction methods
- (IBAction)userTrackingModeBtnTapped:(id)sender {
    
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

- (IBAction)btnHome:(id)sender {
    //[_mapView setRegion:_startRegion animated:YES];
    [_mapView setRegion:[_mapView regionThatFits:firstRegion] animated:YES];
}
- (void)locationHome {
    double minLat = 9999.0;
    double minLng = 9999.0;
    double maxLat = -9999.0;
    double maxLng = -9999.0;
    double lat, lng;
    for (id<MKAnnotation> annotation in _mapView.annotations){
        if (annotation != _mapView.userLocation) {
            lat = annotation.coordinate.latitude;
            lng = annotation.coordinate.longitude;
            //緯度の最大最小を求める
            if(minLat > lat)
                minLat = lat;
            if(lat > maxLat)
                maxLat = lat;
            
            //経度の最大最小を求める
            if(minLng > lng)
                minLng = lng;
            if(lng > maxLng)
                maxLng = lng;
        }
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat + minLat) / 2.0, (maxLng + minLng) / 2.0);
    MKCoordinateSpan span = MKCoordinateSpanMake(maxLat - minLat, maxLng - minLng);
    firstRegion = MKCoordinateRegionMake(center, span);
    firstRegion.span.latitudeDelta += 0.01;
    firstRegion.span.longitudeDelta += 0.01;
    [_mapView setRegion:[_mapView regionThatFits:firstRegion] animated:NO];
    
    //[_mapView setCenterCoordinate:_mapView.region.center zoomLevel:[_mapView getCurrentZoomLevel]-2 animated:YES];
    
}

- (BOOL)visbibleHour:(BOOL)visbibled {
    
    if (!visbibled) {
        [_mapView removeAnnotations:_hourAnnotations];
        return NO;
    }
    
    [_mapView addAnnotations:_hourAnnotations];
    return YES;
}

- (BOOL)visbibleDistance:(BOOL)visbibled {
    
    if (!visbibled) {
        [_mapView removeAnnotations:_disAnnotations];
        return NO;
    }
    
    [_mapView addAnnotations:_disAnnotations];
    return YES;
}

- (BOOL)visbibleMaxMin:(BOOL)visbibled {
    
    if (!visbibled) {
        [_mapView removeAnnotations:_minMaxAnnotations];
        return NO;
    }
    
    [_mapView addAnnotations:_minMaxAnnotations];
    return YES;
}
- (BOOL)visbibleStartEnd:(BOOL)visbibled {
    
    if (!visbibled) {
        [_mapView removeAnnotations:_stEdAnnotations];
        return NO;
    }
    
    [_mapView addAnnotations:_stEdAnnotations];
    return YES;
}


- (void)updateUserTrackingModeBtn:(MKUserTrackingMode)mode {
    
    NSString *filename = nil;
    
    switch (mode) {
        case MKUserTrackingModeNone:
        default:
            filename = @"map_btn_loc_off";
            _mapInfoView.alpha = 1;
            break;
        case MKUserTrackingModeFollow:
            filename = @"map_btn_loc_on";
            _mapInfoView.alpha = 1;
            break;
        case MKUserTrackingModeFollowWithHeading:
            filename = @"map_btn_loc_hdup";
            _mapInfoView.alpha = 0;
            break;
    }

    //[_btnLocation setImage:[UIImage imageNamed:filename] forState:UIControlStateNormal];
    _btnLocation.image = [UIImage imageNamed:filename];
}

// メニューボタンをタップしたときに呼ばれます
- (IBAction)menuButtonTapped:(id)sender
{
    // スライド
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
    
    // 以前は anchorTopViewTo:ECRight だったが
    // anchorTopViewToRightAnimated:YES になった(たぶんあってる)
}

- (IBAction)btnMapRouteList:(id)sender {
    if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered) {
    // スライド
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    } else {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
    // 以前は anchorTopViewTo:ECRight だったが
    // anchorTopViewToRightAnimated:YES になった(たぶんあってる)
}


- (IBAction)btnBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnManualStop:(id)sender {
    manualRecoding = NO;
    _tileOverlay.manualRecoding = NO;
    _btnManualStop.hidden = YES;
    _btnManualStopImg.hidden = YES;
    [_mapView setRegion:_mapView.region animated:NO];
    // ボタンを戻す
    _btnMenu.hidden = NO;
    _btnMenuImg.hidden = NO;
}
- (void)startManualDownloadMap{

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"jp.nemui666.yamarecomap"]){
        [self showKakinErrAlert];
        return;
    }
    [self showManualAlert];
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
#pragma mark Alert methods
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == manualAlert) {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            _btnManualStop.hidden = NO;
            _btnManualStopImg.hidden = NO;
            manualRecoding = YES;
            [_mapView removeOverlay:_tileOverlay.overlay];
            TileOverlay *overlay = [[TileOverlay alloc] initOverlay];
            [_mapView addOverlay:overlay level:MKOverlayLevelAboveRoads];
            /*
            [_mapView removeOverlay:_polyline];
            [_mapView removeOverlay:_tileOverlay.overlay];
            TileOverlay *overlay = [[TileOverlay alloc] initOverlay];
            [_mapView addOverlay:overlay];
            [_mapView addOverlay:_polyline];
            
            [_mapView setRegion:_mapView.region animated:NO];
            */
            // ボタンを消す
            _btnMenu.hidden = YES;
            _btnMenuImg.hidden = YES;
        }
        if(buttonIndex == alertView.cancelButtonIndex)
        {
            NSLog(@"キャンセル");
        }
    } else if (alertView == autoDownloadAlert) {
        if(buttonIndex != alertView.cancelButtonIndex){
            /*
            [downloadUrls removeAllObjects];
        
            // ズームレベル取得
            NSUInteger zoomLevel = (int)[_mapView getCurrentZoomLevel];
            int limit = zoomLevelSlider.value-2;
            for (int i = (int)zoomLevel;i <= limit;i++) {
                [self getMapTileUrl :i];
            }
            */
            //[self setStart];
            [self showProgressAlert];
            //progressView.progress = 0;
            [self execAutoDownload];
        }
    } else if (alertView == progressAlert) {
        if(buttonIndex == alertView.cancelButtonIndex){

            [sessionConfig invalidateAndCancel];
        }
    }
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
    /*
    autoDownloadAlert =[[UIAlertView alloc]initWithTitle:@"一括地図ダウンロード"
                                                  message:@""
                                                 delegate:self
                                        cancelButtonTitle:@"キャンセル"
                                        otherButtonTitles:@"OK", nil];
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    zoomLevelSlider = [[UISlider alloc] init];
    zoomLevelSlider.minimumValue = (int)[_mapView getCurrentZoomLevel];
    zoomLevelSlider.maximumValue = 18.0;  // 最大値を500に設定
    zoomLevelSlider.value = (int)[_mapView getCurrentZoomLevel];
    zoomLevelSlider.continuous = NO;
    //zoomLevelSlider.center = CGPointMake((self.view.bounds.size.width / 2) - 20, (self.view.bounds.size.height / 2) - 130);
    zoomLevelSlider.frame = CGRectMake(10, 0, 240, 30);
    [zoomLevelSlider addTarget:self action:@selector(sliderAlert:)forControlEvents:UIControlEventValueChanged];
    //[indicator startAnimating];
    [view addSubview:zoomLevelSlider];
    
    long zoomLevel = [_mapView getCurrentZoomLevel];
    
    downloadUrls = [_mapView getMapTileUrl:zoomLevel maxLevel:zoomLevel];
    
    [autoDownloadAlert setValue:view forKey:@"accessoryView"];
    autoDownloadAlert.message = [NSString stringWithFormat:@"表示範囲の地図を一括ダウンロードします。一度にダウンロードできるページ数は3000です。\n\nズームレベル：%.0f\nページ数：%d",zoomLevelSlider.value,(int)downloadUrls.count];
    [autoDownloadAlert show];
     */
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
    /*
    progressAlert =[[UIAlertView alloc]initWithTitle:@"一括地図ダウンロード"
                    message:@"ダウンロード中です。中止する場合はキャンセルを押してください。"
                                                delegate:self
                                       cancelButtonTitle:@"キャンセル"
                                       otherButtonTitles:nil, nil];
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    progressView = [[UIProgressView alloc] init];
    progressView.frame = CGRectMake(10, 0, 240, 30);
    [view addSubview:progressView];
    
    [progressAlert setValue:view forKey:@"accessoryView"];
    [progressAlert show];
    */
    
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
-(void)showKakinErrAlert{
    UIAlertView* alert = [[UIAlertView alloc] init];
    alert.delegate = self;
    alert.title = @"地図ダウンロード";
    alert.message = @"ダウンロード機能をご利用いただくには制限解除が必要です。設定から制限解除を行ってください。";
    [alert addButtonWithTitle:@"OK"];
    alert.cancelButtonIndex = 0;
    [alert show];
}

#pragma mark -NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    //NSLog(@"expectedTotalBytes");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //NSLog(@"totalBytesExpectedToWrite");
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
        [_mapView removeOverlay:_tileOverlay.overlay];
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
