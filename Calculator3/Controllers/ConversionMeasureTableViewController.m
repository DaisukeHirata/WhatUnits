//
//  ConversionMeasureTableViewController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ConversionMeasureTableViewController.h"
#import "ConversionMeasure.h"
#import "ConversionClass+Helper.h"
#import "UIImage+Calculator.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ConversionMeasureTableViewController ()

@end


@implementation ConversionMeasureTableViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionMeasure"];
    request.predicate = nil; // all of ConversionMeasures.
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"whichClass.name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    // ToDo !! set this carefully!
    request.fetchLimit = 100;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"whichClass.name"
                                                                                   cacheName:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.selectedMeasure) {
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.selectedMeasure];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionTop];
    }
}

#pragma mark - Navigation

#define UNWIND_SEGUE_IDENTIFIER @"Select Measure"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath* indexPath = nil;
    indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        ConversionMeasure* measure = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (measure) {
            self.selectedMeasure = measure;
        }
    }
}

#pragma mark - Table view data source delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConversionMeasure Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ConversionMeasure *measure = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = measure.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d units", [measure.units count]];
    cell.imageView.image = [UIImage createPlaceHolderImageWithDiagonalText:measure.name
                                                                    inRect:CGRectMake(0, 0, 60, 60)
                                                                 withColor:[ConversionClass colors][measure.whichClass.name]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

// hide section index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

#pragma mark - Action

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}



@end
