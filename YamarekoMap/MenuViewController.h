//
//  TableViewController.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/30.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPXFile.h"

@interface MenuViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *swTime;
@property (weak, nonatomic) IBOutlet UISwitch *swDistance;
@property (weak, nonatomic) IBOutlet UISwitch *swMaxMin;
@property (weak, nonatomic) IBOutlet UISwitch *swStEd;
@property (nonatomic, strong)GPXFile* gpxFile;

- (IBAction)swStEd:(id)sender;
- (IBAction)swMaxMin:(id)sender;
- (IBAction)swDistance:(id)sender;
- (IBAction)swTime:(id)sender;
- (IBAction)btnMotoWeb:(id)sender;
- (IBAction)btnAnotherMap:(id)sender;
- (IBAction)btnManualDownload:(id)sender;
- (IBAction)btnback:(id)sender;
- (IBAction)autoDownload:(id)sender;

@end
