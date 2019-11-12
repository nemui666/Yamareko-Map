//
//  MapViewSlidingViewController.m
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/08.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "MapViewSlidingViewController.h"

@interface MapViewSlidingViewController ()

@end

@implementation MapViewSlidingViewController

- (void)viewDidLoad {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // topViewControllerにFirstViewControllerを指定する
    MapViewController *fileDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"MapViewFirst"];
    
    MenuViewController *menuViewController = [storyboard instantiateViewControllerWithIdentifier:@"MapViewMenu"];
    
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
