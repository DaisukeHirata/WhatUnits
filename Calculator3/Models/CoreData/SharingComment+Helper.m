//
//  SharingComment+Helper.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/28.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "SharingComment.h"
#import "SharingComment+Helper.h"
#import "WhatUnitsAPI.h"

@implementation SharingComment (Helper)

// bulk load api
+ (void)loadCommentFromCommentsArray:(NSArray *)comments // of Comments NSDictionary
            intoManagedObjectContext:(NSManagedObjectContext *)context
{
    // inefficient way . should be improved later
    for (NSDictionary *comment in comments) {
        [self commentWithCommentInfo:comment inManagedObjectContext:context];
    }
    
}

// simple load api
+ (SharingComment *)commentWithCommentInfo:(NSDictionary *)commentDictionary
                    inManagedObjectContext:(NSManagedObjectContext *)context
{
    SharingComment *comment = nil;
    
    NSString *unique = commentDictionary[WHATUNITS_SHARING_COMMENT_ID];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SharingComment"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error here
    } else if  ([matches count]) {
        comment = [matches firstObject];
    } else {
        comment = [NSEntityDescription insertNewObjectForEntityForName:@"SharingComment"
                                                inManagedObjectContext:context];
        
        comment.unique             = unique;
        comment.photoId            = commentDictionary[WHATUNITS_SHARING_PHOTO_ID];
        comment.convertedValue     = commentDictionary[WHATUNITS_SHARING_CONVERTED_VALUE];
        comment.sourceValue        = commentDictionary[WHATUNITS_SHARING_SOURCE_VALUE];
        comment.unitTitle          = commentDictionary[WHATUNITS_SHARING_UNIT_TITLE];
        comment.measureName        = commentDictionary[WHATUNITS_SHARING_MEASURE_NAME];
        comment.conversionClass    = commentDictionary[WHATUNITS_SHARING_CLASS_NAME];
        comment.comment            = commentDictionary[WHATUNITS_SHARING_COMMENT];
        comment.thumbnailURL       = [[WhatUnitsAPI URLforCommentPhoto:commentDictionary] absoluteString];
        NSTimeInterval interval    = [commentDictionary[WHATUNITS_SHARING_UPLOAD_DATE] doubleValue];
        comment.uploadDate         = [NSDate dateWithTimeIntervalSince1970:interval];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle        = NSDateFormatterFullStyle;
        comment.uploadDay          = [formatter stringFromDate:comment.uploadDate];
        NSLog(@"%@ %@", comment.uploadDate, [formatter stringFromDate:comment.uploadDate]);
        
        NSError *error = nil;
        [context save:&error];
        if(error){
            NSLog(@"could not save data : %@", error);
        }
    }
    
    return comment;
}

@end
