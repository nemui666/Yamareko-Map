//
//  SlidingViewController.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/10/30.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "GPXFile.h"

@interface SlidingViewController : ECSlidingViewController
@property(nonatomic,strong)GPXFile* gpxFile;
@end
