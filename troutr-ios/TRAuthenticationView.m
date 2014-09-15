//
//  TRAuthenticationView.m
//  troutr-ios
//
//  Created by Horace Williams on 9/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRAuthenticationView.h"
#import "Masonry.h"
#import "Masonry/View+MASAdditions.h"

@implementation TRAuthenticationView

- (id)init {
    NSLog(@"auth view init");
    self = [super init];
    if (!self) return nil;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"hihaghofeoghagioagangoianiogna";
    
    UIView *square = [[UIView alloc] init];
    square.backgroundColor = [UIColor redColor];
    
    UIView *superview = self;
    int padding = 30;
    NSLog(@"square class is %@", [square class]);
    [square makeConstraints:^(MASConstraintMaker *make) {
        NSLog(@"hi");
    }];
//    [square mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.greaterThanOrEqualTo(superview.mas_top).offset(padding);
//        make.left.equalTo(superview.mas_left).offset(padding);
//        make.bottom.equalTo(superview.mas_bottom).offset(padding);
//        make.right.equalTo(superview.mas_right).offset(padding);
//    }];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
