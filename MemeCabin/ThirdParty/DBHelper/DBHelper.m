//
//  DBHelper.m
//  ShufflerMusicPlayer
//
//  Created by AAPBD Mac mini on 03/08/2014.
//  Copyright (c) 2014 aapbd. All rights reserved.
//

#import "DBHelper.h"

#import <sqlite3.h>

#import "MemePhoto.h"

static DBHelper *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBHelper

-(NSString *) getDbFilePath
{
    NSString * docsPath= NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [docsPath stringByAppendingPathComponent:@"meme.db"];
}

-(int) createTable:(NSString*) filePath
{
    sqlite3* db = NULL;
    int rc=0;
    
    rc = sqlite3_open_v2([filePath cStringUsingEncoding:NSUTF8StringEncoding], &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
    if (SQLITE_OK != rc)
    {
        sqlite3_close(db);
        NSLog(@"Failed to open db connection");
    }
    else
    {
        char * query ="CREATE TABLE IF NOT EXISTS meme_table ( id INTEGER PRIMARY KEY AUTOINCREMENT, meme_id TEXT, likeCount TEXT, isLiked TEXT, isViewed TEXT, isFavourite TEXT, syncStatus TEXT, category TEXT)";
        
        char * errMsg;
        rc = sqlite3_exec(db, query,NULL,NULL,&errMsg);
        
        NSLog(@"meme_table CREATED");
        
        if(SQLITE_OK != rc)
        {
            NSLog(@"Failed to create table rc:%d, msg=%s",rc,errMsg);
        }
        
        sqlite3_close(db);
        
    }
    
    return rc;
    
}

#pragma mark - InsertMeme
-(BOOL)insertWithMemeID:(NSString *)memeId likeCount:(NSString *)like withCategory:(NSString *)category
{
    BOOL success = false;
    const char *dbpath = [[self getDbFilePath] UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO meme_table (meme_id, likeCount, isLiked, isViewed, isFavourite, syncStatus, category) VALUES (\"%@\", \"%@\", \"%@\",\"%@\", \"%@\", \"%@\", \"%@\")", memeId, like, @"0", @"0", @"0", @"0", category];
                    
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            //NSLog(@"insertIntoMemeWithID-> likeCount :: %@",like);
            //NSLog(@"insertIntoMemeWithID-> category :: %@",category);
            //NSLog(@"insertIntoMemeWithID-> url :: %@",url);
            
            success = true;
        }
        sqlite3_reset(statement);
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return success;
}

#pragma mark - UpdateMeme
-(BOOL) updateMemeLike:(NSString *)isLiked withMemeID:(NSString *)memeId
{
    BOOL success = false;
    const char *dbpath = [[self getDbFilePath] UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"UPDATE meme_table SET isLiked=\"%@\" WHERE meme_id=\"%@\"",isLiked, memeId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            
            //NSLog(@"memeLIKE");
            success = true;
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return success;
}

//update meme view
-(BOOL) updateMemeView:(NSString *)isViewed withMemeID:(NSString *)memeId
{
    BOOL success = false;
    const char *dbpath = [[self getDbFilePath] UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"UPDATE meme_table SET isViewed=\"%@\" WHERE meme_id=\"%@\"",isViewed, memeId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            
            success = true;
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return success;
}

//update meme favorite
-(BOOL) updateMemeFavorite:(NSString *)isFavourite withMemeID:(NSString *)memeId
{
    BOOL success = false;
    const char *dbpath = [[self getDbFilePath] UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"UPDATE meme_table SET isFavourite=\"%@\" WHERE meme_id=\"%@\"",isFavourite, memeId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            
            success = true;
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return success;
}



-(BOOL) isViewed:(NSString *)memeId
{
    const char *dbpath = [[self getDbFilePath] UTF8String];
    BOOL isViewed = NO;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM meme_table WHERE meme_id=\"%@\" AND isViewed=\"1\"",memeId];
        const char *query_stmt = [querySQL UTF8String];
        
        
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                isViewed = YES;
                break;
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return isViewed;
}

-(BOOL) isLiked:(NSString *)memeId
{
    const char *dbpath = [[self getDbFilePath] UTF8String];
    BOOL isLiked = NO;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM meme_table WHERE meme_id=\"%@\" AND isLiked=\"1\"",memeId];
        const char *query_stmt = [querySQL UTF8String];
        
        
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                isLiked = YES;
                break;
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return isLiked;
}

-(BOOL) isFavourite:(NSString *)memeId
{
    const char *dbpath = [[self getDbFilePath] UTF8String];
    BOOL isFavourite = NO;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM meme_table WHERE meme_id=\"%@\" AND isFavourite=\"1\"",memeId];
        const char *query_stmt = [querySQL UTF8String];
        
        
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                isFavourite = YES;
                break;
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return isFavourite;
}

-(NSMutableArray *)getIDs
{
    const char *dbpath = [[self getDbFilePath] UTF8String];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM meme_table"];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *memeID = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 1)];
                
                MemePhoto *memePhoto = [[MemePhoto alloc] init];
                memePhoto.photoID = memeID;
                
                [resultArray addObject:memePhoto];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return resultArray;
}

#pragma mark - getAllMemes
-(NSMutableArray *)getAllMemes
{
    const char *dbpath = [[self getDbFilePath] UTF8String];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM meme_table"];
        const char *query_stmt = [querySQL UTF8String];
        
        
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSString *memeID = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 1)];
                
                NSString *likeCount = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 2)];
                
                //NSLog(@"getAllMemes-> likeCount :: %@",likeCount);
                
                NSString *isLiked = [[NSString alloc] initWithUTF8String:
                                 (const char *) sqlite3_column_text(statement, 3)];
                
                NSString *isViewed = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 4)];
                
                NSString *isFavourite = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 5)];
                
                NSString *syncStatus = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 6)];
                
                
                MemePhoto *memePhoto = [[MemePhoto alloc] init];
                
                memePhoto.photoID = memeID;
                memePhoto.photoLike = likeCount;
                memePhoto.isLiked = isLiked;
                memePhoto.isViewed = isViewed;
                memePhoto.isFavourite = isFavourite;
                memePhoto.syncStatus = syncStatus;
                
                [resultArray addObject:memePhoto];
                
            }
            sqlite3_finalize(statement);
            
            //NSLog(@"resultArray_count==%d",resultArray.count);
            
            //NSLog(@"Done");
        }
        sqlite3_close(database);
    }
    return resultArray;
}

-(NSInteger)getSavedFavourites
{
    const char *dbpath = [[self getDbFilePath] UTF8String];
    NSInteger count = 0;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM meme_table WHERE isFavourite=\"1\""];
        const char *query_stmt = [querySQL UTF8String];
        
        
        
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                count++;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return count;
}

-(BOOL) isMemeIdExist:(NSString *)memeId
{
    const char *dbpath = [[self getDbFilePath] UTF8String];
    BOOL isExist = NO;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM meme_table WHERE meme_id=\"%@\"",memeId];
        const char *query_stmt = [querySQL UTF8String];

        
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                isExist = YES;
                break;
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return isExist;
}

-(BOOL) updateCategory:(NSString *)category withMemeID:(NSString *)memeId
{
    BOOL success = false;
    const char *dbpath = [[self getDbFilePath] UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"UPDATE meme_table SET category=\"%@\" WHERE meme_id=\"%@\"",category, memeId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            
            success = true;
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return success;
}

-(NSInteger) getViewCounterWithCategory:(NSString *)category
{
    const char *dbpath = [[self getDbFilePath] UTF8String];
    NSInteger viewCounter = 0;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM meme_table WHERE isViewed=\"1\" AND category=\"%@\"",category];
        const char *query_stmt = [querySQL UTF8String];
        
        
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                viewCounter++;
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return viewCounter;
}

-(NSDictionary *)updateMemeViewsForMemeIds:(NSArray *)memeArray
{
    int everyCount = 0;
    int motivationalCount = 0;
    int racyCount = 0;
    for(NSDictionary *myMeme in memeArray)
    {
        
        if([self isMemeIdExist:[myMeme objectForKey:@"meme_id"]])
        {
            if(![self isViewed:[myMeme objectForKey:@"meme_id"]])
            {
                if([[myMeme objectForKey:@"category_id"] isEqualToString:@"1"])
                {
                    [self updateMemeView:@"1" withMemeID:[myMeme objectForKey:@"meme_id"]];
                    everyCount = everyCount+1;
                }
                else if([[myMeme objectForKey:@"category_id"] isEqualToString:@"2"])
                {
                    [self updateMemeView:@"1" withMemeID:[myMeme objectForKey:@"meme_id"]];
                    motivationalCount = motivationalCount+1;
                }
                else if([[myMeme objectForKey:@"category_id"] isEqualToString:@"3"])
                {
                    [self updateMemeView:@"1" withMemeID:[myMeme objectForKey:@"meme_id"]];
                    racyCount = racyCount+1;
                }
            }
        }
        
    }
    
    
    
    return [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:everyCount],[NSNumber numberWithInt:motivationalCount],[NSNumber numberWithInt:racyCount]] forKeys:@[EVERYONE_MEME,MOTIVATIONAL_MEME,RACY_MEME]];
}

#pragma mark Alert
-(void) showMessage:(NSString*)title withMessage:(NSString*)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
    
}

//-(BOOL) deleteListItem:(NSString *)itemId
//{
//    BOOL success = false;
//    const char *dbpath = [[self getDbFilePath] UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        NSString *querySQL = [NSString stringWithFormat:
//                              @"DELETE FROM list_item_table WHERE item_id=\"%@\"",itemId];
//        const char *query_stmt = [querySQL UTF8String];
//        
//        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            
//            success = true;
//        }
//        
//        sqlite3_finalize(statement);
//        sqlite3_close(database);
//    }
//    
//    return success;
//}

@end





















