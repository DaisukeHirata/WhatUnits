//
//  PickerViewController.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/27.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerViewControllerDelegate;

@interface PickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

// in
@property (nonatomic, strong) NSArray *choices;                         // PickerView choice items
@property (weak, nonatomic) id<PickerViewControllerDelegate> delegate;

@end

@protocol PickerViewControllerDelegate <NSObject>
// delegate for selecting pickr string
-(void)applySelectedString:(NSString *)str;
// delegate for closing this view
-(void)closePickerView:(PickerViewController *)controller;
@end
