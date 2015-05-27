//
//  AdNetworkConfig.h
//  MemeCabin
//
//  Created by Aapbd on 10/30/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#ifndef MemeCabin_AdNetworkConfig_h
#define MemeCabin_AdNetworkConfig_h
 


#define GameOverAdDefaultCount 1    // Set '0' for no GameOverAd

#define iAd @"iAd"
#define FlurryKey @"Flurry"

#define BannerAdDefaultList [NSArray arrayWithObjects: iAd, FlurryKey, nil]
#define FullScreenAdDefaultList [NSArray arrayWithObjects: iAd, FlurryKey, nil]

//----> Flurry
#define FlurryADId @"3MRWTQNDZFR8PCWWTKB9"
#define FlurryBannerAdSpace @"Meme Cabin Banner iOS"//@"BANNER_MAIN_VIEW"
#define FlurryFullViewAdSpace @"Meme Cabin iOS Intersitial"//@"INTERSTITIAL_MAIN_VIEW"
//----> Flurry

#define factorMinus ((IS_IPAD) ? 5 : 1)
#define factorY ((IS_IPAD) ? 1.8 : 1)
#define factorX ((IS_IPAD) ? 2.4 : 1)
#define padFactor ((IS_IPAD) ? 1.67 : 1)

#define ITEMS_PER_PAGE 32
#define ITEMS_SPIFFY_PER_PAGE 50

#define PURCHASE_DISABLE_ANNUAL @"Non_Renew_Ads_Free_1_Dollar_Yearly_Subscription"
#define PURCHASE_DISABLE_FOREVER @"DisableForever"
#define PURCHASE_DATE @"PurchaseExpirationDate"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


//#define



#endif
