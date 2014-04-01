//
//  CalculatorAppDelegate.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/19.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "CalculatorAppDelegate.h"
#import "CalculatorAppDelegate+MOC.h"
#import "WhatUnitsAPI.h"
#import "ConversionUnit+Helper.h"
#import "ConversionDatabaseAvailability.h"
#import "WhatUnitsDidFinishDownloading.h"
#import "WhatUnitsFetchDidCompleteWithError.h"

@interface CalculatorAppDelegate() <NSURLSessionDownloadDelegate>
@property (nonatomic, copy) void (^whatUnitsDownloadBackgroundURLSessionCompletionHandler)();
@property (nonatomic, strong) NSURLSession *whatUnitsDownloadSession;
@property (nonatomic, strong) NSTimer *whatUnitsForegroundFetchTImer;
@property (nonatomic, strong) NSManagedObjectContext *conversionDatabaseContext;
@end

// name of the WhatUnits fetching background download session
#define WHATUNITS_FETCH @"WhatUnits Units Fetch"

// how often (in seconds) we fetch new photos if we are in the foreground
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)


@implementation CalculatorAppDelegate

#pragma mark - UIApplicationDelegate

/*
 background fetching not implemented yet
 
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.conversionDatabaseContext = [self createMainQueueManagedObjectContext];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [self startWhatUnitsFetch];
    return YES;
}
 */


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.conversionDatabaseContext = [self createMainQueueManagedObjectContext];
    //[self startWhatUnitsFetch];
    return YES;
}

- (void)setConversionDatabaseContext:(NSManagedObjectContext *)conversionDatabaseContext
{
    _conversionDatabaseContext = conversionDatabaseContext;
  
    /*
    [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL
                                     target:self
                                   selector:NSSelectorFromString(@"startWhatUnitsFetch:")
                                   userInfo:nil
                                    repeats:YES];
     */
 
    // notification
    NSDictionary* userInfo =
        self.conversionDatabaseContext ? @{ ConversionDatabaseAvailabilityContext: self.conversionDatabaseContext } : nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ConversionDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}


// this might not work if we're in the background (discretionary), but that's okay
- (void)startWhatUnitsFetch
{
    // Asynchronously calls a completion callback with all outstanding data,
    // upload, and download tasks in a session.
    [self.whatUnitsDownloadSession getTasksWithCompletionHandler:
         ^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                // create download tasks, and execute it.
                NSURLSessionDownloadTask *task =
                    [self.whatUnitsDownloadSession downloadTaskWithURL:[WhatUnitsAPI URLforAllConversionUnits]];
                task.taskDescription = WHATUNITS_FETCH;
                [task resume];
            } else {
                for (NSURLSessionDownloadTask *task in downloadTasks) {
                    [task resume];
                }
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }];
}


// NSURLSession we will use to fetch WhatUnits data in the background
// NSURLConnection does not support background fetch.
- (NSURLSession *)whatUnitsDownloadSession
{
    // lazy instantiation
    if (!_whatUnitsDownloadSession) {
        // invoke background downloading session only once using GCD(Grand Central Dispatch).
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // url session type is background
            NSURLSessionConfiguration *urlSessionConfig =
                [NSURLSessionConfiguration backgroundSessionConfiguration:WHATUNITS_FETCH];
            // for example, connections should be made over a cellular network.
            urlSessionConfig.allowsCellularAccess = YES;
            // starting off in the background. if they finish while this apllication is no longer running,
            // we want it to launch our application and tell us.
            _whatUnitsDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                      delegate:self
                                                                 delegateQueue:nil];
        });
    }
    return _whatUnitsDownloadSession;
}

- (NSArray *)whatUnitsPhotosAtURL:(NSURL *)url
{
    NSDictionary *whatUnitsPropertyList;
    NSData *whatUnitsJSONData = [NSData dataWithContentsOfURL:url];
    if (whatUnitsJSONData) {
        // JSONdata -> NSDictionary
        whatUnitsPropertyList = [NSJSONSerialization JSONObjectWithData:whatUnitsJSONData
                                                                options:0
                                                                  error:NULL];
    }
    return [whatUnitsPropertyList valueForKeyPath:WHATUNITS_RESULTS_UNITS];
}


#pragma mark - NSURLSessionDownloadDelegate

// required by the protocol
// Tells the delegate that a download task has finished downloading.
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    if ([downloadTask.taskDescription isEqualToString:WHATUNITS_FETCH]) {
        NSManagedObjectContext* context = self.conversionDatabaseContext;
        if (context) {
            // download json data -> NSArray
            NSArray *units = [self whatUnitsPhotosAtURL:localFile];
            // Asynchronous block to prevent thread blocking
            [context performBlock:^{
                // store data to coredata
                [ConversionUnit loadUnitFromUnitsArray:units intoManagedObjectContext:context];
                [context save:NULL];
                [[NSNotificationCenter defaultCenter] postNotificationName:WhatUnitsDidFinishDownloadingNotification
                                                                    object:self
                                                                  userInfo:nil];
            }];
        }
        else {
            [self whatUnitsDownloadTasksMightBeComplete];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error && (session == self.whatUnitsDownloadSession)) {
        NSLog(@"WhatUnits background download session failed: %@", error.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:WhatUnitsFetchDidCompleteWithErrorNotification
                                                            object:self
                                                          userInfo:nil];
        [self whatUnitsDownloadTasksMightBeComplete];
    }
}

- (void)whatUnitsDownloadTasksMightBeComplete
{
    if (self.whatUnitsDownloadBackgroundURLSessionCompletionHandler) {
        // Asynchronously calls a completion callback with all outstanding data,
        // upload, and download tasks in a session.
        [self.whatUnitsDownloadSession getTasksWithCompletionHandler:
            ^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
                if (![downloadTasks count]) {
                    void (^completionHandler)() = self.whatUnitsDownloadBackgroundURLSessionCompletionHandler;
                    self.whatUnitsDownloadBackgroundURLSessionCompletionHandler = nil;
                    if (completionHandler) {
                        completionHandler();
                    }
                }
            }];
    }
}

#pragma background fetch

- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self startWhatUnitsFetch];
    // no data for downloading
    completionHandler(UIBackgroundFetchResultNoData);
}

// this method required for background downloading.
- (void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
   completionHandler:(void (^)())completionHandler
{
    // During downloading tasks are still running in foreground, When press home button,
    // the application goes to background. keep tasks going in background.
    self.whatUnitsDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}
							
@end
