//
//  RecentCommentsTableViewController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/28.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "RecentCommentsTableViewController.h"
#import "WhatUnitsAPI.h"
#import "SharingComment+Helper.h"
#import "UIImage+Calculator.h"
#import "CommentDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RecentCommentsTableViewController ()

@end

@implementation RecentCommentsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // prepare fetchedResultsController
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SharingComment"];
    request.predicate = nil; // all
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uploadDate" ascending:NO]];
    request.fetchLimit = 100;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"uploadDay"
                                                                                   cacheName:nil];
    
    
    // fetch comments from server
    [WhatUnitsAPI getSharingCommentsIntoManagedObjectContext:self.managedObjectContext
                                                     success:^{
                                                         NSLog(@"success");
                                                     }
                                                     failure:^{
                                                         NSLog(@"failure");
                                                         [self alert:@"Sorry, could not connect to server."];
                                                     }];
    
    
}

#pragma mark - Table view data source delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SharingComment Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SharingComment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = comment.comment;
    UIImage *image = [UIImage createPlaceHolderImageWithDiagonalText:comment.unitTitle
                                                              inRect:CGRectMake(0, 0, 60, 60)
                                                           withColor:[UIColor lightGrayColor]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:comment.thumbnailURL]
                   placeholderImage:image];
    
    return cell;
}

// hide section index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath* indexPath = nil;
    indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.destinationViewController isKindOfClass:[CommentDetailViewController class]]) {
        
        CommentDetailViewController *commentDetailVC = (CommentDetailViewController *)segue.destinationViewController;
        SharingComment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (comment) {
            commentDetailVC.comment = comment;
        }
        
    } else {
        NSLog(@"unexpected segue happend!");
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
