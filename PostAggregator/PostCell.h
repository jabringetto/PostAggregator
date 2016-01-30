//
//  PostCell.h
//  PostAggregator
//
//  Created by Jeremy Bringetto on 1/29/16.
//  Copyright © 2016 Jeremy Bringetto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostCell : UITableViewCell

@property (nonatomic) UILabel *cellLabel;
@property (nonatomic) UITextView *cellText;
@property (nonatomic) UIImageView *avatarImageView;

-(void)setAvatarImage:(UIImage*)img;

@end
