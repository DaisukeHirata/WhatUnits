//
//  ShareViewController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/28.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ConversionClass+Helper.h"
#import "ConversionMeasure+Helper.h"
#import "ConversionUnit+Helper.h"
#import "ShareViewController.h"
#import "UIImage+Calculator.h"
#import "WhatUnitsAPI.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface ShareViewController () <UITextViewDelegate>
@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // for UITextViewDelegate
    self.commentTextView.returnKeyType = UIReturnKeyDone;
    self.commentTextView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.conversionMeasure && self.conversionUnit) {
        UIImage *measureImage = [UIImage createPlaceHolderImageWithDiagonalText:self.conversionMeasure.name
                                                                  inRect:CGRectMake(0, 0, 60, 60)
                                                               withColor:[ConversionClass colors][self.conversionMeasure.whichClass.name]];
        [self.conversionMeasureButton setBackgroundImage:measureImage forState:UIControlStateNormal];
        
        UIImage *unitImage = [UIImage createPlaceHolderImageWithDiagonalText:self.conversionUnit.title
                                                                  inRect:CGRectMake(0, 0, 60, 60)
                                                               withColor:[UIColor lightGrayColor]];
    
        [self.conversionUnitButton setBackgroundImageWithURL:[NSURL URLWithString:self.conversionUnit.thumbnailURL]
                                                    forState:UIControlStateNormal
                                            placeholderImage:unitImage];
    }
    
    // set data
    self.fromNumberLabel.text      = self.sourceValueString;
    self.toNumberLabel.text        = self.convertedValueString;
    self.commentTextView.text      = @"";
    self.fromMeasureNameLabel.text = self.conversionMeasure.name;
    self.toUnitTitleLabel.text     = self.conversionUnit.title;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Target Action

- (IBAction)uploadComment:(UIButton *)sender {
    //UIImage *image = self.myButton.currentBackgroundImage;
    if ([self.commentTextView.text length]) {
        
        NSDictionary *commentInfo = @{WHATUNITS_SHARING_THUMBNAIL_IMAGE: self.conversionUnitButton.currentBackgroundImage,
                                      WHATUNITS_SHARING_PHOTO_ID: self.conversionUnit.unique,
                                      WHATUNITS_SHARING_SOURCE_VALUE: self.fromNumberLabel.text,
                                      WHATUNITS_SHARING_CONVERTED_VALUE: self.toNumberLabel.text,
                                      WHATUNITS_SHARING_COMMENT: self.commentTextView.text,
                                      WHATUNITS_SHARING_MEASURE_NAME: self.conversionMeasure.name};
        
        [WhatUnitsAPI uploadSharingComment:commentInfo
                                   success:^{
                                       NSLog(@"success");
                                   }
                                   failure:^{
                                       NSLog(@"failure");
                                       [self alert:@"Sorry, could not connect to server."];
                                   }];
        
        
        // go to calculation view
        self.tabBarController.selectedIndex = 0;
    
    } else {
        [self alert:@"Comment required."];
    }
}

#pragma mark - Alerts

- (void)alert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

@end
