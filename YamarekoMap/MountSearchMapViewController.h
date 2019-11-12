//
//  MountSearchMapViewController.h
//  YamarecoMap
//
//  Created by SawakiRyusuke on 2015/04/24.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "MountSearchTableViewController.h"

@interface MountSearchMapViewController : MapViewController{
    NSMutableArray* anoMountSearch;
    NSString* segueTitle;
    NSString *segueUrl;
    UIView* shieldView;
}
- (IBAction)btnMountSearch:(id)sender;

@end
