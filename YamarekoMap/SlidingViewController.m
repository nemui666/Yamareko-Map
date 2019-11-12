//
//  SlidingViewController.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/30.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import "SlidingViewController.h"
#import "FileDetailViewController.h"
#import "MenuViewController.h"
@interface SlidingViewController ()

@end

@implementation SlidingViewController

- (void)viewDidLoad {
    
    // Do any additional setup after loading the view.
    /*
    // ストーリーボードを取得
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // topViewControllerにFirstViewControllerを指定する
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"First"];
    self.underRightViewController  = [storyboard instantiateViewControllerWithIdentifier:@"Menu"];
     */
    /*
    FileDetailViewController *fileDetailViewController = [[FileDetailViewController alloc]init];
    MenuViewController *menuViewController = [[MenuViewController alloc]init];
    self.topViewController = fileDetailViewController;
    self.underRightViewController = menuViewController;
    */
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // topViewControllerにFirstViewControllerを指定する
    FileDetailViewController *fileDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"First"];
    fileDetailViewController.gpxFile = _gpxFile;
    
    MenuViewController *menuViewController = [storyboard instantiateViewControllerWithIdentifier:@"Menu"];
     menuViewController.gpxFile = _gpxFile;
    
    
    self.topViewController = fileDetailViewController;
    self.underLeftViewController = menuViewController;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
