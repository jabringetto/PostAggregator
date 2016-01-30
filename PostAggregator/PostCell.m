//
//  PostCell.m
//  PostAggregator
//
//  Created by Jeremy Bringetto on 1/29/16.
//  Copyright © 2016 Jeremy Bringetto. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell
@synthesize cellLabel;
@synthesize cellText;

- (void)awakeFromNib
{

    cellLabel = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 5.0,300.0, 20.0)];
    cellLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:15.0];
    UIColor *subtleColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.55 alpha:1];
    cellLabel.textColor = subtleColor;
    [self.contentView addSubview:cellLabel];
    NSInteger MAX_HEIGHT = 2000;
    cellText = [[UITextView alloc]initWithFrame:CGRectMake(8.0, 22.0,300.0, MAX_HEIGHT)];
    cellText.userInteractionEnabled = NO;
    cellText.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:cellText];
    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0,1.0,1.0,1.0)];
    [self.contentView addSubview:_avatarImageView];
}
-(void)setAvatarImage:(UIImage*)img
{
    [_avatarImageView setFrame:CGRectMake(10.0, 5.0,img.size.width,img.size.height)];
     
     //[[UIImageView alloc] initWithFrame:CGRectMake(10.0, 5.0,img.size.width,img.size.height)];
    _avatarImageView.image = img;
    CGRect labelFrame = cellLabel.frame;
    labelFrame.origin.x = 35.0;
    [cellLabel setFrame:labelFrame];
    [self reloadInputViews];
    
}

@end
