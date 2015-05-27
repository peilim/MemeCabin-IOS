//
//  DBHelper.h
//  ShufflerMusicPlayer
//
//  Created by AAPBD Mac mini on 03/08/2014.
//  Copyright (c) 2014 aapbd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHelper : NSObject
{
    NSString *databasePath;
}
-(NSString *) getDbFilePath;
-(int) createTable:(NSString*) filePath;
-(BOOL) isFavourite:(NSString *)memeId;
/*!
 @abstract
 Call this method to check whether a MEME exists into DB.
 
 @param memeId Pass the MEME Id you want to check into DB.
 
 @return YES if successful and vice versa.
 */
-(BOOL) isMemeIdExist:(NSString *)memeId;
/*!
 @abstract
 Call this method when you want to insert a MEME details into DB.
 
 @param memeId Pass the MEME Id you want to insert into DB.
 
 @param like Pass the MEME like count.
 
 @return YES if successful and vice versa.
 */
-(BOOL)insertWithMemeID:(NSString *)memeId likeCount:(NSString *)like withCategory:(NSString *)category;
/*!
 @abstract
 Call this method when you have liked MEME.
 
 @param isLiked Pass 1 to indicate you have liked the MEME, or pass 0 to unlike.
 
 @param memeId Pass the MEME Id you have liked.
 
 @return YES if successful and vice versa.
 */
-(BOOL) updateMemeLike:(NSString *)isLiked withMemeID:(NSString *)memeId;
/*!
 @abstract
 Call this method when you have viewed a MEME.
 
 @param isViewed Pass 1 to indicate you have viewed the MEME.
 
 @param memeId Pass the MEME Id you have viewed.
 
 @return YES if successful and vice versa.
 */
-(BOOL) updateMemeView:(NSString *)isViewed withMemeID:(NSString *)memeId;
/*!
 @abstract
 Call this method to make a meme your favourite MEME.
 
 @param isFavourite Pass 1 to meke favourite and 0 to make unfavourite.
 
 @param memeId Pass the MEME Id you want to make favourite/unfavourite.
 
 @return YES if successful and vice versa.
 */
-(BOOL) updateMemeFavorite:(NSString *)isFavourite withMemeID:(NSString *)memeId;
/*!
 @abstract
 Call this method to update MEME Sync status.
 
 @param syncStatus Pass 1 to indicate is Sync and 0 to indicate is not Sync.
 
 @param memeId Pass the MEME Id you want to make Sync/UnSync.
 
 @return YES if successful and vice versa.
 */
//-(BOOL) updateMemeSynchronisation:(NSString *)syncStatus withMemeID:(NSString *)memeId;

/*!
 @abstract
 Call this method to get all MEMEs.
 
 @return Returns a NSMutableArray of Objects of type UserMeme.
 */
-(NSMutableArray *)getAllMemes;

-(BOOL) isViewed:(NSString *)memeId;

-(BOOL) isLiked:(NSString *)memeId;

-(NSMutableArray *)getIDs;

-(NSInteger) getViewCounterWithCategory:(NSString *)category;

-(BOOL) updateCategory:(NSString *)category withMemeID:(NSString *)memeId;

-(NSInteger)getSavedFavourites;

-(NSDictionary *)updateMemeViewsForMemeIds:(NSArray *)memeArray;

@end
