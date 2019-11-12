//
//  SettingTableViewController.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2015/02/21.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "AppDelegate.h"

@interface SettingTableViewController : UITableViewController<SKProductsRequestDelegate>{
    UIView *shieldView;
    UIAlertView* removeAlert;
    UIAlertView *itemErrAlert;
    BOOL purchasedCompleted;
    SKProductsRequest *myProductRequest; // プロダクト情報リクエスト用
    SKProduct *myProduct;                // 取得したプロダクト情報
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCansel;
@property (weak, nonatomic) IBOutlet UITextField *edtUserId;
@property (weak, nonatomic) IBOutlet UITextField *edtUserPass;
@property (weak, nonatomic) IBOutlet UITableViewCell *celAutoLogin;
@property (weak, nonatomic) IBOutlet UITableViewCell *celRemoveFile;
- (IBAction)btnCansel:(id)sender;
@property (weak, nonatomic) IBOutlet UITableViewCell *celSeigen;
@property (weak, nonatomic) IBOutlet UITableViewCell *celRestore;
@end
