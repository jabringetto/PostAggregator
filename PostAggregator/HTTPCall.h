//
//  HTTPCall.h
//  Team Rosters
//
//  Created by Jeremy Bringetto - Vendor on 1/8/16.
//  Copyright © 2016 Stephane Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HTTPCallDelegate <NSObject>

-(void)httpCallResponse:(NSDictionary*)httpResponse;

@end

@interface HTTPCall : NSObject <NSURLSessionDelegate>

@property (nonatomic, weak) id <HTTPCallDelegate> delegate;

-(instancetype)initWithSessionAndURL:(NSString*)urlString method:(NSString*)httpMethod body:(NSDictionary*)postBody;

@end
