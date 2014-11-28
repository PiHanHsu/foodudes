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

@interface ProfileViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *dataArray;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *name = [PFUser currentUser][@"profile"][@"name"];
    if (name) {
        self.displayNameLabel.text = name;
    }

    NSString *userProfilePhotoURLString = [PFUser currentUser][@"profile"][@"pictureURL"];
    // Download the user's facebook profile picture
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       self.headImageView.image = [UIImage imageWithData:data];
                                       // Add a nice corner radius to the image
                                       self.headImageView.layer.cornerRadius = 50.0f;
                                       self.headImageView.layer.masksToBounds = YES;
                                       
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];
        
}
    
    UILabel *numOfFriends = [[UILabel alloc]initWithFrame:CGRectMake(30, 170, 200, 35)];
    numOfFriends.text = [NSString stringWithFormat:@"朋友數： %i",5];
    
    UILabel *numOfRestaurant = [[UILabel alloc]initWithFrame:CGRectMake(self.view.center.x, 170, 200, 35)];
    numOfRestaurant.text = [NSString stringWithFormat:@"推薦餐廳數： %i", 10];
    [self.view addSubview: numOfFriends];
    [self.view addSubview:numOfRestaurant];

    
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadObjects) forControlEvents:UIControlEventValueChanged];
    [self.friendsTableView addSubview:self.refreshControl];
    [self loadObjects];
    }
#pragma tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    } else {
        NSLog(@"I have been initialize. Row = %li", (long)indexPath.row);
    }
    
    NSDictionary *eachDictionaryInfo = [self.dataArray objectAtIndex:indexPath.row];
    NSDictionary *profileDictionary = [eachDictionaryInfo objectForKey:@"profile"];
    
    
    NSString *userProfilePhotoURLString = [profileDictionary objectForKey:@"pictureURL"];
    // Download the user's facebook profile picture
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError == nil && data != nil) {
                                       
                                       cell.textLabel.text = [profileDictionary objectForKey:@"name"];
                                       cell.detailTextLabel.text = [profileDictionary objectForKey:@"email"];

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

- (void)loadObjects {
    
    [self.refreshControl beginRefreshing];
     PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
      self.dataArray = [results mutableCopy];
      [self.friendsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    [self.refreshControl endRefreshing];
    
    

    
    
}

- (IBAction)getToken:(id)sender {
    NSString *token =[FBSession activeSession].accessTokenData.accessToken;
    NSLog(@"FB token: %@" ,token);
}

#pragma logout

- (IBAction)logoutButtonPressed:(id)sender {
    
    [PFUser logOut];
    
    // Return to login view controller
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
    LoginViewController * rootVC =[self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:rootVC animated:YES completion:nil];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
