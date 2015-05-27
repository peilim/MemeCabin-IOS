//
//  MCHTTPManager.m
//  MemeCabin
//
//  Created by Himel on 12/2/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "MCHTTPManager.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation MCHTTPManager

+(instancetype)manager
{
    static dispatch_once_t pred;
    static MCHTTPManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[MCHTTPManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        
        AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer new];
        serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
        shared.responseSerializer = serializer;
        
        shared.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:MEMECABIN_DOMAIN_URL];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    });
    return shared;
}

//------------------------------------------------------
#pragma mark - Overrides
//------------------------------------------------------

-(AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    return [super GET:URLString parameters:parameters success:(^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"Response = %@",responseObject);
        [self processSuccessResponse:responseObject
                        forOperation:operation
                             success:success
                             failure:failure];
    }) failure:failure];
}

-(AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    return [super POST:URLString parameters:parameters constructingBodyWithBlock:block success:(^(AFHTTPRequestOperation *operation, id responseObject){
        [self processSuccessResponse:responseObject
                        forOperation:operation
                             success:success
                             failure:failure];
    }) failure:failure];
}

-(AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    return [super POST:URLString parameters:parameters success:(^(AFHTTPRequestOperation *operation, id responseObject){
        [self processSuccessResponse:responseObject
                        forOperation:operation
                             success:success
                             failure:failure];
    }) failure:failure];
}

//------------------------------------------------------
#pragma mark - Private Utils
//------------------------------------------------------

-(void) processSuccessResponse:(id) responseObject
                  forOperation:(AFHTTPRequestOperation *) operation
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    BOOL handled = NO;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        if (responseObject[@"status"]
            && ![responseObject[@"status"] isKindOfClass:[NSNull class]]
            && [responseObject[@"status"] intValue] > 0)
        {
            handled = YES;
            
            // Adopt base url into result
            id finalResponse = nil;
            
            if (responseObject[@"result"]
                && responseObject[@"base_url"]) {
                id result = [self addingBaseUrl:responseObject[@"base_url"] toResult:responseObject[@"result"]];
                NSMutableDictionary *fixedResponse = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                fixedResponse[@"result"] = result;
                finalResponse = [fixedResponse copy];
            }
            else finalResponse = responseObject;
            
            
            success(operation, finalResponse);
        }
        else if(responseObject[@"message"]
                && [responseObject[@"message"] isKindOfClass:[NSString class]]){
            handled = YES;
            failure(operation, [NSError errorWithDomain:@"AAPBD-API" code:123 userInfo:@{NSLocalizedDescriptionKey:responseObject[@"message"]}]);
        }
    }
    
    if (!handled) {
        failure(operation, [NSError errorWithDomain:@"AAPBD-API" code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"%@", responseObject]}]);
    }
}

-(id) addingBaseUrl:(NSString *) url toResult:(id) result {
    if ([result isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dictionary in result) {
            NSMutableDictionary *mDic = [dictionary mutableCopy];
            mDic[@"base_url"] = url;
            [array addObject:[mDic copy]];
        }
        return [array copy];
    } else if ([result isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *mDic = [result mutableCopy];
        mDic[@"base_url"] = url;
        return [mDic copy];
    } else {
        return result;
    }
}

@end
