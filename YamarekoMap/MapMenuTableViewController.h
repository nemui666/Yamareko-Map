//
//  MapMenuTableViewController.h
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/09.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+ECSlidingViewController.h"
#import "MapViewController.h"

@interface MapMenuTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *sw100meizan;
@property (weak, nonatomic) IBOutlet UISwitch *sw200meizan;
@property (weak, nonatomic) IBOutlet UISwitch *sw300meizan;

- (IBAction)sw100meizan:(id)sender;
- (IBAction)sw200meizan:(id)sender;
- (IBAction)sw300meizan:(id)sender;

- (IBAction)btnAutoDownload:(id)sender;
- (IBAction)btnManualDownload:(id)sender;
@end
