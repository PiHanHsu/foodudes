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
#import "AFNetworking.h"
#import "User.h"

@interface SearchViewController ()
@property UISearchBar *searchBar;
@property UIView *infoView;

@property NSDictionary *restaurantDict;
@property NSArray *restaurantArray;

@property NSString * restaurantID;
@property NSString * restaurantName;
@property NSString * restaurantAddress;
@property NSString * restaurantTel;

@property(nonatomic,strong) UIDynamicAnimator *animator;

@property(strong, nonatomic) NSString * mobileID;

@end

@implementation SearchViewController{
    GMSMapView * mapView;
}
@synthesize gs;

#pragma view Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GMSCameraPosition *camera = [GMSCameraPosition  cameraWithLatitude:25.023868
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
    //[self lodaDataFromParse];
    [self loadData];
    //[self loadDateForInfoView];
    
    User * currentUser = [[User alloc]init];
    //[currentUser getUserData];
    //[currentUser getRestData];
    //[self loadUserData];
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
    marker.icon =[UIImage imageNamed:@"pin"];
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

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.infoView removeFromSuperview];
    return YES;
    
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


#pragma loadData from Parse

//-(void)lodaDataFromParse{
//
//    PFQuery *query = [PFQuery queryWithClassName:@"userRecommendData"];
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            // The find succeeded.
//            // Do something with the found objects
//            for (PFObject *object in objects) {
//                //NSLog(@"%@", object[@"lat"]);
//                //NSLog(@"%@", object[@"lng"]);
//                double lat = [object[@"lat"] doubleValue];
//                double lng = [object[@"lng"] doubleValue];
//                
//                GMSMarker * markers = [[GMSMarker alloc]init];
//                markers.position = CLLocationCoordinate2DMake(lat, lng);
//                if([object[@"userName"] isEqualToString:@"PiHan Hsu"]){
//                    markers.icon = [UIImage imageNamed:@"Pihan_Marker80"];
//                    
//                }else{
//                 markers.icon = [UIImage imageNamed:@"Fung_Marker80"];
//                }
//                // load image from parse
//                /*
//                 PFUser *currentUser = [PFUser currentUser];
//                 PFFile *imageFile =currentUser[@"FBHeadImage"];
//                 NSData *imagedata = [imageFile getData];
//                 markers.icon =[UIImage imageWithData:imagedata];
//                 */
//                markers.map = mapView;
//            }
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
//
//}
//

//#pragma loaddata from local
//-(void) loadUserData
//{
//    //取資料
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectiory =[paths objectAtIndex:0];
//    NSString *uploadFile = [NSString stringWithFormat:@"user.json"];
//    
//    NSString *filePath = [documentDirectiory stringByAppendingPathComponent:uploadFile];
//    NSData *data = [NSData dataWithContentsOfFile:filePath];
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//    
//    NSLog(@"json: %@", json);
//    
//    NSString *mobileID = [NSString stringWithFormat:@"%@", [json objectForKey:@"mobile_id"]];
//    self.mobileID = mobileID;
//    NSLog(@"mobileID: %@", mobileID);
//    
//    [self loadRestData];
//}
//
////still can't loadRestData
//-(void) loadRestData
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectiory =[paths objectAtIndex:0];
//    NSString *uploadFile = [NSString stringWithFormat:@"rest.json"];
//    
//    NSString *filePath = [documentDirectiory stringByAppendingPathComponent:uploadFile];
//    NSData *data = [NSData dataWithContentsOfFile:filePath];
//    NSDictionary *rest = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//    
//    NSLog(@"rest: %@", rest);
//
//}

#pragma lodaData from Linode
-(void)loadData
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://106.185.53.8/"]];
    NSString *token =[FBSession activeSession].accessTokenData.accessToken;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            token,    @"fb_token"
                            , nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@"api/v1/auth/log_in"
                                                      parameters:params];
   
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
 
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
#pragma mark - progressed 完成
        //載入完成
        NSLog(@"Completed!");
        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //test log
        //NSLog(@"Response: %@",tmp);
#pragma mark - 轉資料11/26
        NSData *rawData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"Data from Fung: %@", dict);
        NSString *mobileID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"mobile_id"]];
        self.mobileID = mobileID;
        [self loadRestaurntData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error");
    }];
    
    //4. Start傳輸
    [operation start];

}
-(void) loadRestaurntData
{
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://106.185.53.8/"]];
    
    NSString * mobileID = self.mobileID;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            mobileID,    @"mobile_id"
                            , nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:@"api/v1/maps/index"
                                                      parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Completed!");
        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSData *rawData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"Query2 Data: %@", dict);
        self.restaurantDict = dict;
        NSString * restaurants = [NSString stringWithFormat:@"%@", [dict objectForKey:@"restaurants"]];
        NSLog(@"Restaurant Data: %@", restaurants);
        
        NSString * users = [NSString stringWithFormat:@"%@", [dict objectForKey:@"users"]];
        NSLog(@"users Data: %@", users);
        
        NSArray * array =[dict objectForKey:@"restaurants"];
        NSLog(@"Name: %@", array[0]);
        NSLog(@"num: %ld", array.count);
        
        for (int i =0; i <array.count; i++) {
            
            self.restaurantName = [array[i] objectForKey:@"name"];
            NSLog(@"restaurantName: %@", self.restaurantName);
            
            
            NSString *market_lat = [array[i] objectForKey:@"marker_lat"];
            double lat = [market_lat doubleValue];
            NSLog(@"lat: %f", lat);
            
            NSString *market_lng = [array[i] objectForKey:@"marker_lng"];
            double lng = [market_lng doubleValue];
            NSLog(@"lng: %f", lng);
            
//            self.restaurantID = [array[i] objectForKey:@"id"];
//            NSLog(@"restaurantID: %@", self.restaurantID);
            
            GMSMarker * markers = [[GMSMarker alloc]init];
            markers.position = CLLocationCoordinate2DMake(lat, lng);
            markers.userData=[NSString stringWithFormat:@"%@",  [array[i] objectForKey:@"id"]];
            
            markers.map = mapView;
        }
   
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error!!!!!");
    }];
    
    [operation start];

}



#pragma markers

- (BOOL)mapView:(GMSMapView *)mapView1 didTapMarker:(GMSMarker *)marker
{
    [self.infoView removeFromSuperview];
    CGPoint point = [mapView1.projection pointForCoordinate:marker.position];
    point.y = point.y - 120;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[mapView1.projection coordinateForPoint:point]];
    [mapView1 animateWithCameraUpdate:camera];
    
    NSLog(@"restaurantID: %@", marker.userData);
    self.restaurantID =marker.userData;
    self.restaurantArray = [self.restaurantDict objectForKey:@"restaurants"];
    
    NSLog(@"self.Array: %@", self.restaurantArray);
    for (int i = 0; i < self.restaurantArray.count; i++) {
        NSDictionary *d =self.restaurantArray[i] ;
        NSString *s = [NSString stringWithFormat:@"%@", d[@"id"]];
        NSLog(@"s : %@",s);
        
        if ( [s isEqualToString:self.restaurantID]) {
            self.restaurantName = d[@"name"];
            self.restaurantAddress =d[@"address"];
            self.restaurantTel = d[@"phone_number"];
            NSLog(@"self.rest name: %@", self.restaurantName);
            break;
        }
    }

    
    
    mapView1.selectedMarker = marker;

    [self loadDateForInfoView];
    [mapView1 addSubview:self.infoView];
    //[self.view addSubview:self.infoView];
    //[self willShow];

    return YES;
}
- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    [self viewDismiss];
    [self.searchBar resignFirstResponder];
    //self.infoView.hidden =YES;
}

#pragma loadData for InfoWindow
-(void) loadDateForInfoView
{
    infoWindowView *view =  [[[NSBundle mainBundle] loadNibNamed:@"infoWindowView" owner:self options:nil] objectAtIndex:0];
    
    self.infoView = view;
    
    
    
    view.restaurantName.text =self.restaurantName;
    view.address.text=self.restaurantAddress;
    view.tel.text=self.restaurantTel;
    
    view.center = CGPointMake(self.view.center.x, self.view.center.y-70);
    view.layer.cornerRadius = 10.0f;
    view.layer.masksToBounds = YES;
    
    
}

#pragma Animation
//-(void)willShow {
//    // Use UIKit Dynamics to make the alertView appear.
//    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
//    UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:self.infoView snapToPoint:CGPointMake(self.view.center.x, self.view.center.y-70)];
//    //控制下落速度,數字越大越慢
//    snapBehaviour.damping = .8f;
//    [self.animator addBehavior:snapBehaviour];
//    
//}

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
