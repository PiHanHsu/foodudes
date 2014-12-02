//
//  SearchViewController.m
//  foodudes
//
//  Created by PiHan Hsu on 2014/11/19.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import "SearchViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "infoWindowView.h"

@interface SearchViewController ()
@property UISearchBar *searchBar;
@property UIView *infoView;
@property(nonatomic,strong) UIDynamicAnimator *animator;

@end

@implementation SearchViewController{
    GMSMapView * mapView;
}
@synthesize gs;

#pragma view Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:25.023868
                                                            longitude:121.528976
                                                                 zoom:15];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height);
    mapView.myLocationEnabled = YES;
    mapView.delegate = self;
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 30)];
    self.searchBar.showsSearchResultsButton=YES;
    self.searchBar.searchBarStyle = UIBarStyleDefault;
    self.searchBar.placeholder=@"輸入地點,例如：北投、淡水...";
    self.searchBar.delegate=self;
    
    [self.view addSubview:self.searchBar];
    [self.view insertSubview:mapView atIndex:0];
    gs = [[GCGeocodingService alloc] init];
    [self lodaData];
    [self loadDateForInfoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(25.023868, 121.528976);
    //marker.title = @"Pasta Paradise";
    //marker.snippet = @"Good restaurant!!";
    marker.icon =[UIImage imageNamed:@"Pihan_Marker80"];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = mapView;
}


#pragma SearchBar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    NSLog(@"%@", self.searchBar.text);
    [gs geocodeAddress:self.searchBar.text];
    [self addMarker];
    self.searchBar.text=@"";
    self.searchBar.placeholder=@"輸入地點,例如：北投、淡水...";

}

- (void)addMarker{
    double lat = [[gs.geocode objectForKey:@"lat"] doubleValue];
    double lng = [[gs.geocode objectForKey:@"lng"] doubleValue];
    GMSMarker *options = [[GMSMarker alloc] init];
    options.position = CLLocationCoordinate2DMake(lat, lng);
    options.title = [gs.geocode objectForKey:@"address"];
    options.appearAnimation= kGMSMarkerAnimationPop;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat                                                                longitude:lng                                                        zoom:15];
    [mapView setCamera:camera];
    options.map=mapView;
}


#pragma loadData
-(void)lodaData{
    
    PFQuery *query = [PFQuery queryWithClassName:@"userRecommendData"];
    //[query whereKey:@"userName" equalTo:@"PiHan Hsu"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            for (PFObject *object in objects) {
                //NSLog(@"%@", object[@"lat"]);
                //NSLog(@"%@", object[@"lng"]);
                double lat = [object[@"lat"] doubleValue];
                double lng = [object[@"lng"] doubleValue];
                
                GMSMarker * markers = [[GMSMarker alloc]init];
                markers.position = CLLocationCoordinate2DMake(lat, lng);
                if([object[@"userName"] isEqualToString:@"PiHan Hsu"]){
                    markers.icon = [UIImage imageNamed:@"Pihan_Marker80"];
                    
                }else{
                 markers.icon = [UIImage imageNamed:@"Fung_Marker80"];
                }
                // load image from parse
                /*
                 PFUser *currentUser = [PFUser currentUser];
                 PFFile *imageFile =currentUser[@"FBHeadImage"];
                 NSData *imagedata = [imageFile getData];
                 markers.icon =[UIImage imageWithData:imagedata];
                 */
                markers.map = mapView;
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

#pragma markers

- (BOOL)mapView:(GMSMapView *)mapView1 didTapMarker:(GMSMarker *)marker
{
    CGPoint point = [mapView1.projection pointForCoordinate:marker.position];
    point.y = point.y - 120;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[mapView1.projection coordinateForPoint:point]];
    [mapView1 animateWithCameraUpdate:camera];
    
    mapView1.selectedMarker = marker;
//    infoWindowView *view =  [[[NSBundle mainBundle] loadNibNamed:@"infoWindowView" owner:self options:nil] objectAtIndex:0];
//
//    self.infoView = view;
//     view.center = CGPointMake(self.view.center.x, self.view.center.y-70);
//     view.layer.cornerRadius = 10.0f;
//     view.layer.masksToBounds = YES;
    [self loadDateForInfoView];
    [mapView1 addSubview:self.infoView];
    //[self.view addSubview:self.infoView];
    //[self willShow];

    return YES;
}
- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    //self.infoView.hidden =YES;
    [self viewDismiss];
    [self.searchBar resignFirstResponder];

}

#pragma loadData for InfoWindow
-(void) loadDateForInfoView
{
    infoWindowView *view =  [[[NSBundle mainBundle] loadNibNamed:@"infoWindowView" owner:self options:nil] objectAtIndex:0];
    
    self.infoView = view;
    view.center = CGPointMake(self.view.center.x, self.view.center.y-70);
    view.layer.cornerRadius = 10.0f;
    view.layer.masksToBounds = YES;
    
    
}

#pragma Animation
-(void)willShow {
    // Use UIKit Dynamics to make the alertView appear.
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self.infoView snapToPoint:CGPointMake(self.view.center.x, self.view.center.y-70)];
    //控制下落速度,數字越大越慢
    snapBehaviour.damping = .8f;
    [self.animator addBehavior:snapBehaviour];
    
}

-(void)viewDismiss {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.infoView]];
    //控制方向與速度. 0.0f -->正下方, 10.0f 速度 （數字越大越快）
    gravityBehaviour.gravityDirection = CGVectorMake(0.0f, 10.0f);
    [self.animator addBehavior:gravityBehaviour];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.infoView]];
    //控制轉動程度,2.0f-->數字越大轉動越大
    [itemBehaviour addAngularVelocity:2.0f forItem:self.infoView];
    [self.animator addBehavior:itemBehaviour];
    
    
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
