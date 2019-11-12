//
//  AreaTableViewController.h
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/22.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AreaTableViewController;

@protocol AreaTableViewDelegate <NSObject>
- (void)childViewDidChanged:(AreaTableViewController*)viewController :(NSIndexPath *)indexPath;
@end

@interface AreaTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *dataSourceId;
@property(weak, nonatomic) id<AreaTableViewDelegate> delegate;
@end
