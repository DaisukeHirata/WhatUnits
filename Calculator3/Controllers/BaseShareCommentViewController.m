//
//  BaseShareCommentViewController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "BaseShareCommentViewController.h"

@interface BaseShareCommentViewController () <UITextViewDelegate>

@end

@implementation BaseShareCommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // draw bottom border
    CALayer* fromlayer = [self.fromNumberLabel layer];
    CALayer *fromBottomBorder = [CALayer layer];
    fromBottomBorder.borderWidth = 1;
    fromBottomBorder.borderColor = [[UIColor lightGrayColor] CGColor];
    fromBottomBorder.frame = CGRectMake(-1, fromlayer.frame.size.height-1,fromlayer.frame.size.width+3, 1);
    [fromlayer addSublayer:fromBottomBorder];
    
    // draw bottom border
    CALayer* tolayer = [self.toNumberLabel layer];
    CALayer *toBottomBorder = [CALayer layer];
    toBottomBorder.borderWidth = 1;
    toBottomBorder.borderColor = [[UIColor lightGrayColor] CGColor];
    toBottomBorder.frame = CGRectMake(-1, tolayer.frame.size.height-1, tolayer.frame.size.width+3, 1);
    [tolayer addSublayer:toBottomBorder];
    
    // draw bottom border
    CALayer *fromLabellayer = [self.fromMeasureNameLabel layer];
    CALayer *fromLabelBorder = [CALayer layer];
    fromLabelBorder.borderWidth = 1;
    fromLabelBorder.borderColor = [[UIColor lightGrayColor] CGColor];
    fromLabelBorder.frame = CGRectMake(-1, fromLabellayer.frame.size.height-1, tolayer.frame.size.width, 1);
    [fromLabellayer addSublayer:fromLabelBorder];
    
    // draw bottom border
    CALayer *toLabellayer = [self.toUnitTitleLabel layer];
    CALayer *toLabelBorder = [CALayer layer];
    toLabelBorder.borderWidth = 1;
    toLabelBorder.borderColor = [[UIColor lightGrayColor] CGColor];
    toLabelBorder.frame = CGRectMake(-1, toLabellayer.frame.size.height-1, tolayer.frame.size.width, 1);
    [toLabellayer addSublayer:toLabelBorder];
    
    // clip comment text border.
    self.commentTextView.layer.borderWidth  = 0;
    self.commentTextView.layer.cornerRadius = 5;
}

@end
