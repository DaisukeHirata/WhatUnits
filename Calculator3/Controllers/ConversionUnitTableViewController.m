//
//  ConversionUnitTableViewController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ConversionUnitTableViewController.h"
#import "AddConversionUnitViewController.h"
#import "ConversionClass.h"
#import "ConversionMeasure.h"
#import "ConversionUnit.h"
#import "UIImage+Calculator.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ConversionUnitTableViewController ()

@end

@implementation ConversionUnitTableViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionUnit"];
    request.predicate = [NSPredicate predicateWithFormat:@"whichMeasure.whichClass.name = %@", self.selectingMeasure.whichClass.name];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"whichMeasure.name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    // ToDo !! set this carefully!
    request.fetchLimit = 100;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"whichMeasure.name"
                                                                                   cacheName:nil];
    
    self.navigationItem.title = self.selectingMeasure.whichClass.name;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.selectedUnit) {
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.selectedUnit];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionTop];
    }
}


#pragma mark - Table view data source delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConversionUnit Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ConversionUnit *unit = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = unit.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", unit.value, unit.whichMeasure.name];
    UIImage *image = [UIImage createPlaceHolderImageWithDiagonalText:unit.title
                                                              inRect:CGRectMake(0, 0, 60, 60)
                                                           withColor:[UIColor lightGrayColor]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:unit.thumbnailURL]
                   placeholderImage:image];

    return cell;
}

// hide section index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

#pragma mark - Navigation

#define UNWIND_SEGUE_IDENTIFIER @"Select Unit"
#define DO_ADD_UNIT_SEGUE_IDENTIFIER @"Do Add Unit"
#define DO_EDIT_UNIT_SEGUE_IDENTIFIER @"Do Edit Unit"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath* indexPath = nil;
    indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        
        ConversionUnit* unit = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (unit) {
            self.selectedUnit = unit;
        }
        
    } else if ([segue.identifier isEqualToString:DO_ADD_UNIT_SEGUE_IDENTIFIER]) {
        
        AddConversionUnitViewController *addConversionUnitVC =
            (AddConversionUnitViewController *)segue.destinationViewController;
        addConversionUnitVC.selectingMeasure = self.selectingMeasure;
        addConversionUnitVC.isAddNewUnitMode = YES;
        addConversionUnitVC.managedObjectContext = self.managedObjectContext;
        
    } else if ([segue.identifier isEqualToString:DO_EDIT_UNIT_SEGUE_IDENTIFIER]) {
        
        AddConversionUnitViewController *addConversionUnitVC =
            (AddConversionUnitViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        ConversionUnit *unit = [self.fetchedResultsController objectAtIndexPath:indexPath];
        addConversionUnitVC.selectingMeasure = unit.whichMeasure;
        addConversionUnitVC.addedUnit = unit;
        addConversionUnitVC.isAddNewUnitMode = NO;
        addConversionUnitVC.managedObjectContext = self.managedObjectContext;
        
    } else {
        NSLog(@"bad segue.");
    }
}

- (IBAction)addedUnit:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[AddConversionUnitViewController class]]) {
        // call back when returned from AddConversionUnitViewController
        AddConversionUnitViewController *addConversionUnitVC = (AddConversionUnitViewController *)segue.sourceViewController;
        ConversionUnit *addedUnit = addConversionUnitVC.addedUnit;
        if (addedUnit) {
            // update ui!! behave like entering equal.
            self.selectedUnit = addedUnit;
        } else {
            NSLog(@"AddConversionUnitViewController unexpectedly did not add a unit!");
        }
    }
}

#pragma mark - Action

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
