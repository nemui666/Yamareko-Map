//
//  ZoomLevelView.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2015/03/06.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomLevelView : UIAlertView
@property(nonatomic,strong)UISlider *zoomLevelSlider;
@property(nonatomic,strong)UILabel* label;
@property(nonatomic,strong)UILabel* label2;
@end
