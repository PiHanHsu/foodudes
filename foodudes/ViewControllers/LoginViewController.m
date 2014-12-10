//
//  LoginViewController.m
//  foodudes
//
//  Created by PiHan Hsu on 2014/11/19.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import "LoginViewController.h"
#import "SearchViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "User.h"
#import "MBProgressHUD.h"

@interface LoginViewController () <MBProgressHUDDelegate>
{
    MBProgressHUD  *progressHUD;

}


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    // Do any additional setup after loading

    UIImageView *logoImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Logo for login"]];
    
    logoImageView.frame = CGRectMake(0, 0, 280, 210);
    logoImageView.contentMode = UIViewContentModeScaleToFill;
    logoImageView.center = CGPointMake(self.view.center.x, self.view.center.y*0.6);
    
    
    UIButton *loginButton =[[UIButton alloc]init];
    loginButton.frame= CGRectMake(0, 0, 240, 45.75);
    loginButton.center = CGPointMake(self.view.center.x
                                     , self.view.center.y*1.3);
    [loginButton addTarget:self action:@selector(loginButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setImage:[UIImage imageNamed:@"FBLoginButton"] forState:UIControlStateNormal];
    
    [self.view addSubview:logoImageView];
    [self.view addSubview:loginButton];
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:@"loadingDataFinished"
     object:nil
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *notification) {
         if ([notification.name isEqualToString:@"loadingDataFinished"]) {
             NSLog(@"Loading Data Finished!");
             [self _ViewControllerAnimated:YES]; 
         }
     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
    //Check if user is cached and linked to Facebook, if so, bypass login
//    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//    [self _ViewControllerAnimated:YES];
//    }
}
- (void)initializeProgressHUD:(NSString *)msg
{
    if (progressHUD)
        [progressHUD removeFromSuperview];
    
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUD];
    progressHUD.dimBackground = NO;
    progressHUD.delegate = self;
    progressHUD.labelText = msg;
    
    progressHUD.margin = 20.f;
    progressHUD.yOffset = 10.f;
    
    progressHUD.removeFromSuperViewOnHide = YES;
    [progressHUD show:YES];
}

- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"user_friends", @"email"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                User *currentUser = [[User alloc]init];
                [currentUser getUserData];
                [self initializeProgressHUD:@"Loading..."];
                [currentUser saveUserDataToParse];
                
            } else {
                NSLog(@"User with facebook logged in!");
                User *currentUser = [[User alloc]init];
                [currentUser getUserData];
                [self initializeProgressHUD:@"Loading..."];
            }
            //[self _ViewControllerAnimated:YES];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)_ViewControllerAnimated:(BOOL)animated {
  
    UITabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [tabBarVC setSelectedIndex:1];
    [self presentViewController:tabBarVC animated:YES completion:nil];
//    [self.navigationController pushViewController:tabBarVC animated:animated];
}

@end
