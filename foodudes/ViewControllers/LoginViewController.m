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

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    // Do any additional setup after loading 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
    [self _ViewControllerAnimated:NO];
    }
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
                
            } else {
                NSLog(@"User with facebook logged in!");
                //NSLog(@" user info %@", user.description);
                //user.email=[PFUser currentUser][@"profile"][@"email"];
                //user[@"name"]=[PFUser currentUser][@"profile"][@"name"];
                //user[@"gender"]=[PFUser currentUser][@"profile"][@"gender"];
                //user[@"birthday"]=[PFUser currentUser][@"profile"][@"birthday"];
                
                
            }
            [self _ViewControllerAnimated:YES];
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
