//
//  CommentDetailViewController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "CommentDetailViewController.h"
#import "SharingComment+Helper.h"
#import "UIImage+Calculator.h"
#import "ConversionClass+Helper.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface CommentDetailViewController ()
@end

@implementation CommentDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // disable interaction (just seeing)
    self.commentTextView.editable = NO;
    
    // set data
    self.commentTextView.text      = self.comment.comment;
    self.fromNumberLabel.text      = self.comment.sourceValue;
    self.toNumberLabel.text        = self.comment.convertedValue;
    self.fromMeasureNameLabel.text = self.comment.measureName;
    self.toUnitTitleLabel.text     = self.comment.unitTitle;
    
    if (self.comment.measureName && self.comment.unitTitle) {
        UIImage *measureImage = [UIImage createPlaceHolderImageWithDiagonalText:self.comment.measureName
                                                                         inRect:CGRectMake(0, 0, 60, 60)
                                                                      withColor:[ConversionClass colors][self.comment.conversionClass]];
        [self.conversionMeasureButton setBackgroundImage:measureImage forState:UIControlStateNormal];
        
        UIImage *unitImage = [UIImage createPlaceHolderImageWithDiagonalText:self.comment.unitTitle
                                                                      inRect:CGRectMake(0, 0, 60, 60)
                                                                   withColor:[UIColor lightGrayColor]];
        
        [self.conversionUnitButton setBackgroundImageWithURL:[NSURL URLWithString:self.comment.thumbnailURL]
                                                    forState:UIControlStateNormal
                                            placeholderImage:unitImage];
    }
}

@end
