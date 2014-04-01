//
//  BaseShareCommentViewController.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseShareCommentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *fromNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *toNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *conversionMeasureButton;
@property (weak, nonatomic) IBOutlet UIButton *conversionUnitButton;
@property (weak, nonatomic) IBOutlet UILabel *fromMeasureNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *toUnitTitleLabel;
@end
