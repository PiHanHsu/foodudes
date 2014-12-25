//
//  ProfileViewController.m
//  foodudes
//
//  Created by PiHan Hsu on 2014/11/19.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"
#import "userMarkerView.h"

@interface ProfileViewController ()<UITableViewDataSource, UITableViewDelegate>

@property UIImageView * headImageView;

@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property(strong, nonatomic) NSString * mobileID;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   //  Show data from Parse
    
    NSString *name = [PFUser currentUser][@"profile"][@"name"];
    if (name) {
        self.displayNameLabel.text = name;
        self.displayNameLabel.textColor = [UIColor whiteColor];
        self.displayNameLabel.font = [UIFont systemFontOfSize:30];
        
    }

    NSString *userProfilePhotoURLString = [PFUser currentUser][@"profile"][@"pictureURL"];
    // Download the user's facebook profile picture
    
    self.headImageView =  [[UIImageView alloc]initWithFrame:CGRectMake(10, 72, 100, 100)];
    
    NSLog(@"URL: %@", userProfilePhotoURLString);
    
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       self.headImageView.image = [UIImage imageWithData:data];
                                      
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
        
}
    UIImageView *background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]
    ;
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = background.bounds;
    [background addSubview:visualEffectView];
    
    
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 600, 200)];
    view1.backgroundColor = [UIColor colorWithRed:58/255.0f green:57/255.0f blue:52/255.0f alpha:.8f];
    
    [self.view insertSubview:view1 atIndex:1];
    
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 600, 60)];
    view2.backgroundColor = [UIColor colorWithRed:246/255.0f green:246/255.0f blue:248/255.0f alpha:1];
    
    [self.view insertSubview:background atIndex:1];

    [view1 addSubview:view2];
    [view2 addSubview:self.headImageView];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    title.text = @"Profile";
    title.center = CGPointMake(self.view.center.x, 40);
    title.textColor = [UIColor blackColor];
    title.font = [UIFont systemFontOfSize:17];
    
    UIButton * logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(140, 145, 100, 45)];
    [logoutButton setImage:[UIImage imageNamed:@"LogoutButton"] forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:title];
    [self.view addSubview:logoutButton];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadObjects) forControlEvents:UIControlEventValueChanged];
    [self.friendsTableView addSubview:self.refreshControl];
    //[self loadObjects];
    //[self loadUseData];
    [self loadUserDataFromLocal];
    
    [self.friendsTableView setBackgroundView:nil];
    [self.friendsTableView setBackgroundColor:[UIColor clearColor]];
    
    self.dataSource = [NSMutableArray arrayWithCapacity:0];

}
#pragma mark loadData from Local

-(void) loadUserDataFromLocal
{
    //取user資料
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectiory =[paths objectAtIndex:0];
    NSString *uploadFile = [NSString stringWithFormat:@"rest.json"];
    
    NSString *filePath = [documentDirectiory stringByAppendingPathComponent:uploadFile];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *rest = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userRecommendCount =[NSString stringWithFormat:@"%@", [defaults objectForKey:@"recommend_count"]];
    UILabel *numOfRestaurant = [[UILabel alloc]initWithFrame:CGRectMake(140, 110, 200, 35)];
                numOfRestaurant.text = [NSString stringWithFormat:@"已推薦%@間餐廳", userRecommendCount];
                numOfRestaurant.textColor = [UIColor grayColor];
                numOfRestaurant.font = [UIFont systemFontOfSize:13];
                [self.view addSubview:numOfRestaurant];
    
    self.dataArray = rest[@"users"];
    NSLog(@"dataArray: %lu", self.dataArray.count);
  
    for (int i =0 ; i< self.dataArray.count; i++) {
        [self.dataSource removeAllObjects];
        
        NSMutableDictionary *friendsInfo = self.dataArray[i];
        
        NSString *userProfilePhotoURLString = [friendsInfo objectForKey:@"image"];
        // Download the user's facebook profile picture
        if (userProfilePhotoURLString) {
            NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
            
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                       if (connectionError == nil && data != nil) {
                                           
                                           UIImageView * friendsImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
                                           friendsImage.image =[UIImage imageWithData:data] ;
                                           friendsImage.layer.cornerRadius = 25.0f;
                                           friendsImage.layer.masksToBounds =YES;
                                           [self.dataSource addObject:friendsImage.image];
                                           
                                           

                                       } else {
                                           NSLog(@"Failed to load profile photo.");
                                       }
                                   }];
        }

    }
    
    
   // [self.friendsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

    
    
    // Add numOfFriends Label
    UILabel *numOfFriends = [[UILabel alloc]initWithFrame:CGRectMake(10, 175, 100, 20)];
    numOfFriends.text = [NSString stringWithFormat:@"%.lu位朋友",self.dataArray.count];
    numOfFriends.textColor = [UIColor lightGrayColor];
    numOfFriends.font = [UIFont systemFontOfSize:13];
    
    [self.view addSubview: numOfFriends];
    


}

#pragma mark tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSLog(@"number of rows: %lu", self.dataArray.count);
    return self.dataArray.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"CodeTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor =[UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font =[UIFont systemFontOfSize:17];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.text = [self.dataArray[indexPath.row] objectForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"推薦餐廳數: %@", [self.dataArray[indexPath.row] objectForKey:@"recommend_count"]];
        
        UIImageView * friendsImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
        friendsImage.layer.cornerRadius = 25.0f;
        friendsImage.layer.masksToBounds =YES;
        friendsImage.backgroundColor = [UIColor grayColor];
 //       friendsImage.image = [self.dataSource[indexPath.row]];
        
        
        [cell.contentView addSubview:friendsImage];
        
        } else {
        //NSLog(@"I have been initialize. Row = %li", (long)indexPath.row);
    }
    
    
    
    NSDictionary *friendsInfo = [self.dataArray objectAtIndex:indexPath.row];
    //NSDictionary *profileDictionary = [eachDictionaryInfo objectForKey:@"profile"];
    
    
    NSString *userProfilePhotoURLString = [friendsInfo objectForKey:@"image"];
    // Download the user's facebook profile picture
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       
                                       cell.textLabel.text = [friendsInfo objectForKey:@"name"];
                                       cell.detailTextLabel.text = [NSString stringWithFormat:@"推薦餐廳數: %@", [friendsInfo objectForKey:@"recommend_count"]];

                                       UIImageView * friendsImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
                                       friendsImage.image =[UIImage imageWithData:data] ;
                                       friendsImage.layer.cornerRadius = 25.0f;
                                       friendsImage.layer.masksToBounds =YES;
                                       
                                       [cell.contentView addSubview:friendsImage];
                                       
                                    } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
    }

    return cell;
}


#pragma mark loadData from Parse
//- (void)loadObjects {
//    
//    [self.refreshControl beginRefreshing];
//     PFQuery *query = [PFUser query];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
//      self.dataArray = [results mutableCopy];
//      [self.friendsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//        }];
//    [self.refreshControl endRefreshing];
//    
//    
//}

#pragma mark logout

- (IBAction)logoutButtonPressed:(id)sender {
    
    [PFUser logOut];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://beta.foodudes.co/"]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mobileID =[NSString stringWithFormat:@"%@", [defaults objectForKey:@"mobile_ID"]] ;
    
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            mobileID,         @"mobile_id",
                            nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"DELETE"
                                                            path:@"api/v1/auth/sign_out"
                                                      parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Completed!");
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error to logout.");
    }];
    
    [operation start];

    LoginViewController * rootVC =[self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:rootVC animated:YES completion:nil];
    
}

#pragma mark loadData from Linode

//-(void)loadUseData
//{
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://106.185.53.8/"]];
//    NSString *token =[FBSession activeSession].accessTokenData.accessToken;
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            token,    @"fb_token"
//                            , nil];
//    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
//                                                            path:@"api/v1/auth/log_in"
//                                                      parameters:params];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        //載入完成
//        NSLog(@"Completed!");
//        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//
//        NSData *rawData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
//        NSError *e;
//        
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&e];
//        //NSLog(@"Data from Fung: %@", dict);
//        NSString *mobileID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"mobile_id"]];
//        self.mobileID = mobileID;
//        NSString *name = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
//        self.displayNameLabel.text = name;
//        
//        // From Linode's DB
//        NSString * imageURLString =[dict objectForKey:@"image"];
//            if (imageURLString) {
//                NSURL *pictureURL = [NSURL URLWithString:imageURLString];
//                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
//                [NSURLConnection sendAsynchronousRequest:urlRequest
//                                                   queue:[NSOperationQueue mainQueue]
//                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                                           if (connectionError == nil && data != nil) {
//                                               self.headImageView.image = [UIImage imageWithData:data];
//                                               // Add a nice corner radius to the image
//                                               self.headImageView.layer.cornerRadius = 50.0f;
//                                               self.headImageView.layer.masksToBounds = YES;
//        
//                                               
//                                               
//                                           } else {
//                                               NSLog(@"Failed to load profile photo.");
//                                           }
//                                       }];
//                }
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error");
//    }];
//    [operation start];
//    
//}
//
//



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
