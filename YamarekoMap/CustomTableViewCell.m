//
//  CustomTableViewCell.m
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/11/03.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnFavorit:(id)sender {
    // デリゲート先がちゃんと「sampleMethod1」というメソッドを持っているか?
    if ([self.delegate respondsToSelector:@selector(favoritClicked:)]) {
        // sampleMethod1を呼び出す
        [self.delegate favoritClicked:self];
    }
}
@end
