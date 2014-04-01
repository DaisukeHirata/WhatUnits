//
//  PickerViewController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/27.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "PickerViewController.h"

@interface PickerViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

// transparent button above a picker
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

// closing view method. invoked when close button pushed
- (IBAction)closePickerView:(id)sender;
@end

@implementation PickerViewController

#pragma mark - ViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set self to PickerView delegate and data source
    self.picker.delegate = self;
    self.picker.dataSource = self;
}

#pragma mark - UIPickerViewDelegate UIPickerViewDataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // invoke delegate method.
    [self.delegate applySelectedString:(self.choices)[row]];
}

// methon specify a row of picker view
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}

// method for setting row number to display
-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.choices count];
}

// method to specify a string to show on the picker
-(NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return (self.choices)[row];
}

#pragma mark - Navigation

// close view when tapped transparent button
- (IBAction)closePickerView:(id)sender {
    [self.delegate closePickerView:self];
}

@end
