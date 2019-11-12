//
//  FileViewController.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/19.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomTableViewCell.h"
@interface FileViewController : UITableViewController<NSFetchedResultsControllerDelegate,CustomCellDelegate,UIActionSheetDelegate>
{
    NSArray* fileList;
    NSIndexPath* updateIndex;
    NSString* updateURL;
}
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)btnSegueWebView:(id)sender;

@end
