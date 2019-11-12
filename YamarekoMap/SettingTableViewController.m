//
//  SettingTableViewController.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2015/02/21.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "SettingTableViewController.h"

@interface SettingTableViewController ()

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    
    // 保存されている設定を初期化する
    [defaults setObject:@"" forKey:@"ud_user_id"];
    [ud registerDefaults:defaults];
    _edtUserId.text = [ud objectForKey:@"ud_user_id"];
    
    [defaults setObject:@"" forKey:@"ud_user_pass"];
    [ud registerDefaults:defaults];
    _edtUserPass.text = [ud objectForKey:@"ud_user_pass"];
    
    [defaults setObject:@"1" forKey:@"ud_auto_login"];
    [ud registerDefaults:defaults];
    if([[ud objectForKey:@"ud_auto_login"] isEqualToString:@"1"]){
        _celAutoLogin.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        _celAutoLogin.accessoryType = UITableViewCellAccessoryNone;
    }
    
    purchasedCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:@"jp.nemui666.yamarecomap"];
    if (purchasedCompleted){
        _celSeigen.textLabel.text = @"制限解除（解除済み）";
        [_celSeigen setAccessoryType:UITableViewCellAccessoryNone];
        [_celSeigen setSelectionStyle:UITableViewCellSelectionStyleNone];
        [_celRestore setAccessoryType:UITableViewCellAccessoryNone];
        [_celRestore setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    } else {

        // アプリ内課金プロダクト情報を取得する
        myProduct = nil;
        myProductRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"jp.nemui666.yamarecomap"]];
        myProductRequest.delegate = self;
        [myProductRequest start];
    }
    
    // キャンセルボタン初期化
    _btnCansel.title = @"";
    _btnCansel.enabled = NO;
    
    // フォルダのサイズ取得
    [self getFilseSize];
    
    // UIViewの生成
    shieldView = [[UIView alloc] init];
    shieldView.frame = self.view.bounds;
    shieldView.backgroundColor = [UIColor blackColor];
    shieldView.alpha = 0.5;
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [window addSubview:shieldView];
    //[self.view addSubview:shieldView];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    // 画面の中央に表示するようにframeを変更する
    float w = indicator.frame.size.width;
    float h = indicator.frame.size.height;
    float x = self.view.frame.size.width/2 - w/2;
    float y = self.view.frame.size.height/2 - h/2;
    indicator.frame = CGRectMake(x, y, w, h);
    
    // クルクルと回し始める
    [indicator startAnimating];
    
    // 現在のサブビューとして登録する
    [shieldView addSubview:indicator];
    shieldView.hidden = YES;
    
}
- (void)viewWillAppear:(BOOL)animated {
    // フォルダのサイズ取得
    [self getFilseSize];
    
    // AppDelegateからの購入通知を登録する
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(purchased:)
                                                 name:@"Purchased"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restored:)
                                                 name:@"Restored"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(failed:)
                                                 name:@"Failed"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(purchaseCompleted:)
                                                 name:@"PurchaseCompleted"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restoreCompleted:)
                                                 name:@"RestoreCompleted"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restoreFailed:)
                                                 name:@"RestoreFailed"
                                               object:nil];
}
- (void)viewDidAppear:(BOOL)animated
{
    // 選択状態解除
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // AppDelegateからの、購入通知を解除する
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"Purchased"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"Restored"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"Failed"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PurchaseCompleted"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"RestoreCompleted"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"RestoreFailed"
                                                  object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnCansel:(id)sender {
    [_edtUserId resignFirstResponder];
    [_edtUserPass resignFirstResponder];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _edtUserId.text = [ud objectForKey:@"ud_user_id"];
    _edtUserPass.text = [ud objectForKey:@"ud_user_pass"];
    
}

#pragma mark - Event
-(void)showMail{
    NSString*scheme = [NSString stringWithFormat:@"mailto:nemui666@gmail.com"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
}

/*
-(void)purchased:(NSNotification*)notification {
    // UIの処理を記述
    shieldView.hidden = YES;
    _celSeigen.textLabel.text = @"制限解除（解除済み）";
    [_celSeigen setAccessoryType:UITableViewCellAccessoryNone];
    [_celSeigen setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_celRestore setAccessoryType:UITableViewCellAccessoryNone];
    [_celRestore setSelectionStyle:UITableViewCellSelectionStyleNone];
    purchasedCompleted = YES;
}
-(void)failed:(NSNotification*)notification {
    // UIの処理を記述
    shieldView.hidden = YES;
}
-(void)purchasedCompleted:(NSNotification*)notification {
    // UIの処理を記述
    shieldView.hidden = YES;
    _celSeigen.textLabel.text = @"制限解除（解除済み）";
    [_celSeigen setAccessoryType:UITableViewCellAccessoryNone];
    [_celSeigen setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_celRestore setAccessoryType:UITableViewCellAccessoryNone];
    [_celRestore setSelectionStyle:UITableViewCellSelectionStyleNone];
    purchasedCompleted = YES;
}
-(void)restoreCompleted:(NSNotification*)notification {
    // UIの処理を記述
    shieldView.hidden = YES;
}
-(void)restoreFailed:(NSNotification*)notification {
    // UIの処理を記述
    shieldView.hidden = YES;
}
 */
- (void)purchased:(NSNotification *)notification {
    _celSeigen.textLabel.text = @"制限解除（解除済み）";
    [_celSeigen setAccessoryType:UITableViewCellAccessoryNone];
    [_celSeigen setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_celRestore setAccessoryType:UITableViewCellAccessoryNone];
    [_celRestore setSelectionStyle:UITableViewCellSelectionStyleNone];
    purchasedCompleted = YES;
    // 選択状態解除
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)restored:(NSNotification *)notification {
    _celSeigen.textLabel.text = @"制限解除（解除済み）";
    [_celSeigen setAccessoryType:UITableViewCellAccessoryNone];
    [_celSeigen setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_celRestore setAccessoryType:UITableViewCellAccessoryNone];
    [_celRestore setSelectionStyle:UITableViewCellSelectionStyleNone];
    purchasedCompleted = YES;
    // 選択状態解除
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)failed:(NSNotification *)notification {
    // Indicatorを非表示にする
    [shieldView setHidden:YES];
    // 選択状態解除
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)purchaseCompleted:(NSNotification *)notification {
    // Indicatorを非表示にする
    [shieldView setHidden:YES];
    // 選択状態解除
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)restoreCompleted:(NSNotification *)notification {
    // Indicatorを非表示にする
    [shieldView setHidden:YES];
    // 選択状態解除
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)restoreFailed:(NSNotification *)notification {
    // Indicatorを非表示にする
    [shieldView setHidden:YES];
    // 選択状態解除
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}
#pragma mark - sub
-(void)saveAccount{
    
    NSString *ckAutoLogin = @"0";
    // チェックありの場合
    if (_celAutoLogin.accessoryType == UITableViewCellAccessoryCheckmark) {
        ckAutoLogin = @"1";
    }
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"data.plist"];
    NSArray *array = @[_edtUserId.text, _edtUserPass.text, ckAutoLogin];
    BOOL successful = [array writeToFile:filePath atomically:NO];
    if (successful) {
        NSLog(@"%@", @"データの保存に成功しました。");
    }
    */
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:_edtUserId.text forKey:@"ud_user_id"];
    [ud setObject:_edtUserPass.text forKey:@"ud_user_pass"];
    [ud setObject:ckAutoLogin forKey:@"ud_auto_login"];
}
- (unsigned long long int)folderSize:(NSString *)folderPath {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName]
                                        error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}
-(void)removeMapData{
    // 削除したいパス取得
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"yamareko_map/cache/"];
    
    // ファイルマネージャを作成
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    
    // ファイルを移動
    BOOL result = [fileManager removeItemAtPath:filePath error:&error];
    if (result) {
        NSLog(@"ファイルを削除に成功：%@", filePath);
    } else {
        NSLog(@"ファイルの削除に失敗：%@", error.description);
    }
}
-(void)getFilseSize {
    _celRemoveFile.detailTextLabel.text = @"計算中...";
    
    // フォルダのサイズ取得
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"yamareko_map/cache/"];
    
    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(globalQueue, ^{
        //NSLog(@"total file size: %llu", [self folderSize:filePath]);
        float flFolderSize = [self folderSize:filePath];
        dispatch_async(main, ^{
            if (flFolderSize > 0) {
                _celRemoveFile.detailTextLabel.text = [NSString stringWithFormat:@"%.1fMB利用中",flFolderSize/1000000];
            } else {
                _celRemoveFile.detailTextLabel.text = @"利用なし";
            }
        });
    });
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 2;
    } else if (section == 3) {
        return 2;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // アカウントの選択
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            // 選択されたセルを取得
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                // セルのアクセサリにチェックマークを指定
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            [self saveAccount];
        } else if (indexPath.row == 3) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.yamareco.com/modules/hakusen/register.php"]];
        }
    // データ管理の選択
    } else if (indexPath.section == 1) {
        [self showRemoveAlert];
    // 拡張
    } else if (indexPath.section == 2) {
        // 購入済みじゃない時
        if (!purchasedCompleted) {
            if (indexPath.row == 0) {
                [self startInAppPurchase];
            
            }else if (indexPath.row == 1) {
                [self restoredStart];
            }
        }
    // その他の選択
    } else if (indexPath.section == 3) {
        if (indexPath.row == 1) {
            [self showMail];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Keybord
-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    [self saveAccount];
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField{
    _btnCansel.title = @"キャンセル";
    _btnCansel.enabled = YES;
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField*)textField{
    _btnCansel.title = @"";
    _btnCansel.enabled = NO;
}

#pragma mark - AlertView
-(void)showRemoveAlert {
    // アラートの作成と設定
    removeAlert = [[UIAlertView alloc] initWithTitle:@"確認"
                                                      message:@"全ての地図情報が削除されます。よろしいですか？"
                                                     delegate:self
                                            cancelButtonTitle:@"閉じる"
                                            otherButtonTitles:@"確認", nil];
    
    // アラートの表示
    [removeAlert show];
}
-(void)showRestoreAlert {
    // アラートの作成と設定
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"確認"
                                             message:@"復元が完了しました。"
                                            delegate:self
                                   cancelButtonTitle:@"確認"
                                   otherButtonTitles:nil, nil];
    
    // アラートの表示
    [alert show];
}
-(void)showRestoreErrAlert {
    // アラートの作成と設定
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"確認"
                                                    message:@"復元が失敗しました。"
                                                   delegate:self
                                          cancelButtonTitle:@"確認"
                                          otherButtonTitles:nil, nil];
    
    // アラートの表示
    [alert show];
}
-(void)showSuccessAlert {
    // アラートの作成と設定
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"確認"
                                                    message:@"購入が完了しました。"
                                                   delegate:self
                                          cancelButtonTitle:@"確認"
                                          otherButtonTitles:nil, nil];
    
    // アラートの表示
    [alert show];
}
-(void)showErrorAlert {
    // アラートの作成と設定
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"確認"
                                                    message:@"購入が失敗しました。"
                                                   delegate:self
                                          cancelButtonTitle:@"確認"
                                          otherButtonTitles:nil, nil];
    
    // アラートの表示
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == removeAlert) {
        if (buttonIndex==1) {
            [self removeMapData];
            [self getFilseSize];
        }
    }else if (alertView == itemErrAlert) {
        shieldView.hidden = YES;
    }
    // 選択状態解除
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark - SKProductsRequestDelegate SKPaymentTransactionObserver
// メソッド名は適当に（チェック処理の結果がYESだったらこの処理を呼ぶ）
- (void)startInAppPurchase
{
    /*
    if (![SKPaymentQueue canMakePayments]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"アプリ内課金が制限されています。"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    shieldView.hidden = NO;
    
    SKPayment* payment = [SKPayment paymentWithProduct:myProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
     */
    // 機能制限 - App内の購入　のチェックを行う
    if ([SKPaymentQueue canMakePayments] == NO) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"購入できません"
                                   message:@"App内の購入が機能制限されています"
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // 購入用のペイメントをSKProductから生成する
    SKPayment *payment = [SKPayment paymentWithProduct:myProduct];
    // SKPaymentQueueに追加＝トランザクションが開始される
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    // Indicatorを表示する
    [shieldView setHidden:NO];
}
// リストア開始メソッド
-(void)restoredStart {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    // Indicatorを表示する
    [shieldView setHidden:NO];
}
#pragma mark SKProductsRequestDelegate
/*
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    // アプリ内課金プロダクト取得できない
    if (response == nil) {
        // アラートの表示
    }
    // 無効なアイテムがないかチェック
    for (NSString* identifier in response.invalidProductIdentifiers) {
        NSLog(@"invalidProductIdentifiers: %@", identifier);
    }
    
    
    // 有効なプロダクトを処理する
    for (SKProduct* product in response.products) {
        NSLog(@"Product: %@ %@ %@ %d",product.productIdentifier,product.localizedTitle,product.localizedDescription,(int)[product.price integerValue]);
        myProduct = product;
    }
}
*/
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    // アプリ内課金プロダクトが取得できなかった
    if (response == nil) {
        NSLog(@"didReceiveResponse response == nil");
        // Indicatorを非表示にする
        [shieldView setHidden:YES];
        
        return;
    }
    
    // 確認できなかったidentifierをログに記録
    for (NSString *identifier in response.invalidProductIdentifiers) {
        NSLog(@"invalidProductIdentifiers: %@", identifier);
    }
    
    // アプリ内課金プロダクトを取得
    for (SKProduct *product in response.products) {
        NSLog(@"Product: %@ %@ %@ %d",
              product.productIdentifier,
              product.localizedTitle,
              product.localizedDescription,
              [product.price intValue]);
        
        // ここではアプリ内課金プロダクトが唯一である想定
        myProduct = product;
    }
    
    // 商品情報が1つも取得できなかった
    if (myProduct == nil) {
        NSLog(@"myProduct == nil");
        
        // Indicatorを非表示にする
        [shieldView setHidden:YES];
        
        return;
    }
    
    // ローカライズ後の価格を取得
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:myProduct.priceLocale];
    NSString *localedPrice = [numberFormatter stringFromNumber:myProduct.price];
    
    // 商品情報を表示
    
    // Indicatorを非表示にする
    [shieldView setHidden:YES];
}

@end
