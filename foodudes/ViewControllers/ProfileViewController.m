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
                                       
                                       
                                       //Try to put the head to customMarker, not work yet!
                                       
                                       /*
                                        CustomMarker *userMarker = [CustomMarker customView] ;
                                        userMarker.markerView.image= [UIImage imageWithData:data];
                                        self.headImageView.image =userMarker.markerImage;
                                        */
                                       
                                       //Save FB image to Parse. Done!
                                       /*
                                        NSData *imageData = UIImageJPEGRepresentation(userMarker.markerImage, 0);
                                        PFFile *imageFile = [PFFile fileWithName:@"userMarker.png" data:imageData];
                                        PFUser *currentUser =[PFUser currentUser];
                                        currentUser[@"userMarker"] =imageFile;
                                        [currentUser saveInBackground];
                                        */
                                       
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                               }];

}
}
#pragma tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
    
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
    static NSString *requestIdentifier = @"HelloCell";
    static NSString *requestIdentifier2 = @"HelloCell2";
    
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:{
            cell = [tableView dequeueReusableCellWithIdentifier:requestIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:requestIdentifier];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.detailTextLabel.textColor = [UIColor colorWithRed:241.0f/255.0f green:244.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
                cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size: 20.f];
                cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-LightOblique" size: 12.f];
                
            }
        }
            break;
        case 1:{
            cell = [tableView dequeueReusableCellWithIdentifier:requestIdentifier2];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:requestIdentifier2];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.detailTextLabel.textColor = [UIColor colorWithRed:241.0f/255.0f green:244.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
                cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size: 20.f];
                cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-LightOblique" size: 12.f];
                
            }
        }
        default:
            break;
    }
    /*
    cell.textLabel.text = dataSource [indexPath.row];
    cell.detailTextLabel.text = detailDataSource [indexPath.row];
    
    NSString *title;
    switch (indexPath.section) {
        case 0:
            title = @"download";
            break;
        case 1:
            title =@"upload";
            break;
            
        default:
            break;
    }
    
    UIButton *button= [[ UIButton alloc] initWithFrame:CGRectMake(220, 15, 80, 30)];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size: 14.f];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.tag =indexPath.row;
    //button.layer.cornerRadius = 25.0f;
    [button.layer setCornerRadius:4.0f];
    [button.layer setBorderColor:[[UIColor whiteColor]CGColor]];
    [button.layer setBorderWidth:1.0f];
    [cell.contentView addSubview:button];
    */
    return cell;
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
