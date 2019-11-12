//
//  AreaTableViewController.m
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/22.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "AreaTableViewController.h"

@interface AreaTableViewController ()

@end

@implementation AreaTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _dataSource = [NSMutableArray array];
    _dataSourceId = [NSMutableArray array];
    
    [self getYamaData];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _dataSource.count;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = self.dataSource[indexPath.row];
            
            if([_dataSourceId[indexPath.row] integerValue]%100 == 0){
            cell.backgroundColor = [UIColor colorWithHue:0.61
                                              saturation:0.09
                                              brightness:0.99
                                                   alpha:1.0];
            } else {
                 cell.backgroundColor = [UIColor whiteColor];
            }
            break;
        default:
            break;
    }
    
    return cell;
}
-(void)tableView:
(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( [self.delegate respondsToSelector:@selector(childViewDidChanged::)] ) {
        [self.delegate childViewDidChanged:self :indexPath];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)getYamaData{
    // 送信したいURLを作成する
    NSURL *url = [NSURL URLWithString:@"http://api.yamareco.com/api/v1/getArealist/"];
    // Mutableなインスタンスを作成し、インスタンスの内容を変更できるようにする
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // MethodにPOSTを指定する。
    request.HTTPMethod = @"GET";
    
    //サーバーとの通信を行う
    NSData *json = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //JSONをパース
    NSArray *array = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:nil];
    
    NSArray *arealist = [array valueForKeyPath:@"arealist"];
    
    [_dataSource addObject:@"全エリア"];
    [_dataSourceId addObject:@"0"];
    for (NSArray* line in arealist) {
        //NSLog(@"area：%@　area_id：%@", [line valueForKeyPath:@"area"], [line valueForKeyPath:@"area_id"]);
        [_dataSource addObject:[line valueForKeyPath:@"area"]];
        [_dataSourceId addObject:[line valueForKeyPath:@"area_id"]];
    }
    
    /*
     NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
     if (!connection) {
     NSLog(@"connection error.");
     }
     */
}
@end
