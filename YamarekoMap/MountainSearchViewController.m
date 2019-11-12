//
//  MountainSearchViewController.m
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/22.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "MountainSearchViewController.h"

@interface MountainSearchViewController ()

@end

@implementation MountainSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // デリゲートメソッドをこのクラスで実装する
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    _dataSource = [NSMutableArray array];
    _dataSourceUrl = [NSMutableArray array];
    _dataSourceDetail = [NSMutableArray array];
    _dataSourcePtid = [NSMutableArray array];
    _areaId = @"0";
    
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([[ud objectForKey:@"ud_auto_login"] isEqualToString:@"1"]) {
        loadFlg = YES;
        [self yamarecoLoginId:[ud objectForKey:@"ud_user_id"] pass:[ud objectForKey:@"ud_user_pass"]];
        [self coreserverLogin:[ud objectForKey:@"ud_user_id"] pass:[ud objectForKey:@"ud_user_pass"]];
        [self saveCookie];
        loadFlg = NO;
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    // 選択状態解除
    [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:YES];
    [_searchBar resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue destinationViewController] isKindOfClass:[AreaTableViewController class]]) {
        AreaTableViewController* areaTableView = [segue destinationViewController];
        areaTableView.delegate = self;
    } else if ([segue.identifier isEqualToString:@"MountSearchTable"]) {
        MountSearchTableViewController* vc = [segue destinationViewController];
        vc.segTitle = _dataSource[_tableView.indexPathForSelectedRow.row];
        vc.ptid = _dataSourcePtid[_tableView.indexPathForSelectedRow.row];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger dataCount;
    
    // テーブルに表示するデータ件数を返す
    switch (section) {
        case 0:
            dataCount = 2;
            break;
        case 1:
            dataCount = self.dataSource.count;
            break;
        default:
            break;
    }
    return dataCount;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section) {
        case 0: // 1個目のセクションの場合
            return @"別の方法で探す";
            break;
        case 1: // 2個目のセクションの場合
            return @"検索結果";
            break;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    switch (indexPath.section) {
        case 0:{
            static NSString *CellIdentifier = @"OtherCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0)
                cell.textLabel.text = @"ヤマレコから探す";
            if (indexPath.row == 1)
                cell.textLabel.text = @"地図から探す";
            
            return cell;
            break;
        }
        case 1:
        {
            static NSString *CellIdentifier = @"Cell";
            // 再利用できるセルがあれば再利用する
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (!cell) {
                // 再利用できない場合は新規で作成
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.text = self.dataSource[indexPath.row];
            //cell.detailTextLabel.text = self.dataSourceDetail[indexPath.row];
            [cell.detailTextLabel setText:self.dataSourceDetail[indexPath.row]];
            /*
            NSURL* url = [NSURL URLWithString:self.dataSourceImg[indexPath.row]];
            NSData* data = [NSData dataWithContentsOfURL:url];
            cell.imageView.image = [[UIImage alloc] initWithData:data];
            */
            return cell;
            break;
        }
        default:
            break;
    }
    
    return nil;
}
-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"cellcont = %d",indexPath.row);
    if(indexPath.row >= [_dataSource count]-10 && !loadFlg && !maxFlg) {
        //非同期の読み込み
        loadFlg = YES;
        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t q_main = dispatch_get_main_queue();
        cell.imageView.image = nil;
        dispatch_async(q_global, ^{
            
            [self getYamaDataPage:++loadPage];
            
            dispatch_async(q_main, ^{
                [_tableView reloadData];
            });
        });
        loadFlg = NO;
    }
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 読み込み中は遷移させない
    if (loadFlg) {
        return;
    }
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0)
                [self performSegueWithIdentifier:@"YamarecoWeb" sender:nil];
            if (indexPath.row == 1)
                [self performSegueWithIdentifier:@"MountSearchMap" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"MountSearchTable" sender:nil];
        default:
            break;
    }
}
-(void)getYamaDataPage:(NSInteger)page{
    maxFlg = YES;
    // 送信したいURLを作成する
    NSURL *url = [NSURL URLWithString:@"http://api.yamareco.com/api/v1/searchPoi/"];
    // Mutableなインスタンスを作成し、インスタンスの内容を変更できるようにする
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // MethodにPOSTを指定する。
    request.HTTPMethod = @"POST";
    // 送付したい内容を、key1=value1&key2=value2・・・という形の
    // 文字列として作成する
    NSString *body = [NSString stringWithFormat:@"page=%ld&name=%@&type_id=0&area_id=%@", (long)page, _searchBar.text,_areaId];
    
    // HTTPBodyには、NSData型で設定する
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    //サーバーとの通信を行う
    NSData *json = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //JSONをパース
    NSArray *array = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:nil];
    
    NSArray *poilist = [array valueForKeyPath:@"poilist"];
    
    for (NSArray* line in poilist) {
        //NSLog(@"山名：%@　URL：%@", [line valueForKeyPath:@"name"], [line valueForKeyPath:@"detail"]);
        [_dataSource addObject:[line valueForKeyPath:@"name"]];
        [_dataSourceUrl addObject:[line valueForKeyPath:@"page_url"]];
        [_dataSourceDetail addObject:[NSString stringWithFormat:@"%@m",[line valueForKeyPath:@"elevation"]] ];
        [_dataSourcePtid addObject:[line valueForKeyPath:@"ptid"]];
        maxFlg = NO;
    }
}
-(void)yamarecoLoginId:(NSString*)userId pass:(NSString*)password{
    // 送信したいURLを作成する
    NSURL *url = [NSURL URLWithString:@"http://www.yamareco.com/user.php/"];
    // Mutableなインスタンスを作成し、インスタンスの内容を変更できるようにする
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // MethodにPOSTを指定する。
    request.HTTPMethod = @"POST";
    // 送付したい内容を、key1=value1&key2=value2・・・という形の
    // 文字列として作成する
    NSString *body = [NSString stringWithFormat:@"uname=%@&pass=%@&rememberme=/?smp=1&xoops_redirect=On&op=login", userId, password];
    
    // HTTPBodyには、NSData型で設定する
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request  queue:[[NSOperationQueue alloc] init]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // 受け取ったレスポンスから、Cookieを取得します。
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields forURL:response.URL];
        
        // 受け取ったCookieのうち必要なものは、
        // 保存しておくと今後使う時に便利です。
        for (int i = 0; i < cookies.count; i++) {
            NSHTTPCookie *cookie = [cookies objectAtIndex:i];
            //NSLog(@"cookie: name=%@, value=%@", cookie.name, cookie.value);
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;{
    [_dataSource removeAllObjects];
    [_dataSourceUrl removeAllObjects];
    [_dataSourceDetail removeAllObjects];
    [_dataSourcePtid removeAllObjects];
    
    [searchBar resignFirstResponder];
    
    loadPage = 1;
    [self getYamaDataPage:loadPage];
    [_tableView reloadData];
    
    // 結果がない場合はアラート
    if (maxFlg) {
        [self showNotFoundAlert];
    }
}

#pragma mark - AreaTableViewDelegate
- (void)childViewDidChanged:(AreaTableViewController*)viewController :(NSIndexPath *)indexPath{
    // エリアが選択されたら再検索する
    
    //_btnArea.titleLabel.text = [viewController.dataSource objectAtIndex:indexPath.row];
    [_btnArea setTitle:[viewController.dataSource objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    _areaId = [viewController.dataSourceId objectAtIndex:indexPath.row];
    
    [_dataSource removeAllObjects];
    [_dataSourceUrl removeAllObjects];
    [_dataSourceDetail removeAllObjects];
    [_dataSourcePtid removeAllObjects];
    //[_searchBar resignFirstResponder];
    
    loadPage = 1;
    [self getYamaDataPage:loadPage];
    [_tableView reloadData];
    
    // 結果がなかったらアラートを表示
    if (maxFlg) {
        [self showNotFoundAlert];
    }
}
-(void)showNotFoundAlert {
    // アラートの作成と設定
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"山検索"
                                                    message:@"見つかりませんでした。条件を変えてください。"
                                                   delegate:self
                                          cancelButtonTitle:@"確認"
                                          otherButtonTitles:nil, nil];
    
    // アラートの表示
    [alert show];
}
-(void)showFaledLoginAlert {
    // アラートの作成と設定
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"ログイン失敗"
                                                    message:@"ログインできませんでした。設定のヤマレコアカウントを確認してください。"
                                                   delegate:self
                                          cancelButtonTitle:@"確認"
                                          otherButtonTitles:nil, nil];
    
    // アラートの表示
    [alert show];
}
- (IBAction)btnClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)searchBarCancelButtonClicked:
(UISearchBar*)searchBar{
    [_searchBar resignFirstResponder];
}

-(BOOL)coreserverLogin:(NSString*)userId pass:(NSString*)password{
    NSString *strUrl = [[NSString stringWithFormat:@"http://nemui666.m50.coreserver.jp/yamareco_map/get_yamareco_json.php"] stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceCharacterSet]];
    NSURL *url = [NSURL URLWithString:strUrl];
    // Mutableなインスタンスを作成し、インスタンスの内容を変更できるようにする
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // MethodにPOSTを指定する。
    request.HTTPMethod = @"POST";
    // 文字列として作成する
    NSString *body = [NSString stringWithFormat:@"uname=%@&pass=%@&op=login",userId,password];
    
    // HTTPBodyには、NSData型で設定する
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    //サーバーとの通信を行う
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    return YES;
   
}
- (void)saveCookie{
    
    // Save the cookies to the user defaults
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:
                           [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData
                                              forKey:@"SavedHTTPCookiesKey"];
    
}
@end
