//
//  App_Resources.m
//  EnergyHunters
//
//  Created by Aapbd on 4/30/14.
//  Copyright (c) 2014 Advanced Apps Bangladesh Limited - AAPBD. All rights reserved.
//

#import "AppResources.h"

@implementation AppResources


+(id) sharedInstance
{
    AppResources *appResObj = [[AppResources alloc] init];
    
    if ([super init])
    {
        //
    }
    
    return appResObj;
}

+(void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message
{
    if (!title)
    {
        title = @"Message";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}


+ (NSString*) getProperNameAccordingToScreen:(NSString*)name
{
    NSString *newName = name;
    
    if (IS_IPHONE)
    {
        if (IS_IPHONE_4INCHES)
            newName = [newName stringByAppendingString:@""];
        else
            newName = [newName stringByAppendingString:@"_iPhone"];
    }
    else
    {
        newName = [newName stringByAppendingString:@"_iPad"];
    }
    
    
    //////// For tesing in one for all device mode
    if (IS_ONE_DEVICE_MODE)
    {
        newName = name;
    }
    
    
    return newName;
}

+ (NSString*) getProperXibNameAccordingToScreen:(NSString*)xibName
{
    NSString *newXibName = xibName;
    
    if (IS_IPHONE)
    {
        if (IS_IPHONE_4INCHES)
            newXibName = [newXibName stringByAppendingString:@""];
        else
            newXibName = [newXibName stringByAppendingString:@"_iPhone"];
    }
    else
    {
        newXibName = [newXibName stringByAppendingString:@"_iPad"];
    }
    
    
    return newXibName;
}



+ (NSString*) getProperStoryBoardNameAccordingToScreen:(NSString*)storyBoardName
{
    NSString *newStoryBoardName = storyBoardName;
    
    if (IS_IPHONE)
    {
        if (IS_IPHONE_4INCHES)
        {
//            newStoryBoardName = [newStoryBoardName stringByAppendingString:@"-4-inches"];
            newStoryBoardName = [newStoryBoardName stringByAppendingString:@""];
        }
        else
        {
            if (IS_IPOD)
            {
//                newStoryBoardName = [newStoryBoardName stringByAppendingString:@""];
                newStoryBoardName = [newStoryBoardName stringByAppendingString:@"-3.5-inches"];
            }
            else
            {
//                newStoryBoardName = [newStoryBoardName stringByAppendingString:@""];
                newStoryBoardName = [newStoryBoardName stringByAppendingString:@"-3.5-inches"];
            }
        }
    }
    else if (IS_IPAD)
    {
        newStoryBoardName = [newStoryBoardName stringByAppendingString:@"-iPad"];
    }
    else if(IS_SIMULATOR)
    {
        newStoryBoardName = [newStoryBoardName stringByAppendingString:@""];
    }
    else
    {
        newStoryBoardName = [newStoryBoardName stringByAppendingString:@""];
    }
    
    
    
    //////// For tesing in one for all device mode
    if (IS_ONE_DEVICE_MODE)
    {
        newStoryBoardName = storyBoardName;
    }
    
    
    return newStoryBoardName;
}


+ (BOOL) isEmptyString:(int) count, ...
{
    BOOL isEmpty = NO;
    
    va_list args;
    va_start(args, count);
    
    NSString *checkString;
    
    for( int i = 0; i < count; i++ )
    {
        checkString = va_arg(args, NSString *);
        
        if (!checkString)
        {
            isEmpty = YES;
            break;
        }
        
        
        if ([checkString length]==0)
        {
            isEmpty = YES;
            break;
        }
    }
    
    va_end(args);
    
    return isEmpty;
}


+ (BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


+ (NSString*) timeDifference:(NSDate *)startDate ToDate:(NSDate *)endDate
{
    NSString *timeDiff = @"0 Mins";
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *calendarComps = [calendar components:unitFlags fromDate:startDate  toDate:endDate  options:0];
    
    if ([calendarComps day]>=0 && [calendarComps hour]>=0 && [calendarComps minute]>=0)
    {
//        timeDiff = [NSString stringWithFormat:@"%0i Days %0i Hours %0i Minutes", [calendarComps day], [calendarComps hour], [calendarComps minute]];
        timeDiff = @"";
        BOOL isPrevAdded = NO;
        
        if ([calendarComps day]>0)
        {
            timeDiff = [timeDiff stringByAppendingFormat:@"%i Days", [calendarComps day]];
            
            isPrevAdded = YES;
        }
        
        if ([calendarComps hour]>0)
        {
            if (isPrevAdded)
            {
                timeDiff = [timeDiff stringByAppendingString:@" "];
            }
            timeDiff = [timeDiff stringByAppendingFormat:@"%02i Hours", [calendarComps hour]];
            
            isPrevAdded = YES;
        }
        
        if ([calendarComps minute]>0)
        {
            if (isPrevAdded)
            {
                timeDiff = [timeDiff stringByAppendingString:@" "];
            }
            timeDiff = [timeDiff stringByAppendingFormat:@"%02i Minutes", [calendarComps minute]];
        }
    }
    
    return timeDiff;
}


+(NSArray*) getPartsFromAFloatValue:(float) value
{
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    
    [mArr addObject:[NSNumber numberWithInt:((int)value)]];
    [mArr addObject:[NSNumber numberWithInt:((int)(100* (value-((float) (int)value))))]];
    
    return [mArr copy];
}


+(void) changeTextAttributeForLabel:(UILabel*) _label andText:(NSString*) text andSeperatorText:(NSString*) sepText withFonts:(NSArray*) fontsArr andColors:(NSArray*) colorsArr;
{
    NSString *tit2Str = text;
    NSString *tm = [text lowercaseString];
    
    int index = [tm rangeOfString:sepText].location;
    tm = [tm substringToIndex:(index)];
    
    tit2Str = [text lowercaseString];
    
    NSRange newRange = [tit2Str rangeOfString:tm];
    DebugLog(@"Range--> %@=%@ || %@", tit2Str, tm, NSStringFromRange(newRange));
    
    
    if ([_label respondsToSelector:@selector(setAttributedText:)])
    {
        
        // iOS6 and above : Use NSAttributedStrings
        
        UIFont *boldFont = nil;
        UIFont *regularFont = nil;
        UIColor *foregroundColorBold = nil;
        UIColor *foregroundColor = nil;
        
        if (!fontsArr)
        {
            const CGFloat fontSize = 11.0f;
            boldFont = [UIFont boldSystemFontOfSize:fontSize];
            regularFont = [UIFont systemFontOfSize:fontSize];
        }
        else
        {
            boldFont = (UIFont*)[fontsArr objectAtIndex:0];
            regularFont = (UIFont*)[fontsArr objectAtIndex:1];
        }
        
        
        if (!colorsArr)
        {
            foregroundColorBold = [UIColor colorWithRed:30.0/255.0 green:40.0/255.0 blue:50.0/255.0 alpha:1.0];
            foregroundColor = [UIColor colorWithRed:50/255.0 green:60/255.0 blue:70/255.0 alpha:1.0];
        }
        else
        {
            foregroundColorBold = (UIColor*)[colorsArr objectAtIndex:0];
            foregroundColor = (UIColor*)[colorsArr objectAtIndex:1];
        }
        
        // Create the attributes
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, foregroundColorBold, NSForegroundColorAttributeName, nil];
        //NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: foregroundColor, NSForegroundColorAttributeName, nil];
        
        //NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys: regularFont, NSFontAttributeName, foregroundRedolor, NSForegroundColorAttributeName, nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys: regularFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
        //NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:foregroundRedolor, NSForegroundColorAttributeName, nil];
        const NSRange range = newRange; // range of " 2012/10/14 ". Ideally this should not be hardcoded
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:subAttrs];
        [attributedText setAttributes:attrs range:range];
        
        // Set it in our UILabel and we are done!
        [_label setAttributedText:attributedText];
        
        _label.shadowColor = [UIColor clearColor];
    }
    else
    {
        // iOS5 and below
        // Here we have some options too. The first one is to do something
        // less fancy and show it just as plain text without attributes.
        // The second is to use CoreText and get similar results with a bit
        // more of code. Interested people please look down the old answer.
        
        // Now I am just being lazy so :p
        [_label setText:text];
        
    }
}


+(NSString*) convertDateToString:(NSDate*) myDate
{
    NSString *dateStr = @"";
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMM yyyy*hh:mm a";
    
    dateStr = [dateFormatter stringFromDate:myDate];
    
    return dateStr;
}


+(NSDate*) convertStringToDate:(NSString*) myDateStr
{
    NSDate *myDate = nil;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"dd MMM yyyy*hh:mm a";
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    myDate = [dateFormatter dateFromString:myDateStr];
    
    return myDate;
}


+(void) setData:(id)dataValue toUserDefaultForKey:(NSString *)dataKey
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    if ([dataValue isKindOfClass:[NSObject class]])
    {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataValue];
            [userDef setObject:data forKey:dataKey];
    }
    else
    {
        [userDef setObject:dataValue forKey:dataKey];
    }
    [userDef synchronize];
}


+(id) getDataFromUserDefaultForKey:(NSString *)dataKey
{
    id dataValue = [[NSObject alloc] init];
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    if ([userDef valueForKey:dataKey])
    {
        if ([dataValue isKindOfClass:[NSObject class]])
        {
            NSData *data = [userDef objectForKey:dataKey];
            dataValue = (NSObject*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        else
        {
            dataValue = [userDef objectForKey:dataKey];
        }
    }
    else
    {
        dataValue = nil;
    }
    
    return dataValue;
}



//////////////////////
+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}


+(BOOL) isURL:(NSString*)urlStr containsMedia:(int) mediaType//////image=1,audio=2,video=3
{
    BOOL isContain = NO;
    
    if ([urlStr hasSuffix:@".jpg"] || [urlStr hasSuffix:@".jpeg"] || [urlStr hasSuffix:@".JPG"] || [urlStr hasSuffix:@".JPEG"] || [urlStr hasSuffix:@".png"] || [urlStr hasSuffix:@".PNG"] || [urlStr hasSuffix:@".img"] || [urlStr hasSuffix:@".IMG"] || [urlStr hasSuffix:@".image"] || [urlStr hasSuffix:@".IMAGE"] || [urlStr hasSuffix:@".tiff"] || [urlStr hasSuffix:@".TIFF"])
    {
        ;
    }
    
    return isContain;
}



@end
