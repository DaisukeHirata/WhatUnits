//
//  CalculatorViewController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/19.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//
#import "AFHTTPRequestOperationManager.h"
#import "Calculator.h"
#import "CalculatorViewController.h"
#import "ConversionMeasureTableViewController.h"
#import "ConversionUnitTableViewController.h"
#import "ConversionClass+Helper.h"
#import "ConversionMeasure+Helper.h"
#import "ConversionUnit+Helper.h"
#import "ConversionDatabaseAvailability.h"
#import "Converter.h"
#import "OperandOperatorViewCell.h"
#import "ShufflingLabel.h"
#import "UIImage+Calculator.h"
#import "WhatUnitsDidFinishDownloading.h"
#import "WhatUnitsFetchDidCompleteWithError.h"
#import "WhatUnitsAPI.h"
#import "UnitDetailPopoverViewController.h"
#import "FPPopoverController.h"
#import "DisplayFormatter.h"
#import "OperandAState.h"
#import "OperandBState.h"
#import "ResultState.h"
#import <SDWebImage/UIButton+WebCache.h>



@interface CalculatorViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) Calculator *brain;                    // a key press based calculator engine.
@property (nonatomic, strong) Converter *converter;                 // a unit converter
@property (nonatomic, strong, readwrite) ConversionMeasure *conversionMeasure; // selected conversion measure currently
                                                                    // (first it's on the left hand side)
@property (nonatomic, strong, readwrite) ConversionUnit *conversionUnit;       // selected conversion unit currently
                                                                    // (first it's on the right hand side)
@property (weak, nonatomic, readwrite) IBOutlet UILabel *display;
@property (weak, nonatomic, readwrite) IBOutlet ShufflingLabel *conversionDisplay;
@property (weak, nonatomic) IBOutlet UILabel *operatorDisplay;
@property (weak, nonatomic) IBOutlet UIButton *conversionMeasureButton;
@property (weak, nonatomic) IBOutlet UIButton *conversionUnitButton;
@property (weak, nonatomic) IBOutlet UILabel *conversionUnitLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *operandOperator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) DisplayFormatter *formatter;
@end

@implementation CalculatorViewController

#pragma mark - View Controller Lifecycle

- (void)awakeFromNib
{
    // tune in a managed object context notification radio station at very first.
    // when database context is ready, then fetch conversion units data from a server,
    // after fetching finished , set property.
    [[NSNotificationCenter defaultCenter]
        addObserverForName:ConversionDatabaseAvailabilityNotification
                    object:nil
                     queue:nil
                usingBlock:^(NSNotification *note) {
                    
                    NSLog(@"Database Ready");
                    self.managedObjectContext = note.userInfo[ConversionDatabaseAvailabilityContext];
                    [self fetchConversionUnits];
                }];

    
    
    /* for background task
    // tune in whatunits background fetching did finished notification radio station at very first.
    [[NSNotificationCenter defaultCenter] addObserverForName:WhatUnitsDidFinishDownloadingNotification
                                  object:nil
                                   queue:nil
                              usingBlock:^(NSNotification *note) {
                                  NSLog(@"Background fetching finished");
                                  // if ConversionMeasure not selected yet, then set it.
                                  if (self.managedObjectContext && !self.conversionMeasure) {
                                      self.conversionMeasure =
                                        [ConversionMeasure firstObjectInManagedObjectContext:self.managedObjectContext];
                                  }
                              }];
    */
    
}


const double TAB_BAR_ANIMATION_DURATION = 0.1f;
const double TAB_BAR_HEIGHT = 49.f;
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // add tap gesture to conversion display to switch display notation(format)
    self.conversionDisplay.userInteractionEnabled = YES;
    UITapGestureRecognizer *conversionDisplayTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapConversionDisplay:)];
    [self.conversionDisplay addGestureRecognizer:conversionDisplayTapGesture];
    
    // add tap gesture to conversion display to switch display notation(format)
    self.conversionUnitLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *conversionUnitLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapConversionUnitLabel:)];
    [self.conversionUnitLabel addGestureRecognizer:conversionUnitLabelTapGesture];
    
    
    // hide tabBar for an animation of it.
    self.tabBarController.tabBar.hidden = YES;
    for (UIView *view in self.tabBarController.view.subviews) {
        if ([view isKindOfClass:[UITabBar class]]) {
            [view setFrame:CGRectMake(view.frame.origin.x,
                                      view.frame.origin.y+TAB_BAR_HEIGHT,
                                      view.frame.size.width,
                                      view.frame.size.height)];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // hide navbar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // fetch data
    [self fetchConversionUnits];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // hide tabbar
    if (!self.tabBarController.tabBar.hidden) [self hideTabBar:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        if ([[[segue destinationViewController] topViewController] isKindOfClass:[ConversionMeasureTableViewController class]]) {
            ConversionMeasureTableViewController *conversionMeasureTVC =
                    (ConversionMeasureTableViewController *)[[segue destinationViewController] topViewController];
            conversionMeasureTVC.managedObjectContext = self.managedObjectContext;
            conversionMeasureTVC.selectedMeasure = self.conversionMeasure;
        } else if ([[[segue destinationViewController] topViewController] isKindOfClass:[ConversionUnitTableViewController class]]) {
            // set selecting measure, a next table view controller will show the units inside this measure.
            ConversionUnitTableViewController *conversionUnitTVC =
                    (ConversionUnitTableViewController *)[[segue destinationViewController] topViewController];
            conversionUnitTVC.selectingMeasure = self.conversionMeasure;
            conversionUnitTVC.selectedUnit = self.conversionUnit;
            conversionUnitTVC.managedObjectContext = self.managedObjectContext;
        }
    } else {
        NSLog(@"unexpected segue happend!");
    }
}

#define SEGUE_IDENTIFIER_SELECT_UNIT @"Select Unit"
#define SEGUE_IDENTIFIER_SELECT_MEASURE @"Select Measure"

// brefore a segue, this method check wether the segue can be happened or not.
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:SEGUE_IDENTIFIER_SELECT_MEASURE]) {
        if (!self.conversionMeasure) {
            [self alert:@"Sorry, WhatUnits data loading is not complete yet. make sure network connecting."];
            return NO;
        } else {
            return YES;
        }
    } else if ([identifier isEqualToString:SEGUE_IDENTIFIER_SELECT_UNIT]) {
        /*
        if (!self.conversionMeasure) {
            [self alert:@"Choose a base measure first."];
            return NO;
        } else {
            return YES;
        }
         */
        return YES;
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

// unwind action back from modal view (ConversionMeasureTableViewController)
- (IBAction)selectedMeasure:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[ConversionMeasureTableViewController class]]) {
        ConversionMeasureTableViewController *conversionMeasureTVC = (ConversionMeasureTableViewController *)segue.sourceViewController;
        ConversionMeasure *selectedMeasure = conversionMeasureTVC.selectedMeasure;
        if (selectedMeasure) {
            self.conversionMeasure = selectedMeasure;
        } else {
            NSLog(@"ConversionMeasureTableViewController unexpectedly did not select a unit!");
        }
    }
}

// unwind action back from modal view (ConversionUnitTableViewController)
- (IBAction)selectedUnit:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[ConversionUnitTableViewController class]]) {
        ConversionUnitTableViewController *conversionUnitTVC = (ConversionUnitTableViewController *)segue.sourceViewController;
        ConversionUnit *selectedUnit = conversionUnitTVC.selectedUnit;
        if (selectedUnit) {
            self.conversionUnit = selectedUnit;
        } else {
            NSLog(@"ConversionUnitTableViewController unexpectedly did not select a unit!");
        }
    }
}

#pragma mark - UICollectionViewDataSource delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [[Calculator operandOperatorStrings] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Operand Operand Cell";
    OperandOperatorViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.operandOperatorLabel.text= [Calculator operandOperatorStrings][indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize screenSize = self.view.bounds.size;
    if(screenSize.width == 320.0 && screenSize.height == 568.0) {
        // 4inch
        return CGSizeMake(80, 80);
    } else {
        // 3.5inch
        return CGSizeMake(80, 62.5);
    }
}

//
// tap operator or operand cell view
//
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // get input and put it into calculator.
    NSString *input = [Calculator operandOperatorStrings][indexPath.row];
    if ([input isEqualToString:@"Tab"]) {
        [self showTabBar];
    } else {
        [self.brain input:input];
    }
    
    // update UI
    [self updateUIWithInput:input];
}

#pragma mark - Getters and Setters

- (Calculator *)brain
{
    // lazy instantiation
    if (!_brain) _brain = [[Calculator alloc] init];
    return _brain;
}

- (Converter *)converter
{
    // lazy instantiation
    if (!_converter) _converter = [[Converter alloc] init];
    return _converter;
}

- (void)setConversionUnit:(ConversionUnit *)conversionUnit
{
    if (conversionUnit) {
        _conversionUnit = conversionUnit;
        
        // sync converter unit
        self.converter.unit =conversionUnit;
        
        // sync conversionUnitButton image
        UIImage *image = [UIImage createPlaceHolderImageWithDiagonalText:conversionUnit.title
                                                                  inRect:CGRectMake(0, 0, 60, 60)
                                                               withColor:[UIColor lightGrayColor]];
        
        [self.conversionUnitButton setBackgroundImageWithURL:[NSURL URLWithString:conversionUnit.thumbnailURL]
                                                    forState:UIControlStateNormal
                                            placeholderImage:image];
        
        // update conversion display
        self.conversionDisplay.text = [self.converter convertAnswer:[self.brain newConversionDisplayString]];
        
        
        // sync conversionUnitLabel
        self.conversionUnitLabel.text = conversionUnit.title;
    }
}

- (void)setConversionMeasure:(ConversionMeasure *)conversionMeasure
{
    if (conversionMeasure) {
        _conversionMeasure = conversionMeasure;
        // sync converter measure
        self.converter.measure = conversionMeasure;
        
        // sync conversionMeasureButton image
        UIImage *image = [UIImage createPlaceHolderImageWithDiagonalText:conversionMeasure.name
                                                                  inRect:CGRectMake(0, 0, 60, 60)
                                                               withColor:[ConversionClass colors][conversionMeasure.whichClass.name]];
        [self.conversionMeasureButton setBackgroundImage:image forState:UIControlStateNormal];
        
        // whenever measure changed, sync unit too!
        self.conversionUnit = [ConversionUnit firstObjectByConversionMeasure:_conversionMeasure
                                                   InManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - Action

- (void)tapConversionDisplay:(UITapGestureRecognizer *)sender
{
    // switch notation of conversion display
    self.converter.scientificNotationMode = !self.converter.scientificNotationMode;
    self.conversionDisplay.text = [self.converter convertAnswer:[self.brain newConversionDisplayString]];
}

- (void)tapConversionUnitLabel:(UITapGestureRecognizer *)sender
{
    UnitDetailPopoverViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"UnitDetailPopoverViewController"];
    controller.detailString = [NSString stringWithFormat:@"%@ = %@ %@", self.conversionUnit.title, self.conversionUnit.value, self.conversionUnit.whichMeasure.name ];
    //our popover
    FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:controller];
    popover.border = NO;
    popover.tint = FPPopoverWhiteTint;
    popover.contentSize = CGSizeMake(240, 80);
    
    //the popover will be presented from the okButton view
    [popover presentPopoverFromView:self.conversionUnitLabel];
}

#pragma mark - update calculation display

- (void)updateUIWithInput:(NSString *)input
{
    // 1. main display
    if ([self.brain.state isKindOfClass:[OperandAState class]] ||
        [self.brain.state isKindOfClass:[OperandBState class]] )    {
        // when inputting operand, then format number.
        NSNumber *dispNumber  = @([[self.brain newDisplayString] doubleValue]);
        self.display.text     = [self.formatter.inDecimal stringFromNumber:dispNumber];
    } else {
        self.display.text     = [self.brain newDisplayString];
    }
    
    
    // 2. operator display
    self.operatorDisplay.text   = [self.brain operatorDisplayValue];
    
    
    // 3. conversion display
    if ([self.brain.state isKindOfClass:[ResultState class]]) {
        // with shuffling animation
        NSString *convertedString = [self.converter convertAnswer:[self.brain newConversionDisplayString]];
        [self.conversionDisplay setTextWithShufflingAnimation:convertedString];
    } else if ( [input isEqualToString:@"C"] ) {
        self.conversionDisplay.text = @"0";
    }
    
    // 4. automatically hide tab bar if it's shown
    if (!self.tabBarController.tabBar.hidden && ![input isEqualToString:@"Tab"]) [self hideTabBar:YES];
}

#pragma mark - update tabbar

- (void)showTabBar
{
    if (self.tabBarController.tabBar.hidden)
        [self hideTabBar:NO];
    else
        [self hideTabBar:YES];
}

- (void)hideTabBar:(BOOL)hide
{
    // upward direction
    double height = TAB_BAR_HEIGHT;
    
    if (!hide) {
        // downward direction
        height *= -1;
        self.tabBarController.tabBar.hidden = NO;
    }
    
    [UIView animateWithDuration:TAB_BAR_ANIMATION_DURATION
                     animations:^{
                         for (UIView *view in self.tabBarController.view.subviews) {
                             if ([view isKindOfClass:[UITabBar class]]) {
                                 [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+height, view.frame.size.width, view.frame.size.height)];
                             }
                             else {
                                 [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height+height)];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         if (hide) self.tabBarController.tabBar.hidden = YES;
                     }
     ];
}

#pragma mark - fetch units
- (void) fetchConversionUnits
{
    if (self.managedObjectContext) {
        // fetch
        [WhatUnitsAPI getConversionUnitsIntoManagedObjectContext:self.managedObjectContext
                                                         success:^(){
                                                             
                                                             NSLog(@"success");
                                                             if (self.managedObjectContext && !self.conversionMeasure) {
                                                                 // get data from database, then set property.
                                                                 self.conversionMeasure =
                                                                 [ConversionMeasure firstObjectInManagedObjectContext:self.managedObjectContext];
                                                             }
                                                             
                                                         }
                                                         failure:^(){
                                                             
                                                             NSLog(@"Sorry, could not connect to server.");
                                                             [self alert:@"Sorry, could not connect to server."];
                                                             
                                                         }];
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

#pragma mark - formatter
- (DisplayFormatter *)formatter
{
    // lazy instantiation
    if (!_formatter) _formatter = [[DisplayFormatter alloc] init];
    return _formatter;
}

@end
