//
//  YO.m
//  YO
//
//  Created by yiqin on 7/26/14.
//  Copyright (c) 2014 yiqin. All rights reserved.
//

#import "YO.h"
#import "dispatch/dispatch.h"

static NSString *YOKey;

@implementation YO

+ (void)startWithAPIKey:(NSString *)APIKey
{
    YOKey = APIKey;
}

+ (void)sendYO
{
    NSString *API_KEY = YOKey;
    NSURL *url = [NSURL URLWithString:@"http://api.justyo.co/yoall/"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary *mapData = @{@"api_token": API_KEY};
    NSError *error = [[NSError alloc] init];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        int statusCode = [(NSHTTPURLResponse*) response statusCode];
        if (statusCode == 201) {
            NSLog(@"SUCCESS: Send A Yo to all subscribers.");
        }
        else {
            NSLog(@"FAIL");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(sendYO) userInfo:nil repeats:NO];
            });
        }
    }];
    
    [postDataTask resume];
}

+ (void)sendYOToIndividualUser:(id)username_
{
    NSString *API_KEY = YOKey;
    NSURL *url = [NSURL URLWithString:@"http://api.justyo.co/yo/"];
    
    NSString *username = [[NSString alloc] init];
    if ([username_ isKindOfClass:[NSString class]]) {
        username = username_;
    }
    else {
        username = [[username_ userInfo] objectForKey:@"username"];
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary *mapData = @{@"api_token": API_KEY,
                              @"username" : username};
    NSError *error = [[NSError alloc] init];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        int statusCode = [(NSHTTPURLResponse*) response statusCode];
        if (statusCode == 201) {
            NSLog(@"SUCCESS: Send A Yo to %@", username);
        }
        else {
            NSLog(@"FAIL");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                NSDictionary *userInfo = @{@"username": username};
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(sendYOToIndividualUser:) userInfo:userInfo repeats:NO];
            });
        }
    }];
    
    [postDataTask resume];
}

+ (void) countTotalSubscribers
{
    NSString *API_KEY = YOKey;
    NSString *tempURL = [NSString stringWithFormat:@"http://api.justyo.co/subscribers_count/?api_token=%@", API_KEY];
    NSURL *url = [NSURL URLWithString:tempURL];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        int statusCode = [(NSHTTPURLResponse*) response statusCode];
        if (statusCode == 200) {
            NSError* errorJSON;
            NSDictionary* responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
            NSLog(@"SUCCESS: Count total subscribers, %@", [responseJSON objectForKey:@"result"]);
        }
        else {
            NSLog(@"FAIL");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(sendYO) userInfo:nil repeats:NO];
            });
        }
    }];
    
    [getDataTask resume];
}




@end