//
//  TableViewController.m
//  PostAggregator
//
//  Created by Jeremy Bringetto on 1/29/16.
//  Copyright © 2016 Jeremy Bringetto. All rights reserved.
//

#import "TableViewController.h"
#import "PostCell.h"


@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self apiCall];
    [self configureView];
}
-(void)configureView
{
    UIRefreshControl  *refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.95 alpha:1]];
   
     
     
     NSDictionary *a            = @{
                                  NSUnderlineStyleAttributeName: @1,
                                  NSForegroundColorAttributeName : [UIColor colorWithRed:0.25 green:0.25 blue:0.35 alpha:1],
                                  NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:17]
                                  };
    
     [self.navigationController.navigationBar setTitleTextAttributes:a];
    self.navigationItem.title = @"Latest Posts";
}

#pragma mark - HTTPCall delegate, API call & response.

-(void)apiCall
{
    NSString *uri = @"https://alpha-api.app.net/stream/0/posts/stream/global";
    HTTPCall *httpCall = [[HTTPCall alloc]initWithSessionAndURL:uri method:@"GET" body:nil];
    httpCall.delegate = self;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
-(void)httpCallResponse:(NSDictionary*)httpResponse;
{
   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    BOOL isADict = [httpResponse isKindOfClass:[NSDictionary class]];
    
    if(httpResponse && isADict)
    {
        NSData *data = httpResponse[@"data"];
        
        _allData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(_allData)
        {
             [self sortAndParsePostData:_allData];
        }
    }
}
-(void)sortAndParsePostData:(NSDictionary*)allData
{
    NSSortDescriptor* timeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:timeDescriptor];
    _allPosts = [allData[@"data"] sortedArrayUsingDescriptors:sortDescriptors];
   
    NSMutableArray *cellHeightsMutable = [[NSMutableArray alloc]init];
    NSMutableArray *avatarURLsMutable = [[NSMutableArray alloc]init];
    
    for (NSDictionary *d in _allPosts)
    {
        CGFloat rowHeight = [self heightForTextView:d[@"text"]];
        NSNumber *n = [NSNumber numberWithFloat:rowHeight];
        [cellHeightsMutable addObject:n];
        NSString *imgURL = d[@"user"][@"avatar_image"][@"url"];
        if(imgURL)
        {
             [avatarURLsMutable addObject:imgURL];
        }
        else
        {
            [avatarURLsMutable addObject:@""];
        }
       
    }
    _cellHeights = [cellHeightsMutable copy];
    _avatarURLs = [avatarURLsMutable copy];
    
    [self.tableView reloadData];
    if(!_avatarImages)
    {
        _avatarImages = [[NSMutableDictionary alloc]init];
    }
    [self loadAvatarImages];
}

#pragma mark - refresh control

-(void)refresh:(UIRefreshControl*)refreshCntrl
{
    [refreshCntrl endRefreshing];
    [self apiCall];
}
#pragma mark - fetching the avatar images

-(void)loadAvatarImages
{
    _q = [[NSOperationQueue alloc]init];
    _q.maxConcurrentOperationCount = 1;
    for (NSString *url in _avatarURLs)
    {
        BOOL avatarAlreadyLoaded = [[_avatarImages allKeys]containsObject:url];
        
        if(!avatarAlreadyLoaded)
        {
            NSOperation *op = [self taskWithData:url];
            [_q addOperation:op];
        }
     
    }
}

- (NSOperation*)taskWithData:(NSString*)url
{
    
    NSInvocationOperation* getImage = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchAndResizeImage:) object:url];
    
    return getImage;
}


- (void)fetchAndResizeImage:(NSString*)urlString
{
    if(urlString && [urlString isKindOfClass:[NSString class]])
    {

        NSURL *url = [NSURL URLWithString:urlString];
        NSData *imgData = [NSData dataWithContentsOfURL:url];
        UIImage *rawImage = [UIImage imageWithData:imgData];
        CGSize newSize = CGSizeMake(20.0, 20.0);
        UIGraphicsBeginImageContext(newSize);
        [rawImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [_avatarImages setObject:newImage forKey:urlString];
        __weak __typeof__(self) weakSelf = self;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [weakSelf.tableView reloadData];
        }];
    }
}


#pragma mark - Table view data source:

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_allPosts count];
}


- (PostCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[PostCell alloc]init];
    }
    NSString *name = [_allPosts objectAtIndex:indexPath.row][@"user"][@"name"];
    if(!name)
    {
        name = [_allPosts objectAtIndex:indexPath.row][@"user"][@"username"];
    }
    
    cell.cellLabel.text = name;
    cell.cellText.text = [_allPosts objectAtIndex:indexPath.row][@"text"];
    
    cell.backgroundColor = cell.cellText.backgroundColor =[UIColor whiteColor];
    if (indexPath.row % 2 != 0)
    {
        cell.backgroundColor = cell.cellText.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.99 alpha:1];
    }
    NSString *imgURL = [_avatarURLs objectAtIndex:indexPath.row];
    BOOL urlNotEmptyString = ![imgURL isEqualToString:@""];
    if(urlNotEmptyString)
    {
        UIImage *avatar = [_avatarImages objectForKey:imgURL];
        if(avatar)
        {
            [cell setAvatarImage:avatar];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate:


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[_cellHeights objectAtIndex:indexPath.row]floatValue];
}

-(CGFloat)heightForTextView:(NSString *)text
{
    NSInteger MAX_HEIGHT = 2000;
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(8.0, 22.0,300.0, MAX_HEIGHT)];
    textView.text = text;
    [textView sizeToFit];
    return textView.frame.size.height + 20.0;
}



@end
