//
//  MountSearchMapViewController.m
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/24.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "MountSearchMapViewController.h"

@interface MountSearchMapViewController ()

@end

@implementation MountSearchMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // UIViewの生成
    shieldView = [[UIView alloc] init];
    shieldView.frame = self.view.bounds;
    shieldView.backgroundColor = [UIColor blackColor];
    shieldView.alpha = 0.5;
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [window addSubview:shieldView];
    //[self.view addSubview:shieldView];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    // 画面の中央に表示するようにframeを変更する
    float w = indicator.frame.size.width;
    float h = indicator.frame.size.height;
    float x = self.view.frame.size.width/2 - w/2;
    float y = self.view.frame.size.height/2 - h/2;
    indicator.frame = CGRectMake(x, y, w, h);
    
    // クルクルと回し始める
    [indicator startAnimating];
    
    // 現在のサブビューとして登録する
    [shieldView addSubview:indicator];
    shieldView.hidden = YES;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"jp.nemui666.yamarecomap"]){
        manualRecoding = NO;
    } else {
        manualRecoding = NO;
    }
    
    [super visibled100meizan:NO];
    [super visibled200meizan:NO];
    [super visibled300meizan:NO];
    
    anoMountSearch = [NSMutableArray array];
    
    //self.mapView.delegate = self;
}
- (void)viewDidAppear:(BOOL)animated
{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    return nil;
}
- ( void ) mapView: ( MKMapView * ) mapView
regionWillChangeAnimated: ( BOOL ) animated {
    //[self.mapView removeOverlay:tileOverlay.overlay];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MountSearchTableViewController* ymvc = [segue destinationViewController];
    ymvc.segTitle = segueTitle;
    ymvc.ptid = segueUrl;
}

- (IBAction)btnMountSearch:(id)sender {
    
    shieldView.hidden = NO;
    [self.mapView removeAnnotations:anoMountSearch];
    [anoMountSearch removeAllObjects];
    //非同期の読み込み
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    dispatch_async(q_global, ^{
        
        [self getYamaData];
        
        dispatch_async(q_main, ^{
            if (anoMountSearch.count == 0) {
                [self showNotFoundAlert];
            }else {
                [self.mapView addAnnotations:anoMountSearch];
            }
            shieldView.hidden = YES;
        });
    });
}
-(BOOL)getYamaData{
    // 送信したいURLを作成する
    NSURL *url = [NSURL URLWithString:@"http://api.yamareco.com/api/v1/nearbyPoi/"];
    // Mutableなインスタンスを作成し、インスタンスの内容を変更できるようにする
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // MethodにPOSTを指定する。
    request.HTTPMethod = @"POST";
    // 送付したい内容を、key1=value1&key2=value2・・・という形の
    // 文字列として作成する
    NSString* lat = [NSString stringWithFormat:@"%f", super.mapView.centerCoordinate.latitude];
    NSString* lon = [NSString stringWithFormat:@"%f", super.mapView.centerCoordinate.longitude];
    MKMapPoint point1 = MKMapPointMake(super.mapView.visibleMapRect.origin.x,super.mapView.visibleMapRect.origin.y);
    MKMapPoint point2 =  MKMapPointMake(
        super.mapView.visibleMapRect.origin.x+super.mapView.visibleMapRect.size.width,
        super.mapView.visibleMapRect.origin.y);
    CLLocationDistance distance = MKMetersBetweenMapPoints(point1, point2);
    NSInteger intRange = distance/1000;
    if (intRange > 30) {
        intRange = 30;
    } else if (intRange < 1) {
        intRange = 1;
    }
    NSString* range = [NSString stringWithFormat:@"%d", (int)intRange];
    NSMutableArray *dataSource = [NSMutableArray array];
    for (NSInteger page = 1; page <= 5; page++) {

    NSString *body = [NSString stringWithFormat:@"page=%ld&range=%@&type_id=0&lat=%@&lon=%@", (long)page, range,lat,lon];
    NSLog(@"%@",body);
    // HTTPBodyには、NSData型で設定する
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    //サーバーとの通信を行う
    NSData *json = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //JSONをパース
    NSArray *array = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:nil];
    
    // エラーチェック
        if([[array valueForKeyPath:@"errcode"] isEqualToString:@"NODATA"]) {
            break;
        }
    NSArray *poilist = [array valueForKeyPath:@"poilist"];
    
    if (poilist.count == 0) {
        return NO;
    }
    for (NSArray* line in poilist) {
        //NSLog(@"山名：%@　URL：%@", [line valueForKeyPath:@"name"], [line valueForKeyPath:@"page_url"]);

        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [line valueForKeyPath:@"name"], @"name",
                             [line valueForKeyPath:@"ptid"], @"ptid",
                             [NSString stringWithFormat:@"%@",[line valueForKeyPath:@"elevation"]], @"elevation",
                             [line valueForKeyPath:@"lat"], @"lat",
                             [line valueForKeyPath:@"lon"], @"lon",
                             [line valueForKeyPath:@"ptid"],@"ptid",nil];
        [dataSource addObject:dic];
    }
    }
    
    for (NSDictionary *dic in dataSource) {
        NSString* anLat = [dic objectForKey:@"lat"];
        NSString* anLon = [dic objectForKey:@"lon"];
        CustomAnnotation* annotation = [[CustomAnnotation alloc] initWithLocationCoordinate:CLLocationCoordinate2DMake([anLat doubleValue], [anLon doubleValue]) title:[dic objectForKey:@"name"] subtitle:[NSString stringWithFormat:@"標高：%@m" ,[dic objectForKey:@"elevation"]]];
        annotation.tag = 4;
        annotation.buf = [dic objectForKey:@"ptid"];
        [anoMountSearch addObject:annotation];
    }
    
    
    /*
     NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
     if (!connection) {
     NSLog(@"connection error.");
     }
     */
    return YES;
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    // push the detail view
    segueTitle = ((CustomAnnotation*)view.annotation).title;
    segueUrl = ((CustomAnnotation*)view.annotation).buf;
    [self performSegueWithIdentifier:@"MountSearchTable" sender:nil];
}
-(void)showNotFoundAlert {
    // アラートの作成と設定
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"検索結果"
                                                    message:@"この付近には山の情報がありません。"
                                                   delegate:self
                                          cancelButtonTitle:@"確認"
                                          otherButtonTitles:nil, nil];
    
    // アラートの表示
    [alert show];
}

@end
