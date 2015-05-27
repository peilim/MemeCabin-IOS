//
//  MenuView.m
//  test
//
//  Created by AAPBD Mac mini on 10/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

//TEST

#import "MenuView.h"
#import "MKStoreKit.h"
#import "SVProgressHUD.h"

@implementation MenuView
{
    NSMutableArray *tableDataForFree;
    NSMutableArray *tableDataForPro;
}

@synthesize purchaseCode;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:[AppResources getProperXibNameAccordingToScreen:@"MenuView"] owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UIView class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
        if([self daysRemainingOnSubscription:[[NSUserDefaults standardUserDefaults] objectForKey:PURCHASE_DATE]]== 0)
        {
            [UIAppDelegate removeProUser];
        }
        
        
        //if (![UIAppDelegate isProUser])
        //{
            tableDataForFree = [[NSMutableArray alloc] initWithObjects:
                         @"Rate this App! (5 stars I Hope!)",
                         @"Disable Ads",
                         @"Meme Cabin on Facebook",
                         @"Get The Humaning App",
                         @"Single Dad Laughing on Facebook",
                         @"Single Dad Laughing on Instagram",
                         @"LOGOUT",nil];
        //}
        //else
        //{
            tableDataForPro = [[NSMutableArray alloc] initWithObjects:
                                @"Rate this App! (5 stars I Hope!)",
                                @"Meme Cabin on Facebook",
                                @"Get The Humaning App",
                                @"Single Dad Laughing on Facebook",
                                @"Single Dad Laughing on Instagram",
                                @"LOGOUT",nil];
        //}
        
        _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED])
        {
            if ([UIAppDelegate isProUser])
            {
                [tableDataForPro replaceObjectAtIndex:[tableDataForPro count]-1 withObject:@"LOGIN"];
            }
            else
            {
                [tableDataForFree replaceObjectAtIndex:[tableDataForFree count]-1 withObject:@"LOGIN"];
            }
            
        }
        
        vc = (UIViewController *)[UIAppDelegate.navigationController.viewControllers lastObject];
        NSLog(@"vc = %@",vc);
        
    }
    return self;
}

-(int)daysRemainingOnSubscription:(NSString*)dateString
{
    NSDateFormatter *dateformatter = [NSDateFormatter new];
    [dateformatter setDateFormat:@"dd-MM-yyyy"];
    
    //NSDate * expiryDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"PurchaseExpirationDate"];
    NSDate * expiryDate = [dateformatter dateFromString:dateString];
    
    
    NSTimeInterval timeInt = [[dateformatter dateFromString:[dateformatter stringFromDate:expiryDate]] timeIntervalSinceDate: [dateformatter dateFromString:[dateformatter stringFromDate:[NSDate date]]]]; //Is this too complex and messy?
    int days = timeInt / 60 / 60 / 24;
    
    if (days >= 0) {
        return days;
    } else {
        return 0;
    }
}

#pragma mark - Table Delegate START

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UIAppDelegate isProUser])
    {
        return tableDataForPro.count;
    }
    else
    {
        return tableDataForFree.count;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    UIImage *imgBackGround = [UIImage imageNamed: (indexPath.row%2==0)?@"menu_btn1.png":@"menu_btn2.png"];
    
    UIView *cellView = [[UIView alloc] initWithFrame:cell.frame];
    [cellView setBackgroundColor:[UIColor colorWithPatternImage:imgBackGround]];
    cell.backgroundView = cellView;
    /*
    if (indexPath.row %2 == 0)
    {
        [cell setBackgroundColor:[UIColor redColor]];
        //[cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_btn1.png"]]];
        

    }
    else
    {
        [cell setBackgroundColor:[UIColor yellowColor]];
        //[cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_btn2.png"]]];
    }
     */
    
    if ([UIAppDelegate isProUser])
    {
        cell.textLabel.text = [tableDataForPro objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = [tableDataForFree objectAtIndex:indexPath.row];
    }
    
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:15*padFactor]];
    [cell.textLabel setTextAlignment:NSTextAlignmentRight];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([UIAppDelegate isProUser])
    {
        switch (indexPath.row)
        {
            case 0:
                [self rateButtonAction];
                break;
            case 1:
                [self memeCabinFbButtonAction];
                break;
            case 2:
                [self singleDadButtonAction];
                break;
            case 3:
                [self singleDadFbButtonAction];
                break;
            case 4:
                [self singleDadInstButtonAction];
                break;
            case 5:
                [self logoutButtonAction];
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case 0:
                [self rateButtonAction];
                break;
            case 1:
                [self disableAdButtonAction];
                break;
            case 2:
                [self memeCabinFbButtonAction];
                
                break;
            case 3:
                [self singleDadButtonAction];
                break;
            case 4:
                [self singleDadFbButtonAction];
                break;
            case 5:
                [self singleDadInstButtonAction];
                break;
            case 6:
                [self logoutButtonAction];
                break;
                
            default:
                break;
        }
    }
    
}


#pragma mark - Table Delegate END

-(IBAction)rateButtonAction
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Rate Button Clicked"];
    DanMessagePopup *rAlert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self
                                                                 label1:@"Will you rate this app?"
                                                                 label2:@"Would you mind taking a sec to help a brother from another mother?"
                                                         button1stTitle:@"YES! Five stars, baby!"
                                                         button2ndTitle:@"Hey Dan, remind me later."
                                                         button3rdTitle:@"No. I don't wanna"
                                                         button4thTitle:nil
                                                        showTopBlackBar:NO];
    
    rAlert.tag = 1;
    [rAlert show];
}

-(IBAction)disableAdButtonAction
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Disable Ads Button Clicked"];
    DanMessagePopup *rAlert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self
                                                                 label1:@"DISABLE ADS?"
                                                                 label2:@"How can I blame you?! This app is awesome!"
                                                         button1stTitle:@"Disable for $0.99/year"
                                                         button2ndTitle:@"Disable forever for $4.99"
                                                         button3rdTitle:@"Restore Subscription"
                                                         button4thTitle:@"Nah. I changed my mind."
                                                        showTopBlackBar:NO];
    rAlert.tag = 2;
    [rAlert show];
}

-(IBAction)singleDadButtonAction
{
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:SDL_APP_SCHEME]]]) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:SDL_APP_SCHEME]]];
        NSLog(@"canOpenURL");
    }
    else{
        if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:SDL_APP_iTUNES_URL]]]) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:SDL_APP_iTUNES_URL]]];
            NSLog(@"canOpenURL");
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Unable to open the page. Pleaes try later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil]show];
        }
    }
}
-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    NSLog(@"productViewControllerDidFinish");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Custom Rating AlertView
-(void)danMessagePopupView:(DanMessagePopup *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (alertView.tag) {
        case 1:
            switch (buttonIndex) {
                case 0:
                    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Rate-Now on Rate popup"];
                    [iRate sharedInstance].ratedThisVersion = YES;
                    [[iRate sharedInstance] openRatingsPageInAppStore];
                    break;
                case 1:
                    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Remind-Later on Rate popup"];
                    [iRate sharedInstance].lastReminded = [NSDate date];
                    break;
                case 2:
                    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Cancel on Rate popup"];
                    [iRate sharedInstance].declinedThisVersion = YES;
                    break;
                    
                default:
                    break;
            }
            break;
        case 2:
            switch (buttonIndex)
        {
                case 0:
                self.purchaseCode = PURCHASE_DISABLE_ANNUAL;
                if([AppDelegate isNetworkAvailable])
                {
                    [self purchaseSubscription];
                    /*
                    [UIAppDelegate setProUser];
                    [UIAppDelegate.obj_iAd removeFromSuperview];
                    [UIAppDelegate.obj_FlurryAd removeFromSuperview];
                    [UIAppDelegate setProUserHasBeenMarked:YES];
                    
                    
                    _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                    [_menuTableView reloadData];*/
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:@"No internet connection detected. Please try later."];
                }
                
                
                    break;
                case 1:
                self.purchaseCode = PURCHASE_DISABLE_FOREVER;
                if([AppDelegate isNetworkAvailable])
                {
                    [self purchaseSubscription];
                    /*
                    [UIAppDelegate setProUser];
                    [UIAppDelegate.obj_iAd removeFromSuperview];
                    [UIAppDelegate.obj_FlurryAd removeFromSuperview];
                    [UIAppDelegate setProUserHasBeenMarked:YES];
                    
                    
                    _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                    [_menuTableView reloadData];*/
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:@"No internet connection detected. Please try later."];
                }
                
                    break;
                case 2:
                [self restorePurchase];
                /*[UIAppDelegate setProUser];// <<Added by sujohn for testing>>
                [UIAppDelegate.obj_iAd removeFromSuperview];
                [UIAppDelegate.obj_FlurryAd removeFromSuperview];*/
                break;
                case 3:
                    //[irate declineThisVersion];
                    NSLog(@"tag = 2 buttonIndex = 2");
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

-(void)purchaseSubscription
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMKStoreKitProductPurchasedNotification object:nil];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:self.purchaseCode];
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Purchased/Subscribed to product with id: %@", [note object]);
                                                      //[SVProgressHUD showSuccessWithStatus:@"Purchase Successful!"];
                                                      [SVProgressHUD dismiss];
                                                      
                                                      
                                                      NSLog(@"%@", [[MKStoreKit sharedKit] valueForKey:@"purchaseRecord"]);
                                                      //[UIAppDelegate hideLoading];
                                                      [UIApplication sharedApplication].idleTimerDisabled = NO;
                                                      
                                                      NSDateFormatter *format = [[NSDateFormatter alloc] init];
                                                      format.dateFormat = @"dd-MM-yyyy";
                                                      NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                                                      NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                                                      if([self.purchaseCode isEqualToString:PURCHASE_DISABLE_FOREVER])
                                                      {
                                                          [offsetComponents setYear:50];
                                                      }
                                                      else
                                                      {
                                                          [offsetComponents setYear:1];
                                                      }
                                                      
                                                      NSDate *nextYear = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate new] options:0];
                                                      
                                                      
                                                      NSString *expirayDate = [format stringFromDate:nextYear];
                                                      //Store the purchase record
                                                      AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                                      manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                                                      NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
                                                      NSString *userId = [userInfoDisct objectForKey:@"userId"];
                                                      if(userId.length==0)
                                                      {
                                                          
                                                          userId = [NSString stringWithFormat:@"%d",[self generateRandomNumberBetweenMin:100000000 Max:999999999]];
                                                      }
                                                      
                                                      
                                                      
                                                      [manager GET:@"http://thememecabin.com/SDL/add.php" parameters:[NSDictionary dictionaryWithObjects:@[self.purchaseCode,userId,expirayDate,@"ios"] forKeys:@[@"title",@"user_id",@"expdate",@"device_type"]] success:^(AFHTTPRequestOperation *operation, id responseObject)
                                                       {
                                                           
                                                           NSLog(@"%@",responseObject);
                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase" message:@"Purchased successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                           alert.tag = 201;
                                                           [alert show];
                                                           
                                                           [[NSUserDefaults standardUserDefaults] setObject:expirayDate forKey:PURCHASE_DATE];
                                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                                           
                                                           /////Remove Ad icon From Dashboard//////
                                                           
                                                           [UIAppDelegate enableFeature:REMOVE_ADS :NO];
                                                           
                                                           ///////////
                                                           
                                                           [UIAppDelegate setProUser];
                                                           
                                                           [UIAppDelegate.obj_FlurryAd removeFromSuperview];
                                                           [UIAppDelegate setProUserHasBeenMarked:YES];
                                                           
                                                           
                                                           _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                                                           [_menuTableView reloadData];
                                                           //[SVProgressHUD dismiss];
                                                           
                                                           
                                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                           NSLog(@"Error: %@", error);
                                                           [UIAppDelegate activityHide];
                                                       }];
                                                      
                                                      
                                                      
                                                      
                                                  }];
}

-(void)restorePurchase
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    alertIsShown = NO;
    [[MKStoreKit sharedKit] restorePurchases];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    __block NSString *aFlag = @"NO";
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoredPurchasesNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      [SVProgressHUD dismiss];
                                                      NSLog(@"Restored Purchases");
                                                      
                                                      [UIApplication sharedApplication].idleTimerDisabled = NO;
                                                      NSDateFormatter *format = [[NSDateFormatter alloc] init];
                                                      format.dateFormat = @"dd-MM-yyyy";
                                                      
                                                      
                                                      AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                                      manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                                                      NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
                                                      NSString *userId = [userInfoDisct objectForKey:@"userId"];
                                                      if(userId.length==0)
                                                      {
                                                          
                                                          userId = [NSString stringWithFormat:@"%d",[self generateRandomNumberBetweenMin:100000000 Max:999999999]];
                                                      }
                                                      
                                                      [manager GET:@"http://thememecabin.com/SDL/list.php" parameters:[NSDictionary dictionaryWithObjects:@[userId,@"ios"] forKeys:@[@"user_id",@"device_type"]] success:^(AFHTTPRequestOperation *operation, id responseObject)
                                                       {
                                                           NSLog(@"%@",responseObject);
                                                           NSError *error = nil;
                                                           NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
                                                           BOOL isPurchasedBefore = NO;
                                                           NSArray *aArray = [aDict objectForKey:@"result"];
                                                           NSString *expiryDate = @"";
                                                           int days = 0;
                                                           for(NSDictionary *record in aArray)
                                                           {
                                                               /*
                                                                NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
                                                                format1.dateFormat = @"dd-MM-yyyy";
                                                                NSDate *aDate = [format1 dateFromString:[record objectForKey:@"expdate"]];
                                                                NSString *bDateString = [format1 stringFromDate:[NSDate new]];
                                                                NSDate *bDate = [format1 dateFromString:bDateString];
                                                                if ([bDate  compare:aDate] == NSOrderedAscending)
                                                                {
                                                                flagPurchase = YES;
                                                                break;
                                                                }*/
                                                               
                                                               /*
                                                                if([self daysRemainingOnSubscription:[record objectForKey:@"expdate"]] == 0)
                                                                {
                                                                flagPurchase = YES;
                                                                //break;
                                                                }*/
                                                               if([[record objectForKey:@"title"] isEqualToString:PURCHASE_DISABLE_FOREVER])
                                                               {
                                                                   expiryDate = [record objectForKey:@"expdate"];
                                                                   isPurchasedBefore = YES;
                                                                   break;
                                                               }
                                                               else
                                                               {
                                                                   int days1 = [self daysRemainingOnSubscription:[record objectForKey:@"expdate"]];
                                                                   if(days1>=days)
                                                                   {
                                                                       days = days1;
                                                                       expiryDate = [record objectForKey:@"expdate"];
                                                                       isPurchasedBefore = YES;
                                                                   }
                                                               }
                                                               
                                                               
                                                           }
                                                           
                                                           if(aArray.count==0)
                                                           {
                                                               //Store the purchase record
                                                               NSDateFormatter *format = [[NSDateFormatter alloc] init];
                                                               format.dateFormat = @"dd-MM-yyyy";
                                                               NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                                                               NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                                                               self.purchaseCode = PURCHASE_DISABLE_ANNUAL;
                                                               if([self.purchaseCode isEqualToString:PURCHASE_DISABLE_FOREVER])
                                                               {
                                                                   [offsetComponents setYear:50];
                                                               }
                                                               else
                                                               {
                                                                   [offsetComponents setYear:1];
                                                               }
                                                               
                                                               NSDate *nextYear = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate new] options:0];
                                                               
                                                               
                                                               NSString *expirayDate = [format stringFromDate:nextYear];
                                                               //Store the purchase record
                                                               AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                                               manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                                                               NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
                                                               NSString *userId = [userInfoDisct objectForKey:@"userId"];
                                                               if(userId.length==0)
                                                               {
                                                                  
                                                                   userId = [NSString stringWithFormat:@"%d",[self generateRandomNumberBetweenMin:100000000 Max:999999999]];
                                                               }
                                                               
                                                               
                                                               
                                                               [manager GET:@"http://thememecabin.com/SDL/add.php" parameters:[NSDictionary dictionaryWithObjects:@[self.purchaseCode,userId,expirayDate,@"ios"] forKeys:@[@"title",@"user_id",@"expdate",@"device_type"]] success:^(AFHTTPRequestOperation *operation, id responseObject)
                                                                {
                                                                    
                                                                    NSLog(@"%@",responseObject);
                                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase" message:@"Purchased successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                                    alert.tag = 201;
                                                                    [alert show];
                                                                    
                                                                    [[NSUserDefaults standardUserDefaults] setObject:expirayDate forKey:PURCHASE_DATE];
                                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                                    
                                                                    /////Remove Ad icon From Dashboard//////
                                                                    
                                                                    [UIAppDelegate enableFeature:REMOVE_ADS :NO];
                                                                    
                                                                    ///////////
                                                                    
                                                                    [UIAppDelegate setProUser];
                                                                    
                                                                    [UIAppDelegate.obj_FlurryAd removeFromSuperview];
                                                                    [UIAppDelegate setProUserHasBeenMarked:YES];
                                                                    
                                                                    
                                                                    _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                                                                    [_menuTableView reloadData];
                                                                    
                                                                    
                                                                    
                                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                    NSLog(@"Purchase store failed!");
                                                                    [UIAppDelegate activityHide];
                                                                }];
                                                           }
                                                           else
                                                           {
                                                               if(isPurchasedBefore)
                                                               {
                                                                   /*
                                                                    [[[UIAlertView alloc] initWithTitle:@"Subscription Expired" message:@"Please renew the subscription" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];*/
                                                                   
                                                                   if([self daysRemainingOnSubscription:expiryDate] == 0)
                                                                   {
                                                                       if(!(alertIsShown))
                                                                       {
                                                                           [[[UIAlertView alloc] initWithTitle:@"Subscription Expired" message:@"Please renew the subscription" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
                                                                           alertIsShown = YES;
                                                                       }
                                                                       
                                                                   }
                                                                   else
                                                                   {
                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase" message:@"Restored purchases successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                                       alert.tag = 201;
                                                                       [alert show];
                                                                       
                                                                       
                                                                       [[NSUserDefaults standardUserDefaults] setObject:expiryDate forKey:PURCHASE_DATE];
                                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                                       
                                                                       //[UIApplication sharedApplication].idleTimerDisabled = NO;
                                                                       
                                                                       /////Remove Ad icon From Dashboard//////
                                                                       
                                                                       [UIAppDelegate enableFeature:REMOVE_ADS :NO];
                                                                       
                                                                       ///////////
                                                                       
                                                                       [UIAppDelegate setProUser];
                                                                       
                                                                       [UIAppDelegate.obj_FlurryAd removeFromSuperview];
                                                                       [UIAppDelegate setProUserHasBeenMarked:YES];
                                                                       
                                                                       
                                                                       //[tableData removeObjectAtIndex:1];
                                                                       _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                                                                       [_menuTableView reloadData];
                                                                   }
                                                               }
                                                               else
                                                               {
                                                                   
                                                                   
                                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase" message:@"Restored purchases successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                                   
                                                                   [alert show];
                                                                   
                                                                   /////Remove Ad icon From Dashboard//////
                                                                   
                                                                   [UIAppDelegate enableFeature:REMOVE_ADS :NO];
                                                                   
                                                                   ///////////
                                                                   
                                                                   [UIAppDelegate setProUser];
                                                                   
                                                                   [UIAppDelegate.obj_FlurryAd removeFromSuperview];
                                                                   [UIAppDelegate setProUserHasBeenMarked:YES];
                                                                   
                                                                   
                                                                   //[tableData removeObjectAtIndex:1];
                                                                   _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                                                                   [_menuTableView reloadData];
                                                               }
                                                           }
                                                           
                                                           
                                                           
                                                           
                                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                           NSLog(@"Purchase store failed!");
                                                           [UIAppDelegate activityHide];
                                                       }];
                                                      
                                                      
                                                      
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoringPurchasesFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      [SVProgressHUD dismiss];
                                                      //NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                      if([aFlag isEqualToString:@"NO"])
                                                      {
                                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase" message:@"Purchase aborted" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                          
                                                          [alert show];
                                                          aFlag = @"YES";
                                                      }
                                                      
                                                      
                                                      
                                                  }];
}

-(int)generateRandomNumberBetweenMin:(int)min Max:(int)max
{
    return ( (arc4random() % (max-min+1)) + min );
}

-(IBAction)memeCabinFbButtonAction
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"MemeCabin On Facebok Button Clicked"];
    [self openMemeOnFacebook];
}
-(IBAction)singleDadFbButtonAction
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Single Dad On Facebok Button Clicked"];
    [self openSDLOnFacebook];
}
-(IBAction)singleDadInstButtonAction
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Single Dad On Instagram Button Clicked"];
    [self openSDLOnInstagram];
}

-(IBAction)logoutButtonAction
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Logout Button Clicked"];
    
    NSLog(@"MemeViewController logoutButtonAction tapped!!");
    
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CHECK_FOR_LOGIN];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CHECK_FOR_USER_INFO];
    
    UIAppDelegate.userFavouriteNumber = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MEME_FAVORITE_CURRENT_COUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIAppDelegate.isNewlyLaunched = YES;
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isFromHome)
    {
        NSLog(@"isFromHome yes");
        
        LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"LoginViewController"] bundle:nil];
        for (id myVC in UIAppDelegate.navigationController.viewControllers) {
            vc = (UIViewController *)myVC;
        }
        [vc.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        NSLog(@"isFromHome no");
        
        NSArray *vcArr = [UIAppDelegate.navigationController viewControllers];
        NSLog(@"MyNav: %@", vcArr);
        
        UIViewController *vcd;
        
        for (id myVC in vcArr)
        {
            if ([myVC isKindOfClass:[LoginViewController class]])
            {
                vcd = (UIViewController*)myVC;
                break;
            }
        }
        UIViewController *vcc;
        for (id myVC in UIAppDelegate.navigationController.viewControllers) {
            vcc = (UIViewController *)myVC;
        }
        [vcc.navigationController popToViewController:vcd animated:NO];
    }
}

#pragma mark - Open App OR URL
-(void)openMemeOnFacebook
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:FACEBOOK_MEMECABIN_APP]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FACEBOOK_MEMECABIN_APP]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FACEBOOK_MEMECABIN_URL]];
}
-(void)openSDLOnFacebook
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:FACEBOOK_SINGLEDAD_APP]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FACEBOOK_SINGLEDAD_APP]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FACEBOOK_SINGLEDAD_URL]];
}
-(void)openSDLOnInstagram
{
    if ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:INSTAGRAM_APP]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:INSTAGRAM_APP]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:INSTAGRAM_URL]];
}

/*
 WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
 viewController.controllerIdentifier = 1;
 viewController.titleForPage = @"Single Dad Laughing on Instagram";
 viewController.webURL = INSTAGRAM_URL;
 [vc.navigationController pushViewController:viewController animated:YES];
 */


@end
