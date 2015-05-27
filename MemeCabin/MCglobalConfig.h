//
//  MCglobalConfig.h
//  MemeCabin
//
//  Created by Aapbd on 10/28/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#ifndef MemeCabin_MCglobalConfig_h
#define MemeCabin_MCglobalConfig_h


#define MEME_FOR_EVERYONE @"Memes for Everyone"
#define MOTIVATIONAL_INSPIRATIONAL @" Motivational & Inspirational"
#define RACY_MEMES @"Racy Memes"
#define SPIFFY_GIFS @"Spiffy Gifs"
#define TRENDING_POPULAR @"Trending & Popular"
#define UPLOAD_AWESOME_MEME @"Upload an AWESOME Meme!"
#define SAVED_FAVORITES @"Your Saved Favorites (0)"
#define REMOVE_ADS @"Remove Ads!"
#define SINGLE_DAD_LAUGHING @"The Humaning App"//@"Single Dad Laughing App"
#define MEME_FOR_EVERYONE_BADGE @"MemeEveryOne Badge Show Hide"
#define MOTIVATIONAL_INSPIRATIONAL_BADGE @"Motivational Badge Show Hide"
#define RACY_MEME_BADGE @"RacyMeme Badge Show Hide"
#define SPIFFY_GIFS_BADGE @"SpiffyGifs Badge Show Hide"


#define SDL_APP_SCHEME @"danSDL://"
#define SDL_APP_ID @"911371895"
#define SDL_APP_iTUNES_URL @"itms-apps://itunes.apple.com/app/id911371895"


#define RateAppDefaultCount 5
#define AppRatingURL @"itms-apps://itunes.apple.com/app/id%@"
#define AppID @"921727278" //767995612


#define FACEBOOK_MEMECABIN_URL @"https://www.facebook.com/memecabin"
#define FACEBOOK_SINGLEDAD_URL @"http://www.facebook.com/singledadlaughing"
#define INSTAGRAM_URL @"http://www.instagram.com/danoah"

#define FACEBOOK_MEMECABIN_APP @"fb://profile/452061631600810" //replace  429759140452016
#define FACEBOOK_SINGLEDAD_APP @"fb://profile/139472446076911" // replace plungeint
#define INSTAGRAM_APP @"instagram://user?username=danoah" //replace USERNAME

// Google Analytics
#define TRACKING_ID  @"UA-55801508-1" // @"UA-52655283-1"

//adMod 
#define AdMob_ID_BANNER @"ca-app-pub-1171910944013829/3859722195"
#define AdMob_ID_INTERSTITIAL @"ca-app-pub-1171910944013829/2414209392"



//URL

//topMemesListV2

#define MEMECABIN_DOMAIN_URL @"http://thememecabin.com/"
#define BASE_URL @"http://thememecabin.com/api/"

#define MEME_SIGN_IN [NSString stringWithFormat:@"%@signin?",BASE_URL]
#define MEME_SIGN_UP [NSString stringWithFormat:@"%@signup?",BASE_URL]

#define MEME_EVERYONE [NSString stringWithFormat:@"%@everyoneMemesListV2?",BASE_URL]
#define MEME_MOTIVATIONAL [NSString stringWithFormat:@"%@motivationalMemesListV2?",BASE_URL]
#define MEME_RACY [NSString stringWithFormat:@"%@racyMemesListV2?",BASE_URL]
#define MEME_GIFS [NSString stringWithFormat:@"%@SpiffyMemesListNewV2",BASE_URL]


#define MEME_LIKE (NSString *)[NSString stringWithFormat:@"%@updateMemestotalLike?",BASE_URL]
#define MEME_DISLIKE [NSString stringWithFormat:@"%@updateMemesdisLike?",BASE_URL]

#define MEME_VIEW [NSString stringWithFormat:@"%@updateMemesView?",BASE_URL]
#define MEME_UPLOAD [NSString stringWithFormat:@"%@uploadRacyMemes",BASE_URL]//uploadRacyMemes
//#define MEME_TOPLIST [NSString stringWithFormat:@"%@topMemesListV2?",BASE_URL]
#define MEME_TOPLIST [NSString stringWithFormat:@"%@topMemesList?",BASE_URL]

#define MEME_CHANGE_PASSWORD [NSString stringWithFormat:@"%@changePassord?",BASE_URL]
#define MEME_FORGOT_PASSWORD [NSString stringWithFormat:@"%@forgotPassword?",BASE_URL]

#define MEME_VERIFICATION_LINK [NSString stringWithFormat:@"%@resendVerification?",BASE_URL]//email=amarkotha366@gmail.com

#define MEME_MAKE_FAVOURITE [NSString stringWithFormat:@"%@makeFavourite?",BASE_URL]
#define MEME_MAKE_UNFAVOURITE [NSString stringWithFormat:@"%@makeUnFavourite?",BASE_URL]

#define MEME_UPDATE_LIKE [NSString stringWithFormat:@"%@getFavorites?",BASE_URL]//memeId=226&userID=48

#define MEME_FAVOURITE_LIST [NSString stringWithFormat:@"%@myFavouriteMemeListV2?",BASE_URL]
#define MEME_UPCOMMING_APP_LINK [NSString stringWithFormat:@"%@upComingApps?",BASE_URL]
#define MEME_DELETED_LIST [NSString stringWithFormat:@"%@deletedMemesList",BASE_URL]

//#define MEME_VIEW [NSString stringWithFormat:@"%@updateMemesView?",BASE_URL]
//#define MEME_UPLOAD [NSString stringWithFormat:@"%@uploadRacyMemes",BASE_URL]
//#define MEME_TOPLIST [NSString stringWithFormat:@"%@topMemesList?",BASE_URL]

#define MEME_REPORT (NSString *)[NSString stringWithFormat:@"%@memereport?",BASE_URL]
#define MEME_MESSAGE_FROM_DAN [NSString stringWithFormat:@"%@DansMessage",BASE_URL]
#define MEME_MESSAGE_FROM_DAN_NEW [NSString stringWithFormat:@"%@DansPopupios",BASE_URL]

/*
#define MEME_SIGN_IN @"http://thememecabin.com/api/signin?"
#define MEME_SIGN_UP @"http://thememecabin.com/api/signup?"

#define MEME_EVERYONE @"http://thememecabin.com/api/everyoneMemesList?"
#define MEME_MOTIVATIONAL @"http://thememecabin.com/api/motivationalMemesList?"
#define MEME_RACY @"http://thememecabin.com/api/racyMemesList?"
#define MEME_GIFS @"http://thememecabin.com/api/SpiffyMemesListNew"

#define MEME_LIKE @"http://thememecabin.com/api/updateMemestotalLike?"
#define MEME_DISLIKE @"http://thememecabin.com/api/updateMemesdisLike?"

#define MEME_VIEW @"http://thememecabin.com/api/updateMemesView?"
#define MEME_UPLOAD @"http://thememecabin.com/api/uploadRacyMemes"//uploadRacyMemes
#define MEME_TOPLIST @"http://thememecabin.com/api/topMemesList?"

#define MEME_CHANGE_PASSWORD @"http://thememecabin.com/api/changePassord?"
#define MEME_FORGOT_PASSWORD @"http://thememecabin.com/api/forgotPassword?"

#define MEME_VERIFICATION_LINK @"http://thememecabin.com/api/resendVerification?"//email=amarkotha366@gmail.com

#define MEME_MAKE_FAVOURITE @"http://thememecabin.com/api/makeFavourite?"
#define MEME_MAKE_UNFAVOURITE @"http://thememecabin.com/api/makeUnFavourite?"

#define MEME_UPDATE_LIKE @"http://thememecabin.com/api/getFavorites?"//memeId=226&userID=48

#define MEME_FAVOURITE_LIST @"http://thememecabin.com/api/myFavouriteMemeList?"
#define MEME_UPCOMMING_APP_LINK @"http://thememecabin.com/api/upComingApps?"
#define MEME_DELETED_LIST @"http://thememecabin.com/api/deletedMemesList"

#define MEME_VIEW @"http://thememecabin.com/api/updateMemesView?"
#define MEME_UPLOAD @"http://thememecabin.com/api/uploadRacyMemes"
#define MEME_TOPLIST @"http://thememecabin.com/api/topMemesList?" 

#define MEME_REPORT @"http://thememecabin.com/api/memereport?"
#define MEME_MESSAGE_FROM_DAN @"http://thememecabin.com/api/DansMessage"
 
 */

#define MEME_EVERYONE_SERVER_COUNT @"MemeEveryOneServer"
#define MEME_MOTI_INSP_SERVER_COUNT @"MemeMotiInspServer"
#define MEME_RACY_SERVER_COUNT @"MemeRacyServer"
#define MEME_SPIFFY_GIFS_SERVER_COUNT @"MemeSpiffyGifServer"

#define MEME_EVERYONE_CURRENT_COUNT @"MemeEveryOneCurrent"
#define MEME_MOTI_INSP_CURRENT_COUNT @"MemeMotiInspCurrent"
#define MEME_RACY_CURRENT_COUNT @"MemeRacyCurrent"
#define MEME_SPIFFY_GIF_CURRENT_COUNT @"MemeSpiffyGifCurrent"
#define MEME_FAVORITE_CURRENT_COUNT @"MemeFavoriteCurrent"

#define EVERYONE_MEME @"EveryOne"
#define MOTIVATIONAL_MEME @"Motivational"
#define RACY_MEME @"Racy"


#endif
