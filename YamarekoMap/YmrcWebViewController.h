//
//  YmrcWebViewController.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2015/02/26.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "FileDetailViewController.h"

@interface YmrcWebViewController : UIViewController <UIWebViewDelegate,NSFetchedResultsControllerDelegate>{
    NSString* downloadUrl;
    NSString* downloadTitle;
    NSString* downloadMotoUrl;
    NSString* fileName;
    NSString* ascending;
    NSString* descending;
}
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(strong,nonatomic)NSString *InitialURL;
@property(strong,nonatomic)NSString *totalDate;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnNext;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDownload;

- (IBAction)btnBack:(id)sender;
- (IBAction)btnNext:(id)sender;
- (IBAction)btnDownload:(id)sender;
- (IBAction)btnClose:(id)sender;
@end
