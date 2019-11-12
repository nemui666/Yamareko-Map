//
//  MountSearchTableViewController.m
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/27.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "MountSearchTableViewController.h"

@interface MountSearchTableViewController ()

@end

@implementation MountSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = [NSMutableArray array];
    _dataSourceUrl = [NSMutableArray array];
    _dataSourceImg = [NSMutableArray array];
    _dataSourceDate = [NSMutableArray array];
    
    loadPage = 1;
    [self getYamaDataPage:loadPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = _segTitle;
}
- (void)viewDidAppear:(BOOL)animated
{
    // 選択状態解除
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
    if (_dataSource.count == 0) {
        [self showNotFoundAlert];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger dataCount;
    
    // テーブルに表示するデータ件数を返す
    switch (section) {
        case 0:
            dataCount = self.dataSource.count;
            break;
        default:
            break;
    }
    return dataCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Cell再利用のためのIdentifier
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // 処理の必要があれば処理を書く
    cell.textLabel.text = [_dataSource objectAtIndex:indexPath.row];
    [cell.detailTextLabel setText:self.dataSourceDate[indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"cell_defualt_img"];
    //[cell layoutSubviews];

    //非同期の読み込み
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    cell.imageView.image = nil;
    dispatch_async(q_global, ^{

        NSURL* url = [NSURL URLWithString:self.dataSourceImg[indexPath.row]];
        NSData* data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_async(q_main, ^{
            cell.imageView.image = image;
            [cell layoutSubviews];
        });
    });

    return cell;
}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld  %ld",indexPath.row ,[_dataSource count]);
    if(indexPath.row >= [_dataSource count]-10 && !loadFlg && !maxFlg) {
        //非同期の読み込み
        loadFlg = YES;
        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t q_main = dispatch_get_main_queue();
        dispatch_async(q_global, ^{
            [self getYamaDataPage:++loadPage];
            dispatch_async(q_main, ^{
                [tableView reloadData];
            });
        });
        loadFlg = NO;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"YamarecoWeb" sender:nil];
   
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"YamarecoWeb"]) {
        YmrcWebViewController* vc = [segue destinationViewController];
        vc.InitialURL = _dataSourceUrl[self.tableView.indexPathForSelectedRow.row];
        vc.totalDate = _dataSourceDate[self.tableView.indexPathForSelectedRow.row];
    }
}

-(void)getYamaDataPage:(NSInteger)page{
    maxFlg = YES;
    
    NSString *strUrl = [[NSString stringWithFormat:@"http://nemui666.m50.coreserver.jp/yamareco_map/get_yamareco_json.php"] stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceCharacterSet]];
    NSURL *url = [NSURL URLWithString:strUrl];
    // Mutableなインスタンスを作成し、インスタンスの内容を変更できるようにする
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // MethodにPOSTを指定する。
    request.HTTPMethod = @"POST";
    NSString *body = [NSString stringWithFormat:@"pnum=%d&ptid=%@&op=get",(int)page,_ptid];
    
    // HTTPBodyには、NSData型で設定する
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    //サーバーとの通信を行う
    NSData *json = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    //JSONをパース
    NSArray *arrayJson = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:nil];

    for (NSArray* line in arrayJson) {
        //NSLog(@"title：%@", [line valueForKeyPath:@"title"]);
        [_dataSource addObject:[line valueForKeyPath:@"title"]];
        [_dataSourceUrl addObject:[line valueForKeyPath:@"url"]];
        [_dataSourceImg addObject:[line valueForKeyPath:@"img"]];
        [_dataSourceDate addObject:[line valueForKeyPath:@"date"]];
        maxFlg = NO;
    }
}
-(void)showNotFoundAlert {
    // アラートの作成と設定
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"検索結果"
                                                    message:@"山行記録がありません。"
                                                   delegate:self
                                          cancelButtonTitle:@"確認"
                                          otherButtonTitles:nil, nil];
    
    // アラートの表示
    [alert show];
}
@end
