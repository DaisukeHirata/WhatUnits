//
//  UnitDetailPopoverViewController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "UnitDetailPopoverViewController.h"

@interface UnitDetailPopoverViewController ()
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation UnitDetailPopoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailLabel.text = self.detailString;
}

@end
