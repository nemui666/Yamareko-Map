//
//  ZoomLevelView.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2015/03/06.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "ZoomLevelView.h"

@implementation ZoomLevelView

#pragma mark Initalization and Setup

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"一括地図ダウンロード";
        self.message = @"表示範囲をダウンロードします。一度にダウンロードできるページ数は3000です。";
        [self addButtonWithTitle:@"キャンセル"];
        [self addButtonWithTitle:@"確認"];
        self.cancelButtonIndex = 0;
        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 85)];
        _zoomLevelSlider = [[UISlider alloc] init];
        _zoomLevelSlider.minimumValue = 4;
        _zoomLevelSlider.maximumValue = 18.0;
        _zoomLevelSlider.value = 4;
        _zoomLevelSlider.continuous = NO;
        _zoomLevelSlider.frame = CGRectMake(10, 0, 240, 30);
        [view addSubview:_zoomLevelSlider];
        
        _label = [[UILabel alloc] init];
        _label.frame = CGRectMake(10, 30, 240, 20);
        //_label.backgroundColor = [UIColor blackColor];
        _label.textColor = [UIColor blackColor];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = @"0/3000";
        [view addSubview:_label];
        
        _label2 = [[UILabel alloc] init];
        _label2.frame = CGRectMake(10, 55, 240, 20);
        //_label.backgroundColor = [UIColor blackColor];
        _label2.textColor = [UIColor blackColor];
        _label2.font = [UIFont systemFontOfSize:14];
        _label2.textAlignment = NSTextAlignmentCenter;
        _label2.text = @"0/3000";
        [view addSubview:_label2];
        
        [self setValue:view forKey:@"accessoryView"];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
}
*/
@end
