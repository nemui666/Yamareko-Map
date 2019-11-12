//
//  FileViewController.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/19.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import "FileViewController.h"
#import "FileDetailViewController.h"
#import "SlidingViewController.h"
#import "GPXFile.h"

@interface FileViewController ()

@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;

    self.editButtonItem.title = @"編集";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    // セルが作成されていないか?
    // Configure the cell...
    cell.textLabel.text = [fileList objectAtIndex:indexPath.row];
    */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    // テーブルの設定
    [self configureCell:cell atIndexPath:indexPath];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    //ボタンが押されたときの処理イベントをボタンに登録する。
    [button addTarget:self
               action:@selector(pressAccessaryAddButton:event:)
     forControlEvents:UIControlEventTouchUpInside];
    //アクセサリービューに作成したボタンをセット
    cell.accessoryView = button;
    /*
    UIImage *image = [UIImage imageNamed:@"forward"];
    cell.imageView.image = image;
    */
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // ファイルから削除
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSError *error = nil;
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *cacheDirPath = [array objectAtIndex:0];
        NSString *filePath = [cacheDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"gpxfiles/%@",[object valueForKey:@"name"]]];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error != nil) {
            NSLog(@"File Delete Error %@, %@ %@", error, [error userInfo],[object valueForKey:@"name"]);
        }
        // DBから削除
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"segueWebViewController"]){
        //WebViewController* vc = [segue destinationViewController];
        //vc.managedObjectContext = _managedObjectContext;
    }
    else if ([segue.identifier isEqualToString:@"segueSlidingViewController"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GPXFile *gpxFile = [self.fetchedResultsController objectAtIndexPath:indexPath];
        SlidingViewController* vc = [segue destinationViewController];
        vc.gpxFile = gpxFile;
        gpxFile.first_flag = [[NSNumber alloc] initWithBool:NO];
        
        // Save the context.
        NSError *error = nil;
        if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"「%@」が選択されました", [fileList objectAtIndex:indexPath.row]);
    //[self performSegueWithIdentifier:@"segueFileDetailViewController" sender:self];
    [self performSegueWithIdentifier:@"segueSlidingViewController" sender:self];
}
- (IBAction)btnSegueWebView:(id)sender {
    [self performSegueWithIdentifier:@"segueWebViewController" sender:self];
    //[self performSegueWithIdentifier:@"segueWebSlidingViewController" sender:self];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GPXFile" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = @[
                    [[NSSortDescriptor alloc] initWithKey:@"favorite" ascending:NO],
                    [[NSSortDescriptor alloc] initWithKey:@"first_flag" ascending:NO],
                    [[NSSortDescriptor alloc] initWithKey:@"regist_dt" ascending:NO]];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *customCell = (CustomTableViewCell*)cell;
    customCell.delegate = self;
    
    GPXFile *gpxFile = [self.fetchedResultsController objectAtIndexPath:indexPath];
    customCell.title.text = [gpxFile.title description];
    
    if (gpxFile.total_time == nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        NSDate *date= [formatter dateFromString:[gpxFile.regist_dt description]];
        [formatter setDateFormat:@"yyyy-MM-dd(E) HH:mm:ss"];
        NSString *result = [formatter stringFromDate:date];
        //cell.detailTextLabel.text = result;
        customCell.date.text = [NSString stringWithFormat:@"取得日：%@",result ];
    } else {
        customCell.date.text = [NSString stringWithFormat:@"日程：%@",gpxFile.total_time ];
    }
    
    // お気に入りボタンセット
    //[btn setTag:BTN];
    if ([gpxFile.favorite boolValue]) {
        [customCell.favorit setImage:[UIImage imageNamed:@"tbl_favorite_on"] forState:UIControlStateNormal];
    } else {
        [customCell.favorit setImage:[UIImage imageNamed:@"tbl_favorite_off"] forState:UIControlStateNormal];
        //customCell.favorit.titleLabel.text = @"⭐︎";
    }
    
    if ([gpxFile.first_flag boolValue]) {
        customCell.imgNewFlag.image = [UIImage imageNamed:@"tbl_new"];
    } else {
        customCell.imgNewFlag.image = nil;
    }
    /*
    [button addTarget:self action:@selector(onCellButtonPushed:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button];
     */
}

- (void)pressAccessaryAddButton:(id)sender event:(id)event{
    // タッチされた場所を探す
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    updateIndex = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    
    // 登録情報を取得する
    GPXFile *gpxFile = [[self fetchedResultsController] objectAtIndexPath:updateIndex];
    updateURL = gpxFile.moto_url;
    
    //NSLog(@"%d",indexPath.row);
    // alertを表示
    [self showInfoActionSheet:gpxFile.title];
    
}

#pragma mark - CustomCellDelegate
- (void)favoritClicked :(id)_customCell{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:_customCell];
    CustomTableViewCell* customCell = _customCell;
    //NSLog(@"%ld",(long)indexPath.row);
    if (indexPath != nil) {
        GPXFile *gpxFile = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        if ([gpxFile.favorite boolValue]) {
            gpxFile.favorite = [[NSNumber alloc] initWithBool:NO];
            [customCell.favorit setImage:[UIImage imageNamed:@"tbl_favorite_off"] forState:UIControlStateNormal];
        } else {
            gpxFile.favorite = [[NSNumber alloc] initWithBool:YES];
            [customCell.favorit setImage:[UIImage imageNamed:@"tbl_favorite_on"] forState:UIControlStateNormal];
        }
        
        // Save the context.
        NSError *error = nil;
        if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
#pragma mark - editButtonItem
-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:YES];
    
    if(editing){
        self.editButtonItem.title = @"完了";
    }else{
        self.editButtonItem.title = @"編集";
    }
}
#pragma mark - AlertView
-(void)showFileNameAlert:(NSString*)fileName{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"タイトル編集"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"閉じる"
                                            otherButtonTitles:@"変更", nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];//１行で実装
    UITextField *textField = [message textFieldAtIndex:0];
    textField.text = fileName;
    [message show];
}
-(void)showMotoURLAlert:(NSString*)motoURL{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"取得サイトURL編集"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"閉じる"
                                            otherButtonTitles:@"変更", nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];//１行で実装
    UITextField *textField = [message textFieldAtIndex:0];
    textField.text = motoURL;
    [message show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"タイトル編集"]) {
        if (buttonIndex==1) {
            // 変更されたテキスト取得
            NSString* result = [[alertView textFieldAtIndex:0] text];
            // ブランクは登録しない
            if ([result isEqualToString:@""]) return;
            GPXFile *gpxFile = [[self fetchedResultsController] objectAtIndexPath:updateIndex];
            gpxFile.title = result;
        
            // Save the context.
            NSError *error = nil;
            if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    } else if ([alertView.title isEqualToString:@"取得サイトURL編集"]) {
        if (buttonIndex==1) {
            // 変更されたテキスト取得
            NSString* result = [[alertView textFieldAtIndex:0] text];
            // ブランクは登録しない
            if ([result isEqualToString:@""]) return;
            GPXFile *gpxFile = [[self fetchedResultsController] objectAtIndexPath:updateIndex];
            gpxFile.moto_url = result;
            
            // Save the context.
            NSError *error = nil;
            if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}
#pragma mark - ActionSheet
-(void)showInfoActionSheet:(NSString*)title{
    // アクションシート例文
    UIActionSheet *as = [[UIActionSheet alloc] init];
    as.delegate = self;
    as.title = title;
    [as addButtonWithTitle:@"タイトル編集"];
    //[as addButtonWithTitle:@"取得サイトURL編集"];
    [as addButtonWithTitle:@"キャンセル"];
    as.cancelButtonIndex = 1;
    //as.destructiveButtonIndex = 2;
    [as showInView:self.view];  // ※下記参照
}
-(void)actionSheet:(UIActionSheet*)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self showFileNameAlert:actionSheet.title];
            break;
        case 1:
            break;
        case 2:
            break;
    }
}
@end
