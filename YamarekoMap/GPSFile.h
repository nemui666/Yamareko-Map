//
//  GPSFile.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/12/28.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GPSFile : NSManagedObject

@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * first_flag;
@property (nonatomic, retain) NSString * moto_url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSDate * regist_dt;

@end
