//
//  GPXFile.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2015/03/03.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GPXFile : NSManagedObject

@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * first_flag;
@property (nonatomic, retain) NSNumber * import;
@property (nonatomic, retain) NSString * moto_url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * regist_dt;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * ascending;
@property (nonatomic, retain) NSString * descending;
@property (nonatomic, retain) NSString * max_altitude;
@property (nonatomic, retain) NSString * min_altitude;
@property (nonatomic, retain) NSString * total_time;

@end
