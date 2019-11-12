//
//  CustomTableViewCell.h
//  YamarekoMap
//
//  Created by SawakiRyusuke on 2014/11/03.
//  Copyright (c) 2014年 SawakiRyusuke. All rights reserved.
//

#import <UIKit/UIKit.h>

// デリゲートを定義
@protocol CustomCellDelegate <NSObject>

// デリゲートメソッドを宣言
// （宣言だけしておいて，実装はデリゲート先でしてもらう）
- (void)favoritClicked:(id)customCell;

@end

@interface CustomTableViewCell : UITableViewCell
@property (nonatomic, assign) id<CustomCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *favorit;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIImageView *imgNewFlag;
- (IBAction)btnFavorit:(id)sender;

@end
