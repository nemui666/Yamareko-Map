//
//  AppDelegate.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/19.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import "AppDelegate.h"
#import "FileViewController.h"
#import "ECSlidingViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _locationManager = [[CLLocationManager alloc]init];
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        // GPSを取得する旨の認証をリクエストする
        [_locationManager requestWhenInUseAuthorization];
    }
    
    // バックグラウンド処理
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
    // 拡張子で処理分岐：zipの場合.
    if( [[url pathExtension] isEqualToString:@"gpx"] ){
        //ダウンロードファイルの保存先
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *cacheDirPath = [array objectAtIndex:0];
        NSString *dirPath = [cacheDirPath stringByAppendingPathComponent:@"gpxfiles"];
        NSString *savePath = [dirPath stringByAppendingPathComponent:[url lastPathComponent]];
        
        NSFileManager* fm	= [NSFileManager defaultManager];
        NSError* error = nil;
        //NSLog(@"%@",savePath);
        //return YES;
        if( [fm moveItemAtPath:[url path] toPath:savePath error:&error] ){
            // ダウンロード元URLを作成
            // ※ヤマレコしか意味はない
            NSRange searchResult = [[url lastPathComponent] rangeOfString:@"-"];
            NSString* strId = [[url lastPathComponent] substringWithRange:NSMakeRange(searchResult.location+1,6)];
            NSString* baseUrl = @"http://www.yamareco.com/modules/jqm/detail.php?did=";
            NSString* motoUrl = [NSString stringWithFormat:@"%@%@",baseUrl,strId];
            //NSLog(@"%@",motoUrl);
            
            // CoreDataに保存
            NSManagedObjectContext *context = [self managedObjectContext];
            NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"GPXFile"
                inManagedObjectContext:context];
            [managedObject setValue:[NSDate date] forKey:@"regist_dt"];
            [managedObject setValue:[url lastPathComponent] forKey:@"name"];
            [managedObject setValue:@"インポートファイル" forKey:@"title"];
            [managedObject setValue:motoUrl forKey:@"moto_url"];
            [managedObject setValue:[[NSNumber alloc] initWithBool:NO] forKey:@"favorite"];
            [managedObject setValue:[[NSNumber alloc] initWithBool:YES] forKey:@"first_flag"];
            [managedObject setValue:[[NSNumber alloc] initWithBool:YES] forKey:@"import"];
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        
    }
    return YES;
}
// バックグラウンド実行の際に呼び出される
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
}
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "jp.nemui.YamarekoMap" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"YamarekoMap" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"YamarekoMap.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark SKPaymentTransactionObserver
/*
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                // NSLog(@"購入処理中");
                // TODO: インジケータなど回して頑張ってる感を出す。
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"購入成功");
                [ud setObject:@"1" forKey:@"KEY_I"];
                //[ud registerDefaults:defaults];
                if ([ud synchronize]) {
                    NSLog(@"%@", @"データの保存に成功しました。");
                }
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:@"Purchased" object:transaction];
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"購入失敗: %@, %@", transaction.transactionIdentifier, transaction.error);
                [queue finishTransaction:transaction];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"Failed" object:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                // リストア処理
                // NSLog(@"以前に購入した機能を復元");
                // TODO: アイテム購入した処理（アップグレード版の機能制限解除処理等）
                [ud setObject:@"1" forKey:@"KEY_I"];
                //[ud registerDefaults:defaults];
                //[defaults setObject:array forKey:@"bookmarks"];
                if ([ud synchronize]) {
                    NSLog(@"%@", @"データの保存に成功しました。");
                }
                [queue finishTransaction:transaction];
                break;
            default:
                [queue finishTransaction:transaction];
                break;
        }
    }
}
#pragma mark SKPaymentQueue
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"リストア失敗:%@", error);
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RestoreFailed" object:queue];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"全てのリストア完了");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RestoreCompleted" object:queue];
}
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"購入処理の終了");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"PurchaseCompleted" object:transactions];
}
*/
// 購入、リストアなどのトランザクションの都度、通知される
- (void)   paymentQueue:(SKPaymentQueue *)queue
    updatedTransactions:(NSArray *)transactions {
    NSLog(@"paymentQueue:updatedTransactions");
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // 購入処理中
            case SKPaymentTransactionStatePurchasing:
            {
                NSLog(@"SKPaymentTransactionStatePurchasing");
                break;
            }
                
                // 購入処理完了
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"SKPaymentTransactionStatePurchased");
                [[NSUserDefaults standardUserDefaults] setBool:YES
                                                        forKey:transaction.payment.productIdentifier];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // 購入処理成功したことを通知する
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Purchased"
                                                                    object:transaction];
                
                [queue finishTransaction:transaction];
                break;
            }
                
                // 購入処理エラー
                // ユーザが購入処理をキャンセルした場合も含む
            case SKPaymentTransactionStateFailed:
            {
                NSLog(@"SKPaymentTransactionStateFailed");
                [queue finishTransaction:transaction];
                
                // エラーメッセージを表示
                NSError *error = transaction.error;
                NSString *errormsg = [NSString stringWithFormat:@"%@ [%ld]", error.localizedDescription, error.code];
                [[[UIAlertView alloc] initWithTitle:@"エラー"
                                            message:errormsg
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                
                // エラーの詳細
                // 支払いがキャンセルされた
                if (transaction.error.code != SKErrorPaymentCancelled) {
                    NSLog(@"SKPaymentTransactionStateFailed - SKErrorPaymentCancelled");
                }
                // 請求先情報の入力画面に移り、購入処理が強制終了した
                else if (transaction.error.code == SKErrorUnknown) {
                    NSLog(@"SKPaymentTransactionStateFailed - SKErrorUnknown");
                }
                // その他エラー
                else {
                    NSLog(@"SKPaymentTransactionStateFailed - error.code:%ld",
                          transaction.error.code);
                }
                
                // 購入処理エラーを通知する
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Failed"
                                                                    object:transaction];
                
                break;
            }
                
            case SKPaymentTransactionStateRestored:
            {
                NSLog(@"SKPaymentTransactionStateRestored");
                // リストア処理完了
                [[NSUserDefaults standardUserDefaults] setBool:YES
                                                        forKey:transaction.payment.productIdentifier];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // リストアが成功したこと（＝購入成功）を通知する
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Restored"
                                                                    object:transaction];
                
                [queue finishTransaction:transaction];
                break;
            }
                
            default:
                break;
        }
    }
}

// 購入処理の終了
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    NSLog(@"paymentQueue:removedTransactions");
    
    // 購入処理が全て成功したことを通知する
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PurchaseCompleted"
                                                        object:transactions];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    // 全てのリストア処理が終了
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
    
    // 全てのリストア処理が終了したことを通知する
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RestoreCompleted"
                                                        object:queue];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    // リストアの失敗
    NSLog(@"restoreCompletedTransactionsFailedWithError %@ [%ld]", error.localizedDescription, error.code);
    
    // リストアが失敗したことを通知する
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RestoreFailed"
                                                        object:error];
}
@end

