//
//  App_Resources.h
//  EnergyHunters
//
//  Created by Aapbd on 4/30/14.
//  Copyright (c) 2014 Advanced Apps Bangladesh Limited - AAPBD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
//#import "MyLocationManager.h"
//#import "MyWebServiceManager.h"

//#import "Mod_UserInfo.h"


#pragma mark - Detecting Device for compatibility |###################
#define IS_ONE_DEVICE_MODE NO//YES//NO

#define IS_SIMULATOR            ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone Simulator" ] )
//#define IS_IPHONE               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE               ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
#define IS_IPOD                 ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
//#define IS_IPAD                 ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPad" ] )
#define IS_IPAD                 ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#define IS_IPHONE_4INCHES       ( ( [[UIScreen mainScreen] bounds].size.height == 568 ) )

#define IOS_VERSION             [[[UIDevice currentDevice] systemVersion] floatValue]

#pragma mark - Dynamic Log for debug mode |###################
#ifdef DEBUG
#define DebugLog(s, ...) NSLog(s, ##__VA_ARGS__)
#else
#define DebugLog(s, ...)
#endif





#pragma mark - AppDelegate Object |###################
#define AppDelegateObject (AppDelegate*)[[UIApplication sharedApplication] delegate]

#define AppsBlueColor [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue_bg.png"]] //[AppResources colorWithHexString:@"0097C9"]

#define RadioStreamingURL @"http://192.240.102.3:8912/"//@"http://192.240.97.69:8937"

#pragma mark - App Specific String Messages |###################
#define ErrorText @"Error"
#define WarningText @"Warning"
#define MessageText @"Message"

#define CameraNotAvailableText @"Camera not found in this device! Camera is not available, not supported in this device or there is a problem with camera."
#define ImageCaptureSuccessText @"Image capture success. Now app is scanning the QR code..."
#define ImageCaptureFailedText @"Image capture canceled."
#define EmptyFieldText @"Empty fields are not allowed."
#define InvalidEmailAddressText @"Email address entered is not valid."
#define PasswordsDontMatchText @"Retyped password is not same."
#define DataFetchFromInternetFailedForConnectionText @"Fetching data from internet can not be performed. Please, check the internet connection, network setting and try again."
#define DataFetchFromInternetFailedForInternalProblemText @"Fetching data from internet can not be performed due to internal problem or given login credentials do not match."
#define NODataFoundForURLText @"No data is found for this request."



#pragma mark - App Specific String Components |###################
#define TEST_Driver_ID @"admin"
#define TEST_Driver_PIN @"admin"

#define SelectedJobID 4
#define BadgeValue 13
#define StatusInfoArray @[ @{@"statusMsg":@"JOB STARTED", @"statusImg":@"bar_jobStarteda.png", @"btnText":@"ARRIVED", @"btnImg":@"btn_arriveda.png"}, @{@"statusMsg":@"JOB ARRIVED", @"statusImg":@"bar_arriveda.png", @"btnText":@"POB", @"btnImg":@"btn_poba.png"}, @{@"statusMsg":@"JOB POB", @"statusImg":@"bar_poba.png", @"btnText":@"NEAR FINISH", @"btnImg":@"btn_nearFishera.png"}, @{@"statusMsg":@"JOB NEAR FINISH", @"statusImg":@"bar_currentstatusa.png", @"btnText":@"FINISH", @"btnImg":@"btn_finisha.png"} ]
#define FinishedJobID 5
#define DemoUserID 21






@interface AppResources : NSObject

#pragma mark - Function Declaration |###################


+(id) sharedInstance;

+ (void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message;
+ (NSString*) getProperNameAccordingToScreen:(NSString*)name;
+ (NSString*) getProperXibNameAccordingToScreen:(NSString*)xibName;
+ (NSString*) getProperStoryBoardNameAccordingToScreen:(NSString*)storyBoardName;

// VarArgs that needs NIL at the end like array
//+ (NSArray *)arrayWithObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;

+ (BOOL) isEmptyString:(int) count, ...NS_REQUIRES_NIL_TERMINATION;
+ (BOOL) isValidEmail:(NSString *)checkString;

+(NSString*) timeDifference:(NSDate *)fromDate ToDate:(NSDate *)toDate;
+(NSArray*) getPartsFromAFloatValue:(float) value;

+(void) changeTextAttributeForLabel:(UILabel*) _label andText:(NSString*) text andSeperatorText:(NSString*) sepText withFonts:(NSArray*) fontsArr andColors:(NSArray*) colorsArr;
+(NSString*) convertDateToString:(NSDate*) myDate;
+(NSDate*) convertStringToDate:(NSString*) myDateStr;

+(void) setData:(id)dataValue toUserDefaultForKey:(NSString*) dataKey;
+(id) getDataFromUserDefaultForKey:(NSString*) dataKey;

+(UIColor*)colorWithHexString:(NSString*)hex;

+(BOOL) isURL:(NSString*)urlStr containsMedia:(int) mediaType;//////image,audio,video


@end
