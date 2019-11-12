//
//  HellpViewController.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2015/03/01.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "HellpViewController.h"

@interface HellpViewController ()

@end
static NSString * const InitialURL = @"https://docs.google.com/document/d/1A-u925jR7NBDTSl3wGGEfy2QVehPeZ5zeih6zRBX57M/pub";
@implementation HellpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webView.delegate = self;
    
    // 初期サイト
    NSURL *url = [NSURL URLWithString:InitialURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - WebView
// 読み込み後に呼ばれる
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (webView.loading) return; // 複数呼ばれないようにする制御
}
// ページ読込開始時にインジケータをくるくるさせる
-(void)webViewDidStartLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
