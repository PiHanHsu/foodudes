//
//  ProfileViewController.m
//  foodudes
//
//  Created by PiHan Hsu on 2014/11/19.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ProfileViewController ()

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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logoutButtonPressed:(id)sender {
    
    [PFUser logOut];
    
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];

    
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
