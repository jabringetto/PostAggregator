//
//  TableViewController.h
//  PostAggregator
//
//  Created by Jeremy Bringetto on 1/29/16.
//  Copyright © 2016 Jeremy Bringetto . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPCall.h"

@interface TableViewController : UITableViewController <HTTPCallDelegate>

@property (nonatomic) NSDictionary *allData;
@property (nonatomic) NSArray *allPosts;
@property (nonatomic) NSArray *cellHeights;
@property (nonatomic) NSArray *avatarURLs;
@property (nonatomic) NSMutableDictionary *avatarImages;
@property (nonatomic) NSOperationQueue *q;


-(void)apiCall;

@end
