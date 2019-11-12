//
//  MountainSearchViewController.h
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/22.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AreaTableViewController.h"
#import "YmrcWebViewController.h"
#import "MountSearchTableViewController.h"

@interface MountainSearchViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,AreaTableViewDelegate>{
    NSInteger loadPage;
    BOOL loadFlg;
    BOOL maxFlg;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btnArea;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *dataSourceUrl;
@property (nonatomic, strong) NSMutableArray *dataSourceDetail;
@property (nonatomic, strong) NSMutableArray *dataSourcePtid;
@property (nonatomic, strong) NSString *areaId;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnClose;
- (IBAction)btnClose:(id)sender;
@end
