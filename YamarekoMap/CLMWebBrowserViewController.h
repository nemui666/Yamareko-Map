//
//  CLMWebBrowserViewController.h
//  WebBrowserSample
//
//  Created by hirai.yuki on 2014/09/06.
//  Copyright (c) 2014年 Classmethod, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "FileDetailViewController.h"

/**
 簡易 Web ブラウザーを表示する ViewController
 */
@interface CLMWebBrowserViewController : UIViewController<WKNavigationDelegate,NSFetchedResultsControllerDelegate>{
    NSString* downloadUrl;
    NSString* downloadTitle;
    NSString* downloadMotoUrl;
    M13ProgressHUD *HUD;
}

@property (strong, nonatomic) WKWebView *webView;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *forwardButton;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopButton;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
/**
 履歴一覧画面で選択された WKBackForwardListItem インスタンスをセットするためのプロパティ
 */
@property (strong, nonatomic) WKBackForwardListItem *backForwardListItem;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *btnDownload;
@property (weak, nonatomic) IBOutlet UIView *infowindowView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;


- (IBAction)didTapBackButton:(id)sender;
- (IBAction)didTapForwardButton:(id)sender;
//- (IBAction)didTapReloadButton:(id)sender;
//- (IBAction)didTapStopButton:(id)sender;
- (IBAction)unwindToWebBrowser:(UIStoryboardSegue *)segue;
- (IBAction)btnDownloadGpx:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnBackHome;
- (IBAction)btnBackHome:(id)sender;
- (IBAction)btnUser:(id)sender;

@end

