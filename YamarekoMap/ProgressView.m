//
//  ProgressView.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2015/03/05.
//  Copyright (c) 2015年 SawakiRyusuke. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView

-(id)init {
    
    self = [super init];
    
    self.title = @"一括地図ダウンロード";
    self.message = @"ダウンロード中です。中止する場合はキャンセルを押してください。";
    [self addButtonWithTitle:@"キャンセル"];
    self.cancelButtonIndex = 0;
    
    // バーを貼り付ける
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 60)];
    _progressView = [[UIProgressView alloc] init];
    _progressView.frame = CGRectMake(10, 0, 240, 30);
    [view addSubview:_progressView];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(10, 20, 240, 20);
    //_label.backgroundColor = [UIColor blackColor];
    _label.textColor = [UIColor blackColor];
    //_label.font = [UIFont fontWithName:@"AppleGothic" size:12];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"0/0";
    [view addSubview:_label];
    
    [self setValue:view forKey:@"accessoryView"];
    
    return self;
}
/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
