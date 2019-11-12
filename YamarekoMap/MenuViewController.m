//
//  TableViewController.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/30.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import "MenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "FileDetailViewController.h"

@interface MenuViewController ()
@property (nonatomic, strong) FileDetailViewController *fileDetailViewController;
@end

@implementation MenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.fileDetailViewController = (FileDetailViewController *)self.slidingViewController.topViewController;
    
    _swMaxMin.on = [_fileDetailViewController visbibleMaxMin:NO];
    _swDistance.on = [_fileDetailViewController visbibleDistance:NO];
    _swTime.on = [_fileDetailViewController visbibleHour:NO];
    
    self.tableView.allowsSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"aaaa");
}

- (IBAction)swStEd:(id)sender {
    if (_swStEd.on) {
        [_fileDetailViewController visbibleStartEnd:YES];
    } else {
        [_fileDetailViewController visbibleStartEnd:NO];
    }
}

- (IBAction)swMaxMin:(id)sender {
    if (_swMaxMin.on) {
        [_fileDetailViewController visbibleMaxMin:YES];
    } else {
        [_fileDetailViewController visbibleMaxMin:NO];
    }
}

- (IBAction)swDistance:(id)sender {
    if (_swDistance.on) {
        [_fileDetailViewController visbibleDistance:YES];
    } else {
        [_fileDetailViewController visbibleDistance:NO];
    }
}

- (IBAction)swTime:(id)sender {
    if (_swTime.on) {
        [_fileDetailViewController visbibleHour:YES];
    } else {
        [_fileDetailViewController visbibleHour:NO];
    }
}

- (IBAction)btnMotoWeb:(id)sender {
    if ([_gpxFile.import boolValue] == NO) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_gpxFile.moto_url]];
    } else {
        [self showMotoUrlAlert];
    }
}

- (IBAction)btnAnotherMap:(id)sender {
    FileDetailViewController* fileDetailView = (FileDetailViewController*)self.slidingViewController.topViewController;
    
    NSString* openUrl = [NSString stringWithFormat:
                         @"http://maps.apple.com/maps?ll=%f,%f&z=17&q=loc:%f,%f&saddr=loc:%f,%f&daddr=loc:%f,%f",
                         fileDetailView.startCoodinate.latitude,
                         fileDetailView.startCoodinate.longitude,
                         fileDetailView.startCoodinate.latitude,
                         fileDetailView.startCoodinate.longitude,
                         fileDetailView.mapView.userLocation.coordinate.latitude,
                         fileDetailView.mapView.userLocation.coordinate.longitude,
                         fileDetailView.startCoodinate.latitude,
                         fileDetailView.startCoodinate.longitude];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
}

- (IBAction)btnManualDownload:(id)sender {
    [self.slidingViewController resetTopViewAnimated:YES];
    [_fileDetailViewController startManualDownloadMap];
}

- (IBAction)btnback:(id)sender{
    //[self.slidingViewController resetTopViewAnimated:YES];
    [_fileDetailViewController btnBack:self];
}

- (IBAction)autoDownload:(id)sender {
    [self.slidingViewController resetTopViewAnimated:YES];
    [_fileDetailViewController startAutoDownloadMap];
}
#pragma mark - AlertView
-(void)showMotoUrlAlert {
    // アラートの作成と設定
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"情報"
                                                      message:@"インポートファイルは取得サイトを表示できません。"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"OK", nil];
    
    // アラートの表示
    [message show];
}
@end
