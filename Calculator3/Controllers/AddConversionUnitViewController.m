//
//  AddConversionUnitViewController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/21.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>   // kUTTypeImage
#import <SDWebImage/UIImageView+WebCache.h>
#import "AddConversionUnitViewController.h"
#import "ConversionClass.h"
#import "ConversionMeasure+Helper.h"
#import "ConversionUnit+Helper.h"
#import "UIImage+Calculator.h"                      // thumbnail and filtering methods
#import "WhatUnitsAPI.h"
#import "PickerViewController.h"

@interface AddConversionUnitViewController () <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, PickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *unitTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *overviewTextView;
@property (weak, nonatomic) IBOutlet UIButton *selectMeasureButton;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) NSInteger locationErrorCode;
@property (nonatomic, strong) PickerViewController *pickerViewController;
@end

@implementation AddConversionUnitViewController

#pragma mark - Capabilities

// probably this should be public
// then presenters could check first to see if it's even worth effort
+ (BOOL)canAddUnit
{
    /*
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *avaiableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([avaiableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
                return YES;
            }
        }
    }
     */
    return YES;
    return NO;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[self class] canAddUnit]) {
        [self fatalAlert:@"Sorry, this device cannot add a photo. Because you have no camera."];
    } else {     // should check that location services are enabled first
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // stop updating location happen when we leave heap, but just to be sure ...
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // draw description border.
    self.overviewTextView.layer.borderWidth = 1;
    self.overviewTextView.layer.borderColor = [[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0] CGColor];
    self.overviewTextView.layer.cornerRadius = 5;
    self.overviewTextView.returnKeyType = UIReturnKeyDone;
    self.overviewTextView.delegate = self;
    
    // add tap gesture to conversion display to switch display notation(format)
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhoto)];
    [self.imageView addGestureRecognizer:tapGesture];
    
    if (!self.isAddNewUnitMode) {
        // edit mode.
        self.titleTextField.text   = self.addedUnit.title;
        self.unitTextField.text    = [self.addedUnit.value stringValue];
        self.overviewTextView.text = self.addedUnit.overview;
        UIImage *image = [UIImage createPlaceHolderImageWithDiagonalText:self.addedUnit.title
                                                                  inRect:CGRectMake(0, 0, 60, 60)
                                                               withColor:[UIColor lightGrayColor]];
        [self.imageView setImageWithURL:[NSURL URLWithString:self.addedUnit.imageURL]
                       placeholderImage:image];
    }
    
    // set measure name to picker button title.
    [self.selectMeasureButton setTitle:self.selectingMeasure.name forState:UIControlStateNormal];
    
    
}

#pragma mark - Target/Action

- (IBAction)cancel
{
    // clean up any temporary files by setting nil.
    self.image = nil;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)takePhoto
{
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@""
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Take Photo", @"Select from saved photo alubm", nil];
    [sheet showInView:self.view];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    self.image = image;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextFielddelegete

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // make "return key" hide keyboard
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Action sheet delegate 

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerControllerSourceType sourceType = (UIImagePickerControllerSourceType)NULL;
    UIImagePickerController *imagePickerController;
    
    switch (buttonIndex) {
        case 0:
            // bring up camera
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                sourceType = UIImagePickerControllerSourceTypeCamera;
            } else {
                [self alert:@"Sorry, this device cannot add a photo. Because you have no camera."];
                return;
            }
            break;
        case 1:
            // show camera roll
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            } else {
                [self alert:@"Sorry, this device does not have a photo album."];
                return;
            }
            break;
        default:
            break;
    }
    
    if (sourceType) {
        imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePickerController.sourceType = sourceType;
        imagePickerController.allowsEditing = YES;
        [self presentViewController:imagePickerController animated:YES completion:NULL];
    }
    
}

#pragma mark - Navigation

#define UNWIND_SEGUE_IDENTIFIER @"Do Add Unit"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        
        NSManagedObjectContext *context = self.selectingMeasure.managedObjectContext;
        if (context) {
            ConversionUnit *unit = nil;
            
            NSString *unique = self.isAddNewUnitMode ? [[NSUUID UUID] UUIDString] : self.addedUnit.unique;
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionUnit"];
            request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
            
            NSError *error;
            NSArray *matches = [context executeFetchRequest:request error:&error];
            
            if (!matches || error || ([matches count] > 1)) {
                // error
                unit = nil; // not necessary. it's for readability
            } else if  ([matches count]) {
                // update
                unit = [matches firstObject];
            } else {
                // insert
                unit = [NSEntityDescription insertNewObjectForEntityForName:@"ConversionUnit"
                                                     inManagedObjectContext:context];
            }
            
            if (unit) {
                unit.unique       = self.isAddNewUnitMode ? [[NSUUID UUID] UUIDString] : self.addedUnit.unique;
                unit.title        = self.titleTextField.text;
                unit.overview     = self.overviewTextView.text;
                unit.value        = @([self.unitTextField.text doubleValue]);
                unit.latitude     = @(self.location.coordinate.latitude);
                unit.longitude    = @(self.location.coordinate.longitude);
                if ([[self.image accessibilityIdentifier] isEqualToString:@"AddPhoto"]) {
                    self.image    = [UIImage createPlaceHolderImageWithDiagonalText:unit.title
                                                                              inRect:CGRectMake(0, 0, 60, 60)
                                                                           withColor:[UIColor lightGrayColor]];
                    
                }
                unit.imageURL     = [self.imageURL absoluteString];
                unit.thumbnailURL = [self.thumbnailURL absoluteString];
                unit.uploadDate   = [NSDate date];
                unit.whichMeasure = self.selectingMeasure;
                NSError *error = nil;
                [context save:&error];
                if(error) {
                    [self alert:[NSString stringWithFormat:@"could not save data : %@", error]];
                }

                // upload!!
                [WhatUnitsAPI uploadConversionUnit:unit
                                           success:^{
                                               NSLog(@"success");
                                           }
                                           failure:^{
                                               NSLog(@"failure");
                                               [self alert:@"Sorry, could not connect to server."];
                                           }];
                
                self.addedUnit = unit;
            }
            
            
            self.imageURL = nil;    // this URL has been used now
            self.thumbnailURL = nil;
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        //NSLog(@"%@", [self.imageView accessibilityIdentifier]);
        if (![self.titleTextField.text length]) {
            [self alert:@"Title required!!"];
            return NO;
        } else if (![self.unitTextField.text length]) {
            [self alert:@"Unit required!!"];
            return NO;
        } else {
            return YES;
        }
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

#pragma mark - PickerViewController Delegate

- (IBAction)openSelectMeasurePickerView:(UIButton *)sender {
    // get pickerviewcontroller instance from storyboard
    self.pickerViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"PickerViewController"];
    self.pickerViewController.delegate = self;
    //    self.pickerViewController.choices = [ConversionMeasure measureNameArrayInManagedObjectContext:self.managedObjectContext];
    self.pickerViewController.choices = [ConversionMeasure measureNameArrayByClassName:self.selectingMeasure.whichClass.name inManagedObjectContext:self.managedObjectContext];
    
    // show it with in a mainview
    UIView *pickerView = self.pickerViewController.view;
    CGPoint middleCenter = pickerView.center;
    CGSize offSize = [UIScreen mainScreen].bounds.size;
    CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
    pickerView.center = offScreenCenter;
    [self.view addSubview:pickerView];
    
    // with animation.
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    pickerView.center = middleCenter;
    [UIView commitAnimations];
}

// delegate method when a row is selected
- (void)applySelectedString:(NSString *)str
{
    // set measure name to picker button title.
    [self.selectMeasureButton setTitle:str forState:UIControlStateNormal];
    // sync self.selectingMeasure
    //self.selectingMeasure = [ConversionMeasure searchMeasureByName:str inManagedObjectContext:self.managedObjectContext];
    
    self.selectingMeasure = [ConversionMeasure searchMeasure:str className:self.selectingMeasure.whichClass.name inManagedObjectContext:self.managedObjectContext];
}

// delegate method when a transparent button above PickerVIew
- (void)closePickerView:(PickerViewController *)controller
{
    // close picker view slowly
    UIView *pickerView = controller.view;
    
    // caluculate a location when animation done
    CGSize offSize = [UIScreen mainScreen].bounds.size;
    CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
    
    [UIView beginAnimations:nil context:(void *)pickerView];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    // set selector with animation completion
    [UIView setAnimationDidStopSelector:@selector(pickerViewAnimationDidStop:finished:context:)];
    pickerView.center = offScreenCenter;
    [UIView commitAnimations];
}

- (void)pickerViewAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    // show off picker view
    UIView *pickerView = (__bridge UIView *)context;
    [pickerView removeFromSuperview];
}



#pragma mark - Location

- (CLLocationManager *)locationManager
{
    // lazy instantiation
    if (!_locationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locationErrorCode = error.code;
}

#pragma mark - Image Properties

- (NSURL *)imageURL
{
    if (!_imageURL && self.image) {
        NSURL *url = [self uniqueDocumentURL];
        if (url) {
            // no compression
            NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
            if ([imageData writeToURL:url atomically:YES]) {
                _imageURL = url;
            }
        }
    }
    return _imageURL;
}

- (NSURL *)thumbnailURL
{
    NSURL *url = [self.imageURL URLByAppendingPathExtension:@"thumbnail"];
    if (![_thumbnailURL isEqual:url]) {
        _thumbnailURL = nil;
        if (url) {
            UIImage *thumbnail = [self.image imageByScallingToSize:CGSizeMake(75, 75)];
            NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
            if ([imageData writeToURL:url atomically:YES]) {
                _thumbnailURL = url;
            }
        }
    }
    return _thumbnailURL;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    // when iamge is changed, we must delete files we've created (if any)
    // Never call self.imageURL(getter) here!! Cause it create photo file.
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:_thumbnailURL error:NULL];
    self.imageURL = nil;
    self.thumbnailURL = nil;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (NSURL *)uniqueDocumentURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *path = [paths firstObject];
    NSError *error;
    if (![fileManager fileExistsAtPath:path]) {
        if (![fileManager createDirectoryAtPath:path
                    withIntermediateDirectories:NO
                                     attributes:nil
                                          error:&error]) {
            NSLog(@"Create directory error: %@", error);
        }
    }
    NSArray *documentDirectories = [fileManager URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.0f", floor([NSDate timeIntervalSinceReferenceDate])];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}


#pragma mark - Alerts

- (void)alert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Add Unit"
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)fatalAlert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Add Unit"
                                message:message
                               delegate:self    // we're going to cancel when dismissed
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancel];
}


NSString *path;


@end
