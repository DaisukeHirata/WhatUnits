//
//  WhatUnitsAPI.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "WhatUnitsAPI.h"
#import "WhatUnitsAPIKey.h"
#import "AFHTTPRequestOperationManager.h"
#import "ConversionMeasure.h"
#import "SharingComment+Helper.h"
#import "ConversionUnit+Helper.h"
#import "ConversionMeasure+Helper.h"
#import "ConversionClass+Helper.h"

#define WHATUNITS_SHARING_GET_URL @"http://g1g0.com:8000/whatunits/services/share-comment?format=json&api_key=5f43af52933cf9e81914ca57eaa837e8"
#define WHATUNITS_UNIT_PHOTO_URL @"http://g1g0.com:8000/static/image/%@_%@.%@"
#define WHATUNITS_COMMENT_PHOTO_URL @"http://g1g0.com:8000/static/sharing_image/%@_%@.%@"
#define WHATUNITS_CONVERSION_UNITS_GET_URL @"http://g1g0.com:8000/whatunits/services/rest?method=units.search&extras=original_format,description,date_upload,owner_name,geo"
#define WHATUNITS_CONVERSION_UNITS_POST_URL @"http://g1g0.com:8000/whatunits/services/rest"
#define WHATUNITS_SHARING_POST_URL @"http://g1g0.com:8000/whatunits/services/share-comment"
#define WHATUNITS_RESULTS_COMMENTS @"comments.comment"

@implementation WhatUnitsAPI

+ (NSURL *)URLForQuery:(NSString *)query
{
    query = [NSString stringWithFormat:@"%@&format=json&api_key=%@", query, WhatUnitsAPIKey];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:query];
}

+ (NSURL *)URLforAllConversionUnits
{
    NSURL *url = [self URLForQuery:[NSString stringWithFormat:WHATUNITS_CONVERSION_UNITS_GET_URL]];
    //NSLog(@"%@", url);
    return url;
}

+ (NSString *)urlStringForUnitPhoto:(NSDictionary *)photo format:(WhatUnitsPhotoFormat)format
{
	id photo_id = photo[@"id"];
    
	if (!photo_id) return nil;
    
	NSString *fileType = @"jpg";
	if (format == WhatUnitsPhotoFormatOriginal) fileType = photo[@"originalformat"];
    
    NSString *formatString = @"s";
	switch (format) {
		case WhatUnitsPhotoFormatSquare:    formatString = @"s"; break;
		case WhatUnitsPhotoFormatLarge:     formatString = @"b"; break;
		case WhatUnitsPhotoFormatOriginal:  formatString = @"o"; break;
	}
    
	return [NSString stringWithFormat:WHATUNITS_UNIT_PHOTO_URL, photo_id, formatString, fileType];
}

+ (NSURL *)URLforUnitPhoto:(NSDictionary *)photo format:(WhatUnitsPhotoFormat)format;
{
    return [NSURL URLWithString:[self urlStringForUnitPhoto:photo format:format]];
}

+ (void)uploadConversionUnit:(ConversionUnit *)unit
                     success:(void (^)())success
                     failure:(void (^)())failure
{
    NSURL *thumbnailURL  = [NSURL URLWithString:unit.thumbnailURL];
    NSURL *largeImageURL = [NSURL URLWithString:unit.imageURL];
    // create nsdata from image
    NSData *thumbnailData = [NSData dataWithContentsOfFile:[thumbnailURL path]];
    NSData *largeImageData = [NSData dataWithContentsOfFile:[largeImageURL path]];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    // create NSURLRequest with URL to upload
    NSMutableURLRequest *request =
    [manager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                    URLString:WHATUNITS_CONVERSION_UNITS_POST_URL
                                                   parameters:@{@"title" : unit.title,
                                                                @"description": unit.overview,
                                                                @"value": unit.value,
                                                                @"photo_id": unit.unique,
                                                                @"latitude": unit.latitude,
                                                                @"longitude": unit.longitude,
                                                                @"measure":unit.whichMeasure.name,
                                                                @"classname":unit.whichMeasure.whichClass.name}
                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                        [formData appendPartWithFileData:thumbnailData
                                                                    name:@"thumbnail_image"
                                                                fileName:[NSString stringWithFormat:@"%@_s.jpg", unit.unique]
                                                                mimeType:@"image/jpeg"];
                                        [formData appendPartWithFileData:largeImageData
                                                                    name:@"large_image"
                                                                fileName:[NSString stringWithFormat:@"%@_b.jpg", unit.unique]
                                                                mimeType:@"image/jpeg"];
                                    }
                                                        error:NULL];
    
    
    // create AFHTTPRequestOperation for uploading
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                             // success
                                                                             // convert NSData to NSString
                                                                             NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                                                             NSLog(@"responseStr: %@", responseStr);
                                                                             
                                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                             // error
                                                                             NSLog(@"Error: %@", error);
                                                                         }];
    
    // setting blocks, it's invoked when sending data
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
        NSLog(@"bytesWritten: %@, totalBytesWritten: %@, totalBytesExpectedToWrite: %@, progress: %@",
              @(bytesWritten),
              @(totalBytesWritten),
              @(totalBytesExpectedToWrite),
              @((float)totalBytesWritten / totalBytesExpectedToWrite));
    }];
    
    // start uploading
    [manager.operationQueue addOperation:operation];
}

+ (void)uploadSharingComment:(NSDictionary *)sharingInfo
                     success:(void (^)())success
                     failure:(void (^)())failure
{
    NSData *thumbnailData = UIImageJPEGRepresentation([sharingInfo valueForKey:WHATUNITS_SHARING_THUMBNAIL_IMAGE], 1.0);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    // create NSURLRequest with URL to upload
    NSMutableURLRequest *request =
    [manager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                    URLString:WHATUNITS_SHARING_POST_URL
                                                   parameters: @{WHATUNITS_SHARING_PHOTO_ID: [sharingInfo valueForKeyPath:WHATUNITS_SHARING_PHOTO_ID],
                                                                 WHATUNITS_SHARING_SOURCE_VALUE: [sharingInfo valueForKeyPath:WHATUNITS_SHARING_SOURCE_VALUE],
                                                                 WHATUNITS_SHARING_CONVERTED_VALUE: [sharingInfo valueForKeyPath:WHATUNITS_SHARING_CONVERTED_VALUE],
                                                                 WHATUNITS_SHARING_COMMENT: [sharingInfo valueForKeyPath:WHATUNITS_SHARING_COMMENT],
                                                                 WHATUNITS_SHARING_MEASURE_NAME: [sharingInfo valueForKey:WHATUNITS_SHARING_MEASURE_NAME]}
                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                        [formData appendPartWithFileData:thumbnailData
                                                                    name:WHATUNITS_SHARING_THUMBNAIL_IMAGE
                                                                fileName:[NSString stringWithFormat:@"%@_s.jpg", [sharingInfo valueForKeyPath:WHATUNITS_SHARING_PHOTO_ID]]
                                                                mimeType:WHATUNITS_MIMETYPE];
                                    }
                                                        error:NULL];
    
    // create AFHTTPRequestOperation for uploading
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         // success
                                         // convert NSData to NSString
                                         NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                         NSLog(@"responseStr: %@", responseStr);
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         // error
                                         NSLog(@"Error: %@", error);
                                     }];
    
    // setting blocks, it's invoked when sending data
    [operation setUploadProgressBlock:
     ^(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
         NSLog(@"bytesWritten: %@, totalBytesWritten: %@, totalBytesExpectedToWrite: %@, progress: %@",
               @(bytesWritten),
               @(totalBytesWritten),
               @(totalBytesExpectedToWrite),
               @((float)totalBytesWritten / totalBytesExpectedToWrite));
     }];
    
    
    // start uploading
    [manager.operationQueue addOperation:operation];
}


+ (void)getSharingCommentsIntoManagedObjectContext:(NSManagedObjectContext *)context
                                           success:(void (^)())success
                                           failure:(void (^)())failure
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:WHATUNITS_SHARING_GET_URL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             NSDictionary *json = (NSDictionary *)responseObject;
             NSArray *comments = [json valueForKeyPath:WHATUNITS_RESULTS_COMMENTS];
             [SharingComment loadCommentFromCommentsArray:comments intoManagedObjectContext:context];
             success();
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Error: %@", error);
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             failure();
             
         }];
    
    
}

+ (void)getConversionUnitsIntoManagedObjectContext:(NSManagedObjectContext *)context
                                           success:(void (^)())success
                                           failure:(void (^)())failure
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:WHATUNITS_CONVERSION_UNITS_GET_URL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             NSDictionary *json = (NSDictionary *)responseObject;
             NSArray *units = [json valueForKeyPath:WHATUNITS_RESULTS_UNITS];
             [ConversionUnit loadUnitFromUnitsArray:units intoManagedObjectContext:context];
             success();
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Error: %@", error);
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             failure();
             
         }];
}

+ (NSURL *)URLforCommentPhoto:(NSDictionary *)commentInfo
{
    return [NSURL URLWithString:[self urlStringForCommentPhoto:commentInfo]];
}

+ (NSString *)urlStringForCommentPhoto:(NSDictionary *)photo
{
	id photo_id = photo[@"photo_id"];
	if (!photo_id) return nil;
	NSString *fileType = @"jpg";
	return [NSString stringWithFormat:WHATUNITS_COMMENT_PHOTO_URL, photo_id, @"s", fileType];
}

@end