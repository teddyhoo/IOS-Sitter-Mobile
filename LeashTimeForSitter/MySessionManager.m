//
//  MySessionManager.m
//  LeashTimeMobileSitter2
//
//  Created by Ted Hooban on 8/13/15.
//  Copyright (c) 2015 Ted Hooban. All rights reserved.
//

#import "MySessionManager.h"

@implementation MySessionManager

#if DEBUG
static NSString *kBaseUrl = @"http://testapi.myapp.com/v1/";
#else
static NSString *kBaseUrl = @"https://api.myapp.com/v1/";
#endif
#define kErrorResponseObjectKey @"kErrorResponseObjectKey"



+ (instancetype)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    });
    return instance;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *, id, NSError *))originalCompletionHandler {
    return [super dataTaskWithRequest:request
                    completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                        
                        // If there's an error, store the response in it if we've got one.
                        if (error && responseObject) {
                            if (error.userInfo) { // Already has a dictionary, so we need to add to it.
                                NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                                userInfo[kErrorResponseObjectKey] = responseObject;
                                error = [NSError errorWithDomain:error.domain
                                                            code:error.code
                                                        userInfo:[userInfo copy]];
                            } else { // No dictionary, make a new one.
                                error = [NSError errorWithDomain:error.domain
                                                            code:error.code
                                                        userInfo:@{kErrorResponseObjectKey: responseObject}];
                            }
                        }
                        
                        // Call the original handler.
                        if (originalCompletionHandler) {
                            originalCompletionHandler(response, responseObject, error);
                        }
                    }];
}



@end
