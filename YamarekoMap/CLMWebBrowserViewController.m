//
//  CLMWebBrowserViewController.m
//  WebBrowserSample
//
//  Created by hirai.yuki on 2014/09/06.
//  Copyright (c) 2014年 Classmethod, Inc. All rights reserved.
//

#import "CLMWebBrowserViewController.h"
//#import "CLMBackForwardListViewController.h"
//#import <SGNavigationProgress/UINavigationController+SGProgress.h>
#import "UINavigationController+M13ProgressViewBar.h"

//static NSString * const InitialURL = @"http://www.yamareco.com/";
static NSString * const InitialURL = @"http://www.yamareco.com/modules/jqm/";
@interface CLMWebBrowserViewController () 

@end

@implementation CLMWebBrowserViewController

#pragma mark - Lifecycle methods

- (void)loadView
{
    [self loadCookie];
    [super loadView];
    
    HUD = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
    HUD.progressViewSize = CGSizeMake(60.0, 60.0);
    HUD.animationPoint = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [window addSubview:HUD];
    
    WKProcessPool* processPool = [[WKProcessPool alloc] init];
    WKWebViewConfiguration *configuration1 = [[WKWebViewConfiguration alloc] init];
    configuration1.processPool = processPool;
    // WKWebView インスタンスの生成
    self.webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:configuration1];
    
    // Auto Layout の設定
    // 画面いっぱいに WKWebView を表示するようにする
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.webView];
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.webView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.webView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:0]
                                ]];
    
    
    // デリゲートにこのビューコントローラを設定する
    self.webView.navigationDelegate = self;
    
    // フリップでの戻る・進むを有効にする
    self.webView.allowsBackForwardNavigationGestures = YES;
    
    // WKWebView インスタンスを画面に配置する
    [self.view insertSubview:self.webView atIndex:0];
    
    _btnDownload.enabled = NO;
    _backButton.enabled = NO;
    _forwardButton.enabled = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;
    
    [self.navigationController showProgress];
    
    // WKWebView インスタンスのプロパティの変更を監視する
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    
    // 初回画面表示時にIntialURLで指定した Web ページを読み込む
    //NSURL *url = [NSURL URLWithString:InitialURL];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // リクエストを作成する
    [self loadCookie];
    NSURL* url = [NSURL URLWithString:InitialURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // CookieStorageから保存されたCookieを読み込み、
    // リクエストにCookieを設定します。
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    NSDictionary *header = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setAllHTTPHeaderFields:header];
    
    [self.webView loadRequest:request];
    
    /*
    // ツールバーの配置
    UIScreen *sc = [UIScreen mainScreen];
    CGRect scFrame = sc.bounds;
    
    // ツールバーを作成
    UIToolbar * toolBar = [ [ UIToolbar alloc ] initWithFrame:
                           CGRectMake(0,scFrame.size.height-44,scFrame.size.width,44) ];
    // ツールバーを親Viewに追加
    [ self.view addSubview:toolBar ];
    
    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"]
                                                            style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(didTapBackButton)];
    _backButton.enabled = false;
    
    _forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward.png"]
                                                            style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(didTapForwardButton)];
    _forwardButton.enabled = false;
*/
    /*
    UIBarButtonItem *btn3 = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"画像名"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(btnDownloadGpx)];
    */
/*
    _btnDownload = [[UIBarButtonItem alloc] initWithTitle:@"ダウンロード"
                                            style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(btnDownloadGpx) ];
*/
    _btnDownload.enabled = false;
/*
    //伸び縮みするスペーサ
    UIBarButtonItem * flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    // 固定スペーサ
    UIBarButtonItem * fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 50;//負の値を指定すると間隔が詰まります
    // ボタン配列をツールバーに設定する
    toolBar.items = [ NSArray arrayWithObjects:_backButton, fixedSpace, _forwardButton, flexibleSpace, _btnDownload, nil ];
*/
    
}

- (void)dealloc
{
    // WKWebView インスタンスのプロパティの変更を監視を解除する
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
    
    //[self saveCookie];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
    // ツールバー > 戻るボタンにロングタップのジェスチャーを登録する
    UIView *backButtonView = [self.backButton valueForKey:@"view"];
    [backButtonView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressBackButton:)]];
    
    // ツールバー > 進むボタンにロングタップのジェスチャーを登録する
    UIView *forwardButtonView = [self.forwardButton valueForKey:@"view"];
    [forwardButtonView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressForwardButton:)]];
    
    // ツールバー > 進むボタンにロングタップのジェスチャーを登録する
    UIView *reloadButtonView = [self.reloadButton valueForKey:@"view"];
    [reloadButtonView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressReloadButton:)]];
*/

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueDetailViewController"]) {
        //FileDetailViewController* vc = [segue destinationViewController];
    }
    /*
    if ([segue.identifier isEqualToString:@"showBackListSegue"]) {
        // 履歴画面に「戻る」履歴一覧をセットする
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        CLMBackForwardListViewController *backListViewController = (CLMBackForwardListViewController *)navigationController.topViewController;
        backListViewController.list = [[self.webView.backForwardList.backList reverseObjectEnumerator] allObjects];
    } else if ([segue.identifier isEqualToString:@"showForwardListSegue"]) {
        // 履歴画面に「進む」履歴一覧をセットする
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        CLMBackForwardListViewController *forwardListViewController = (CLMBackForwardListViewController *)navigationController.topViewController;
        forwardListViewController.list = self.webView.backForwardList.forwardList;
    }
     */
}

#pragma mark - NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        // estimatedProgressが変更されたら、プログレスバーを更新する
        //[self.navigationController setSGProgressPercentage:self.webView.estimatedProgress * 100.0f];
        [self.navigationController setProgress:self.webView.estimatedProgress animated:NO];
        
        
    } else if ([keyPath isEqualToString:@"title"]) {
        // titleが変更されたら、ナビゲーションバーのタイトルを設定する
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"loading"]) {
        // loadingが変更されたら、ステータスバーのインジケーターの表示・非表示を切り替える
        [UIApplication sharedApplication].networkActivityIndicatorVisible = self.webView.loading;
        
        // リロードボタンと読み込み停止ボタンの有効・無効を切り替える
        //self.reloadButton.enabled = !self.webView.loading;
        //self.stopButton.enabled = self.webView.loading;
    } else if ([keyPath isEqualToString:@"canGoBack"]) {
        // canGoBackが変更されたら、「＜」ボタンの有効・無効を切り替える
        self.backButton.enabled = self.webView.canGoBack;
    } else if ([keyPath isEqualToString:@"canGoForward"]) {
        // canGoForwardが変更されたら、「＞」ボタンの有効・無効を切り替える
        self.forwardButton.enabled = self.webView.canGoForward;
    }
}

#pragma mark - Private methods

- (IBAction)didTapBackButton:(id)sender;
{
    [self.webView goBack];
}

- (IBAction)didTapForwardButton:(id)sender;
{
    [self.webView goForward];
}

- (void)getDownloadUrl
{
    NSString *js =
    @"var elem = document.getElementsByTagName('a');"
    @"for (var i = 0;i < elem.length;i++){"
    @"    if (elem[i].href.indexOf('.gpx') > 0) {"
    @"        elem[i].href.toString();"
    @"    }"
    @"}";
    
    downloadUrl = nil;
    [_webView evaluateJavaScript:js completionHandler:^(id object, NSError *error) {
        //NSLog(@"%@",object);
        if (object == nil){
            _btnDownload.enabled = NO;
        } else {
            _btnDownload.enabled = YES;
            downloadUrl = object;
            [UIView beginAnimations:nil context:nil];  // 条件指定開始
            [UIView setAnimationDuration:2.0];  // 2秒かけてアニメーションを終了させる
            //[UIView setAnimationDelay:3.0];  // 3秒後にアニメーションを開始する
            //[UIView setAnimationRepeatCount:5.0];  // アニメーションを5回繰り返す
            //[UIView setAnimationCurve:UIViewAnimationCurveLinear];  // アニメーションは一定速度
            //アニメーション終了後に実行されるコールバック
            //[UIView setAnimationDidStopSelector:@selector(endAnimation)];
            _infowindowView.frame = CGRectMake(0, _toolbar.frame.origin.y-44, _infowindowView.frame.size.width,  _infowindowView.frame.size.height);  // 終了位置を200,400の位置に指定する
            [UIView commitAnimations];  // アニメーション開始！
        }
    }];
    
}
- (void)endAnimation{
    [UIView beginAnimations:nil context:nil];  // 条件指定開始
    [UIView setAnimationDuration:5.0];  // 2秒かけてアニメーションを終了させる
    _infowindowView.frame = _toolbar.frame;
    [UIView commitAnimations];  // アニメーション開始！
}
- (void)getDownloadWebTitle
{
    NSString *js = @"document.getElementsByTagName('h4')[0].innerText.toString();";
    downloadTitle = nil;
    [_webView evaluateJavaScript:js completionHandler:^(id object, NSError *error) {
        //NSLog(@"%@",object);
        downloadTitle = object;
    }];
}
- (void)getDownloadWebUrl
{
    NSString *js = @"location.href.toString();";
    downloadMotoUrl = nil;
    [_webView evaluateJavaScript:js completionHandler:^(id object, NSError *error) {
        //NSLog(@"%@",object);
        downloadMotoUrl = object;
    }];
}
- (void)loginYamareko
{
    
    NSString *js = @"location.href.toString();";
    downloadMotoUrl = nil;
    [_webView evaluateJavaScript:js completionHandler:^(id object, NSError *error) {
        //NSLog(@"%@",object);
        downloadMotoUrl = object;
        if ([InitialURL isEqualToString:downloadMotoUrl]) {
            // ログインする
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *directory = [paths objectAtIndex:0];
            NSString *filePath = [directory stringByAppendingPathComponent:@"data.plist"];
            NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
            if (array) {
                [self loginYamarecoUser:[array objectAtIndex:0] pass:[array objectAtIndex:1]];
            } else {
                return;
            }
        }
    }];
}
- (void)loginYamarecoUser:(NSString*)username pass:(NSString*)pass
{
    
    NSString *js = [NSString stringWithFormat:@"document.getElementsByName('uname')[0].value = '%@';document.getElementsByName('pass')[0].value = '%@';document.getElementsByTagName('form')[0].submit();",username,pass];

    [_webView evaluateJavaScript:js completionHandler:^(id object, NSError *error) {}];
}
- (void)didLongPressBackButton:(UILongPressGestureRecognizer *)gesutureRecognizer
{
    if (gesutureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self performSegueWithIdentifier:@"showBackListSegue" sender:self];
    }
}

- (void)didLongPressForwardButton:(UILongPressGestureRecognizer *)gesutureRecognizer
{
    if (gesutureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self performSegueWithIdentifier:@"showForwardListSegue" sender:self];
    }
}

- (IBAction)didTapReloadButton:(id)sender
{
    [self.webView reload];
}

- (void)didLongPressReloadButton:(UILongPressGestureRecognizer *)gesutureRecognizer
{
    if (gesutureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Reload" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.webView reload];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Reload from origin" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.webView reloadFromOrigin];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)didTapStopButton:(id)sender
{
    [self.webView stopLoading];
}

- (IBAction)unwindToWebBrowser:(UIStoryboardSegue *)segue
{
    if (self.backForwardListItem) {
        [self.webView goToBackForwardListItem:self.backForwardListItem];
        self.backForwardListItem = nil;
    }
}

- (IBAction)btnDownloadGpx:(id)sender; {
    [self getGpxFile];
}

- (IBAction)btnBackHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnUser:(id)sender {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ユーザー情報"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"閉じる"
                                            otherButtonTitles:@"登録", nil];
    [message setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];//１行で実装
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"data.plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    if (array) {
        for (NSInteger i = 0;i < [array count];i++) {
            NSString* user = [array objectAtIndex:i];
            //NSLog(@"%@", user);
            UITextField *textField = [message textFieldAtIndex:i];
            textField.text = user;
        }
    } else {
        NSLog(@"%@", @"データが存在しません。");
    }
    [message show];
}

- (void)getGpxFile{
    
    HUD.status = @"Loading";
    [HUD show:YES];
    [HUD setProgress:self.webView.estimatedProgress animated:YES];
    [HUD setProgress:.0 animated:YES];
    

    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(globalQueue, ^{
        //ダウンロードファイルの保存先
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *cacheDirPath = [array objectAtIndex:0];
        // ディレクトリ作成
        NSString *newCacheDirPath = [cacheDirPath stringByAppendingPathComponent:@"gpxfiles"];
        // 次にFileManagerを用いて、ディレクトリの作成を行います。
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        BOOL created = [fileManager createDirectoryAtPath:newCacheDirPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
        // 作成に失敗した場合は、原因をログに出します。
        if (!created) {
            NSLog(@"failed to create directory. reason is %@ - %@", error, error.userInfo);
        }
        
        //NSString* directoryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat  = @"yyyyMMddHHmmss";
        NSString *fileName = [NSString stringWithFormat:@"%@.gpx",[df stringFromDate:[NSDate date]]];
        
        //保存するファイルパス
        NSString *filePath = [[newCacheDirPath stringByAppendingPathComponent:fileName]
                              stringByStandardizingPath];
        
        // リクエストを作成する
        NSURL* url = [NSURL URLWithString:downloadUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // CookieStorageから保存されたCookieを読み込み、
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
        dispatch_async(main, ^{
            // error
            NSString *error_str = [error localizedDescription];
            if (0<[error_str length]) {
                UIAlertView *alert = [
                                      [UIAlertView alloc]
                                      initWithTitle : @"地図情報のダウンロードに失敗しました。"
                                      message : nil
                                      delegate : nil
                                      cancelButtonTitle : @"OK"
                                      otherButtonTitles : nil
                                      ];
                [alert show];
                [self setComplete];
                return;
            }
            
            // responseを受け取ったあとの処理
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm createFileAtPath:filePath contents:[NSData data] attributes:nil];
            NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:filePath];
            [file writeData:data];
            
            // CoreDataに保存
            NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
            NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
            
            // If appropriate, configure the new managed object.
            // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
            [newManagedObject setValue:[NSDate date] forKey:@"regist_dt"];
            [newManagedObject setValue:fileName forKey:@"name"];
            [newManagedObject setValue:downloadTitle forKey:@"title"];
            [newManagedObject setValue:downloadMotoUrl forKey:@"moto_url"];
            [newManagedObject setValue:[[NSNumber alloc] initWithBool:NO] forKey:@"favorite"];
            [newManagedObject setValue:[[NSNumber alloc] initWithBool:YES] forKey:@"first_flag"];
            // Save the context.
            NSError* error = nil;
            if (![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            //[self performSegueWithIdentifier:@"segueDetailViewController" sender:self];
            

            //[HUD setProgress:.66 animated:YES];
            // インジケーター閉じる
            [self setComplete];
        });
    });
    
}


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

#pragma mark - WKNavigationDelegate methods

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    //NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    //NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //NSLog(@"%s", __FUNCTION__);
    [self.navigationController finishProgress];
    
}

//読み込み完了後呼ばれる
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //NSLog(@"%s", __FUNCTION__);
    [self.navigationController finishProgress];
    [self getDownloadUrl];
    [self getDownloadWebTitle];
    [self getDownloadWebUrl];
    [self loginYamareko];
    [self saveCookie];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    //NSLog(@"%s", __FUNCTION__);
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

#pragma mark - AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        // 変更されたテキスト取得
        NSString* user = [[alertView textFieldAtIndex:0] text];
        NSString* pass = [[alertView textFieldAtIndex:1] text];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        NSString *filePath = [directory stringByAppendingPathComponent:@"data.plist"];
        
        NSArray *array = @[user, pass];
        BOOL successful = [array writeToFile:filePath atomically:NO];
        if (successful) {
            [self loginYamarecoUser:user pass:pass];
            //NSLog(@"%@", @"データの保存に成功しました。");
        }
    }
}


- (void)setComplete
{
    [HUD performAction:M13ProgressViewActionSuccess animated:YES];
    [self performSelector:@selector(reset) withObject:nil afterDelay:1.5];
}

- (void)reset
{
    [HUD setProgress:.0 animated:YES];
    [HUD hide:YES];
    [HUD performAction:M13ProgressViewActionNone animated:NO];
    //Enable other controls
}
@end
