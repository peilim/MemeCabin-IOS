//
//  Photo.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 11/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "MemePhoto.h"

#import "AFNetworking.h"

@implementation MemePhoto

@synthesize photoID,
            photoTitle,
            photoCategory,
            photoLike,
            photoStatus,
            photoUploadby,
            photoUploaddate,
            photoViewCount,
            url,
            baseURL,
            thumb100BaseURL,
            thumb250BaseURL,
            totalMeme,
            thumb100URL,
            thumb250URL,
            photoURL,
            allLike,
            daytotalLike,
            daySeventotalLike,
            dayThirtytotalLike,
            dayNinetytotalLike,
            isLiked,
            isViewed,
            isFavourite,
            syncStatus,
            photoMyFavorite,photoMyLike;


+(NSMutableArray *)loadImagesWithURL:(NSString *)url
{
    NSMutableArray *photoArray = [NSMutableArray array];
    
    NSString *urlString = url;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = nil;//@{@"email": email, @"password": password, @"type": @"normal"};
    
    
    //[SVProgressHUD show];
    
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Sample logic to check login status
        
        //NSString *errorMessage = nil;
        
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        //[spinner stopAnimating];
        //[SVProgressHUD dismiss];
        
        NSError *error = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"Error serializing %@", error);
        }
        else
        {
            if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
            {
                NSLog(@"base_url = %@",[JSON objectForKey:@"base_url"]);
                
                NSArray *listArray = [JSON objectForKey:@"result"];
                for (NSDictionary *listDic in listArray)
                {
                    
                    MemePhoto *photo = [[MemePhoto alloc] init];
                    
                    photo.photoID = [listDic objectForKey:@"id"];
                    photo.photoCategory = [listDic objectForKey:@"category"];
                    photo.url = [listDic objectForKey:@"url"];
                    photo.photoUploadby = [listDic objectForKey:@"upload_by"];
                    photo.photoUploaddate = [listDic objectForKey:@"upload_date"];
                    photo.photoLike = [listDic objectForKey:@"like"];
                    photo.photoViewCount = [listDic objectForKey:@"view"];
                    photo.baseURL = [JSON objectForKey:@"base_url"];
                    photo.photoStatus = [listDic objectForKey:@"status"];
                    
                    photo.photoURL = [photo.baseURL stringByAppendingString:photo.url];
                    
                    [photoArray addObject:photo];
                    
                }
                
                NSLog(@"photoArray.count%lu",(unsigned long)photoArray.count);
                
            }
            
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //[spinner stopAnimating];
        //[SVProgressHUD dismiss];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed!" message:@"connection error!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    return photoArray;
}

@end
