//
//  MountSearchTableViewController.h
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/27.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YmrcWebViewController.h"

@interface MountSearchTableViewController : UITableViewController{
    NSInteger loadPage;
    BOOL loadFlg;
    BOOL maxFlg;
}
@property (nonatomic, strong) NSString *segTitle;
@property (nonatomic, strong) NSString *ptid;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *dataSourceUrl;
@property (nonatomic, strong) NSMutableArray *dataSourceImg;
@property (nonatomic, strong) NSMutableArray *dataSourceDate;
@end
