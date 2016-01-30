//
//  HTTPCall.m
//  Team Rosters
//
//  Created by Jeremy Bringetto - Vendor on 1/8/16.
//  Copyright © 2016 Stephane Nguyen. All rights reserved.
//

#import "HTTPCall.h"
NSURLSession *session;

@implementation HTTPCall


-(instancetype)initWithSessionAndURL:(NSString*)urlString method:(NSString*)httpMethod body:(NSDictionary*)postBody
{
    self = [super init];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    config.timeoutIntervalForResource = 60.0;
    session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url];
    NSData *postData;
    
    if(httpMethod)
    {
       [req setHTTPMethod:httpMethod];
    }
    BOOL isAPut = [httpMethod isEqualToString:@"PUT"];
    BOOL isAPost = [httpMethod isEqualToString:@"POST"];
    BOOL putOrPost = isAPut || isAPost;
    if(postBody)
    {
       NSError *error;
       postData = [NSJSONSerialization dataWithJSONObject:postBody options:0 error:&error];
    }
    if(postData && putOrPost)
    {
        [req addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [req setHTTPBody:postData];
    }
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          dispatch_async(dispatch_get_main_queue(),^{
                                              
                                              __weak __typeof(self)weakSelf = self;
                                              [weakSelf respondToDelegate:data:response:error];
                                              
                                          });
                                          
                                      }];
    [dataTask resume];
    
    return self;
}
-(void)respondToDelegate:(NSData*)data :(NSURLResponse*)response :(NSError*)error
{
    NSMutableDictionary *httpResponse = [[NSMutableDictionary alloc]init];
    if(data)
    {
         [httpResponse setObject:data forKey:@"data"];
    }
    if(response)
    {
        [httpResponse setObject:response forKey:@"response"];
    }
    if(error)
    {
            [httpResponse setObject:error forKey:@"error"];
    }
    if([[httpResponse allKeys]count] > 0)
    {
        [_delegate httpCallResponse:[httpResponse copy]];
        
    }
    [session finishTasksAndInvalidate];
}

@end
