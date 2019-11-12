//
//  YmrcWebViewController.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2015/02/26.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "YmrcWebViewController.h"

@interface YmrcWebViewController ()

@end
//static NSString * const BaceURL = @"http://www.yamareco.com/modules/jqm/";150301del
static NSString * const BaceURL = @"http://www.yamareco.com?smp=1";
@implementation YmrcWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;
    
    // 画面初期化
    _btnDownload.title = @"ルート情報なし";
    _btnDownload.enabled = NO;
    _btnBack.enabled = NO;
    _btnNext.enabled = NO;
    
    _webView.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    _btnDownload.enabled = NO;
}
- (void)viewDidAppear:(BOOL)animated
{
    // Webの読み込み
    [self loadCookie];
    NSURL *url;
    if (_InitialURL == nil) {
        url = [NSURL URLWithString:BaceURL];
    } else {
        url = [NSURL URLWithString:_InitialURL];
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self saveCookie];
}

#pragma mark - WebView

// 読み込み後に呼ばれる
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (webView.loading) return; // 複数呼ばれないようにする制御
    self.btnBack.enabled = self.webView.canGoBack;
    self.btnNext.enabled = self.webView.canGoForward;
    [self removeYamarecoFooter];
    [self getYamareco];
}
// ページ読込開始時にインジケータをくるくるさせる
-(void)webViewDidStartLoad:(UIWebView*)webView{
    [self removeYamarecoFooter];
    [self getYamareco];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - SubProcedure
- (void)getYamareco
{
    /*// 150301del
    NSString *js =
    @"var elem = document.getElementsByTagName('a');"
    @"for (var i = 0;i < elem.length;i++){"
    @"    if (elem[i].href.indexOf('.gpx') > 0) {"
    @"        elem[i].href.toString();"
    @"    }"
    @"}";
    downloadUrl = nil;
    downloadUrl = [self.webView stringByEvaluatingJavaScriptFromString:js];
    */
    // 150301
    NSString *js =
    @"var elem = document.getElementsByTagName('a');"
    @"for (var i = 0;i < elem.length;i++){"
    @"    if (elem[i].href.indexOf('.gpx') != -1) {"
    //@"        elem[i].title.toString();"
    @"        elem[i].href.toString();"
    @"    }"
    @"}";
    
    NSString *downloadCheck = nil;
    downloadCheck = [self.webView stringByEvaluatingJavaScriptFromString:js];
    
    // 2
    js =
    @"var elem = document.getElementsByTagName('input');"
    @"for (var i = 0;i < elem.length;i++){"
    @"    if (elem[i].value.indexOf('.gpx') != -1) {"
    //@"        elem[i].title.toString();"
    @"        elem[i].value.toString();"
    @"    }"
    @"}";
    NSString *downloadUrl2 = nil;
    downloadUrl2 = [self.webView stringByEvaluatingJavaScriptFromString:js];
    
    // 150301
    //if ([downloadUrl isEqualToString:@""]) {150301del
    if ([downloadCheck isEqualToString:@""] && [downloadUrl2 isEqualToString:@""]) {
        _btnDownload.title = @"ルート情報なし";
        _btnDownload.enabled = NO;
    } else {
        /*
        js =
        @"var elem = document.getElementsByTagName('input');"
        @"for (var i = 0;i < elem.length;i++){"
        @"    if (elem[i].value.indexOf('.gpx') > 0) {"
        @"        elem[i].value.toString();"
        @"    }"
        @"}";
        downloadUrl = [self.webView stringByEvaluatingJavaScriptFromString:js];
        downloadUrl = [InitialURL stringByAppendingString:downloadUrl];// 150301
        */
        /*
        if (![downloadCheck isEqualToString:@""]) {
            downloadUrl = downloadCheck;
        } else if (![downloadUrl2 isEqualToString:@""]) {
            downloadUrl2 = [BaceURL stringByAppendingString:downloadUrl2];
            downloadUrl = downloadUrl2;
        }
        */
        
        //js = @"document.getElementsByTagName('h4')[0].innerText.toString();";
        js = @"document.getElementsByTagName('title')[0].innerText.toString();";
        downloadTitle = nil;
        downloadTitle = [self.webView stringByEvaluatingJavaScriptFromString:js];
    
        js = @"location.href.toString();";
        downloadMotoUrl = nil;
        downloadMotoUrl = [self.webView stringByEvaluatingJavaScriptFromString:js];
        
        downloadUrl = [downloadMotoUrl stringByReplacingOccurrencesOfString:@"detail-" withString:@"track-"];
        downloadUrl = [downloadUrl stringByReplacingOccurrencesOfString:@".html" withString:@".gpx"];
        
        _btnDownload.title = @"ルート情報取得";
        _btnDownload.enabled = YES;
    }
}
- (void)removeYamarecoFooter
{

    NSString *js =
    @"var elem = document.getElementById('footer');"
    @"while (elem.firstChild){"
    @"    elem.removeChild(elem.firstChild);"
    @"}";
    
    NSString *downloadCheck = nil;
    downloadCheck = [self.webView stringByEvaluatingJavaScriptFromString:js];
    
}
    
- (BOOL)getGpxFile:(NSString*)_url{
    NSError *error = nil;
        
    // ファイルのダウンロード
    NSURL* url = [NSURL URLWithString:_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // リクエストにCookieを設定します。
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    NSDictionary *header = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setAllHTTPHeaderFields:header];
    NSURLResponse *response = nil;
    error = nil;
    NSData *data = [
                    NSURLConnection
                    sendSynchronousRequest : request
                    returningResponse : &response
                    error : &error
                    ];
    NSString *error_str = [error localizedDescription];
    if (0<[error_str length]) {
        [self showErrorAlert];
        return NO;
    }
    
    // ディレクトリ作成
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cacheDirPath = [array objectAtIndex:0];
    NSString *newCacheDirPath = [cacheDirPath stringByAppendingPathComponent:@"gpxfiles"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    error = nil;
    BOOL created = [
                    fileManager
                    createDirectoryAtPath:newCacheDirPath
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:&error
                    ];
    if (!created) {
        NSLog(@"failed to create directory. reason is %@ - %@", error, error.userInfo);
    }
    
    // ファイルの保存
    NSString *filePath = [[newCacheDirPath stringByAppendingPathComponent:[url lastPathComponent]]stringByStandardizingPath];
    /*
    NSArray *moArray = [_fetchedResultsController fetchedObjects];
    for (int i = 0; i < moArray.count; i++) {
        NSManagedObject *object = [moArray objectAtIndex:i];
        if([[object valueForKey:@"name"] isEqual:[url lastPathComponent]]) {
            return;
        }
        NSLog(@"name=%@ name2=%@", [object valueForKey:@"name"],[url lastPathComponent]);
    }
     */
    // ダウンロードされたか
    NSRange searchResult = [filePath rangeOfString:@".gpx"];
    if(searchResult.location == NSNotFound){
        // みつからない場合の処理
        [self showErrorAlert];
        
        return NO;
    }
    // ファイルが存在するか?
    if ([fileManager fileExistsAtPath:filePath]) { // yes
        //NSLog(@"%@は既に存在しています", filePath);
        [self showExistErrorAlert];
        
        return NO;
    } else {
        //NSLog(@"%@は存在していません", filePath);
    }
    [fileManager createFileAtPath:filePath contents:[NSData data] attributes:nil];
    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [file writeData:data];
    
    fileName = [url lastPathComponent];
    return YES;
}
-(void)saveYamareco{
    //NSLog(@"%@",[url lastPathComponent]);
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newManagedObject setValue:[NSDate date] forKey:@"regist_dt"];
    [newManagedObject setValue:fileName forKey:@"name"];
    [newManagedObject setValue:downloadTitle forKey:@"title"];
    [newManagedObject setValue:downloadMotoUrl forKey:@"moto_url"];
    [newManagedObject setValue:[[NSNumber alloc] initWithBool:NO] forKey:@"favorite"];
    [newManagedObject setValue:[[NSNumber alloc] initWithBool:YES] forKey:@"first_flag"];
    [newManagedObject setValue:[[NSNumber alloc] initWithBool:NO] forKey:@"import"];
    [newManagedObject setValue:ascending forKey:@"ascending"];
    [newManagedObject setValue:descending forKey:@"descending"];
    [newManagedObject setValue:_totalDate forKey:@"total_time"];
    NSError* error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
-(BOOL)getYamarecoTotal{
    NSRange range = [fileName rangeOfString:@"track-"];
    NSRange range2 = [fileName rangeOfString:@".gpx"];
    
    
    NSString* detailID = [fileName substringWithRange:
                        NSMakeRange(range.length,range2.location-(range.location+range.length))];
    NSLog(@"fileName:%@ -> %@",fileName, detailID);

    NSString *strUrl = [[NSString stringWithFormat:@"http://nemui666.m50.coreserver.jp/yamareco_map/get_total.php?did=%@",detailID] stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceCharacterSet]];
    NSURL *url = [NSURL URLWithString:strUrl];
    // Mutableなインスタンスを作成し、インスタンスの内容を変更できるようにする
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request.HTTPMethod = @"GET";
    
    //サーバーとの通信を行う
    NSData *json = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (json == nil) {
        return NO;
    }
    //JSONをパース
    NSArray *arrayJson = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:nil];
    if (arrayJson.count == 0) {
        return NO;
    }

    for (NSArray* line in arrayJson) {
        NSLog(@"ascending：%@", [line valueForKeyPath:@"ascending"]);
        NSLog(@"descending：%@", [line valueForKeyPath:@"descending"]);
        ascending = [line valueForKeyPath:@"ascending"];
        descending = [line valueForKeyPath:@"descending"];
    }

    return YES;
}
/*
-(NSString*)getDetailId{
    NSRange searchResult = [downloadUrl rangeOfString:@"track-"];
    NSRange searchResult2 = [downloadUrl rangeOfString:@".html"];
    NSString *str = [downloadUrl substringWithRange:NSMakeRange(
        searchResult.location+searchResult.length,
        searchResult2.location-(searchResult.location+searchResult.length))];
    NSLog(@"%@",str);
    return str;
}
 */
#pragma mark - Cookie
- (void)loadCookie{
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults]
                           objectForKey:@"SavedHTTPCookiesKey"];
    if (cookiesData) {
        //NSLog(@"load cookies");
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        for (NSHTTPCookie *cookie in cookies){
            //NSLog(@"cookie: name=%@, value=%@", cookie.name, cookie.value);
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
}
- (void)saveCookie{
    
    // Save the cookies to the user defaults
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:
                           [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData
                                              forKey:@"SavedHTTPCookiesKey"];
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GPXFile" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"regist_dt" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)btnBack:(id)sender {
    [self.webView goBack];
}

- (IBAction)btnNext:(id)sender {
    [self.webView goForward];
}

- (IBAction)btnDownload:(id)sender {
    if ([self getGpxFile:downloadUrl]) {
        [self getYamarecoTotal];
    
        [self saveYamareco];
        [self showSuccessAlert];
    }
}

- (IBAction)btnClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AlertView
-(void)showSuccessAlert {
    // アラートの作成と設定
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ダウンロード成功"
                                                     message:@"完了しました。"
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil];
    
    // アラートの表示
    [message show];
}
-(void)showErrorAlert {
    // アラートの作成と設定
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ダウンロード失敗"
                                                      message:@"[設定＞ヤマレコアカウント]\nからヤマレコにログインして実行してください。"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"OK", nil];
    
    // アラートの表示
    [message show];
}
-(void)showExistErrorAlert {
    // アラートの作成と設定
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ダウンロード失敗"
                                                      message:@"このルート情報は既に存在しています。"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"OK", nil];
    
    // アラートの表示
    [message show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"ユーザー情報"]) {
        
    }
}
/*
- (void)childViewDidChanged:(MountainSearchViewController*)viewController :(NSIndexPath *)indexPath{
    NSURL *url = [NSURL URLWithString:[viewController.dataSourceUrl objectAtIndex:indexPath.row]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
}
 */
@end
