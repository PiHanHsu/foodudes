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
#import "userMarkerView.h"
#import "MBProgressHUD.h"


@interface SearchViewController ()<MBProgressHUDDelegate>
{
    MBProgressHUD  *progressHUD;
    
}



@property UISearchBar *searchBar;
@property UIView *infoView;
@property UIImage * userCustomMarker;
@property NSDictionary *restaurantDict;
@property NSArray *restaurantArray;
@property NSArray *userArray;
@property NSArray *recommendUsers;
@property UIImage *userButtonImage;

@property (strong, nonatomic) NSMutableDictionary *usersDictionary;


@property NSString * restaurantID;
@property NSString * restaurantName;
@property NSString * restaurantAddress;
@property NSString * restaurantTel;
@property NSString * content;
@property NSString * recommendName;

@property(nonatomic,strong) UIDynamicAnimator *animator;

@property(strong, nonatomic) NSString * mobileID;

@end

@implementation SearchViewController{
    GMSMapView * mapView;
}
@synthesize gs;

#pragma mark view Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeProgressHUD:@"Loading..."];
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
    //[self loadData];
    //[self loadDateForInfoView];
    
    //User * currentUser = [[User alloc]init];
    //[currentUser getUserData];
    //[currentUser getRestData];
    [self loadRestData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(25.023950, 121.528976);
//    //marker.icon =[UIImage imageNamed:@"pin"];
//    marker.appearAnimation = kGMSMarkerAnimationPop;
//    marker.map = mapView;
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


-(NSMutableDictionary*) usersDictionary {
    if(!_usersDictionary)
        _usersDictionary = [[NSMutableDictionary alloc]init];
    return _usersDictionary;
    
}


#pragma mark SearchBar
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



#pragma mark loaddata from local
//-(void) loadUserData
//{
//    //取user資料
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectiory =[paths objectAtIndex:0];
//    NSString *uploadFile = [NSString stringWithFormat:@"user.json"];
//    
//    NSString *filePathUser = [documentDirectiory stringByAppendingPathComponent:uploadFile];
//    NSData *dataUser = [NSData dataWithContentsOfFile:filePathUser];
//    NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:dataUser options:kNilOptions error:nil];
//    
//    //NSLog(@"userDict: %@", userDict);
//    
//    [self loadRestData];
//   
//}

//still can't loadRestData
-(void) loadRestData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectiory =[paths objectAtIndex:0];
    NSString *uploadFile = [NSString stringWithFormat:@"rest.json"];
    
    NSString *filePath = [documentDirectiory stringByAppendingPathComponent:uploadFile];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *rest = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.restaurantArray = rest[@"restaurants"];
    [self displayMarker];
    //NSLog(@"rest: %@", rest);

}

-(void)displayMarker
{
    for (int i=0 ; i<self.restaurantArray.count; i++) {
        self.restaurantName = [self.restaurantArray[i] objectForKey:@"name"];
        NSLog(@"restaurantName: %@", self.restaurantName);
        
        NSString *market_lat = [self.restaurantArray[i] objectForKey:@"marker_lat"];
        double lat = [market_lat doubleValue];
        NSLog(@"lat: %f", lat);
        
        NSString *market_lng = [self.restaurantArray[i] objectForKey:@"marker_lng"];
        double lng = [market_lng doubleValue];
        NSLog(@"lng: %f", lng);

        NSArray *recommenderArray = [self.restaurantArray[i] objectForKey:@"user"];
        
        if (recommenderArray.count ==1) {
            
        NSString *userPhotoURLString = [NSString stringWithFormat:@"%@", [recommenderArray[0] objectForKey:@"image"]];
        //NSLog(@"URL: %@", userPhotoURLString);
            
         if (userPhotoURLString) {
            NSURL *pictureURL = [NSURL URLWithString:userPhotoURLString];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                        if (connectionError == nil && data != nil) {
            
                                        userMarkerView *view =  [[[NSBundle mainBundle] loadNibNamed:@"UserMarkerView" owner:self options:nil] objectAtIndex:0];
                                        view.userImage.image =[UIImage imageWithData:data];
                                        view.userImage.layer.cornerRadius = 18.0f;
                                        view.userImage.layer.masksToBounds =YES;
               UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
               [view.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *imageScreen =UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                GMSMarker * markers = [[GMSMarker alloc]init];
                  markers.position = CLLocationCoordinate2DMake(lat, lng);
                  markers.icon =imageScreen;
                  markers.map = mapView;
                  markers.userData=[NSString stringWithFormat:@"%@",  [self.restaurantArray[i] objectForKey:@"id"]];
            
                } else {
                NSLog(@"Failed to load photo for Market");
                                                       }
                                   
                                                   }];
                        }
        }
        if (i == (self.restaurantArray.count) -1){
            NSLog(@"display markers done!");
            [progressHUD hide:YES];
            
        }
        }
    
    
}



#pragma mark markers and InfoWindow



- (BOOL)mapView:(GMSMapView *)mapView1 didTapMarker:(GMSMarker *)marker
{
    [self.infoView removeFromSuperview];
    CGPoint point = [mapView1.projection pointForCoordinate:marker.position];
    point.y = point.y - 130;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[mapView1.projection coordinateForPoint:point]];
    [mapView1 animateWithCameraUpdate:camera];
    
    NSLog(@"restaurantID: %@", marker.userData);
    self.restaurantID =marker.userData;
    
    for (int i = 0; i < self.restaurantArray.count; i++) {
        NSDictionary *restaurantDict =self.restaurantArray[i] ;
        NSString *rID = [NSString stringWithFormat:@"%@", restaurantDict[@"id"]];
        
        if ( [rID isEqualToString:self.restaurantID]) {
            self.restaurantName = restaurantDict[@"name"];
            self.restaurantAddress =restaurantDict[@"address"];
            self.restaurantTel = restaurantDict[@"phone_number"];
            
            NSArray *recommenderArray = restaurantDict[@"user"];
            NSLog(@"number of User: %d", recommenderArray.count);
            if (recommenderArray.count==1) {
                NSDictionary * recommendUserDict = recommenderArray[0];
                self.content = recommendUserDict[@"content"];
                self.recommendName =recommendUserDict[@"name"];
                NSString *userPhotoURLString = [NSString stringWithFormat:@"%@", [recommenderArray[0] objectForKey:@"image"]];
                NSURL *pictureURL = [NSURL URLWithString:userPhotoURLString];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
                [NSURLConnection sendAsynchronousRequest:urlRequest
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                           if (connectionError == nil && data != nil) {
                                               
                                               UIImageView *recommenderImageView=[[UIImageView alloc]initWithImage:[UIImage imageWithData:data]];
                                               recommenderImageView.layer.cornerRadius
                                                                                  = 25.0f;
                                                                                  recommenderImageView.layer.masksToBounds=YES;
                                               UIGraphicsBeginImageContextWithOptions(recommenderImageView.frame.size, NO, 0.0);
                                               [recommenderImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
                                               UIImage *imageScreen =UIGraphicsGetImageFromCurrentImageContext();
                                               UIGraphicsEndImageContext();
                                               self.userButtonImage =imageScreen;
                                               [self displayInforWindowData];

                                            
                                                                                  }
                                       }];
            
    }
        }
        
    }
    
            
        
        
        
    mapView1.selectedMarker = marker;

    
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

#pragma mark diaplyData for InfoWindow
-(void) displayInforWindowData
{
    infoWindowView *infoView =  [[[NSBundle mainBundle] loadNibNamed:@"infoWindowView" owner:self options:nil] objectAtIndex:0];
    self.infoView = infoView;

    infoView.restaurantName.text =self.restaurantName;
    infoView.address.text=self.restaurantAddress;
    infoView.tel.text=self.restaurantTel;
    infoView.contentLabel.text=self.content;
    infoView.userNameLabel.text =self.recommendName;
    
    [infoView.userButton setImage:self.userButtonImage forState:UIControlStateNormal];
    
    infoView.center = CGPointMake(self.view.center.x, self.view.center.y-80);
    infoView.layer.cornerRadius = 10.0f;
    infoView.layer.masksToBounds = YES;
    
    [mapView addSubview:self.infoView];
}

#pragma mark Animation
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

#pragma mark lodaData from Linode
//-(void)loadData
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
//#pragma mark - progressed 完成
//        //載入完成
//        NSLog(@"Completed!");
//        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        //test log
//        //NSLog(@"Response: %@",tmp);
//#pragma mark - 轉資料11/26
//        NSData *rawData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
//        NSError *e;
//
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&e];
//        NSLog(@"Data from Fung: %@", dict);
//        NSString *mobileID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"mobile_id"]];
//        self.mobileID = mobileID;
//        [self loadRestaurntData];
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error");
//    }];
//
//    //4. Start傳輸
//    [operation start];
//
//}
//-(void) loadRestaurntData
//{
//
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://106.185.53.8/"]];
//
//    NSString * mobileID = self.mobileID;
//
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            mobileID,    @"mobile_id"
//                            , nil];
//    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
//                                                            path:@"api/v1/maps/index"
//                                                      parameters:params];
//
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
//
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//        NSLog(@"Completed!");
//        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//
//        NSData *rawData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
//        NSError *e;
//
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&e];
//        //NSLog(@"Query2 Data: %@", dict);
//        self.restaurantDict = dict;
//        NSString * restaurants = [NSString stringWithFormat:@"%@", [dict objectForKey:@"restaurants"]];
//        //NSLog(@"Restaurant Data: %@", restaurants);
//
//        NSArray * users = [dict objectForKey:@"users"];
//        //NSLog(@"users Data: %@", users);
//
//        // load image and do custom marker
//
//        for (int i =1; i< users.count; i++) {
//            NSString *userPhotoURLString = [NSString stringWithFormat:@"%@", [users[i] objectForKey:@"image"]];
//
//            NSLog(@"URL: %@", userPhotoURLString);
//            if (userPhotoURLString) {
//                NSURL *pictureURL = [NSURL URLWithString:userPhotoURLString];
//                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
//
//                [NSURLConnection sendAsynchronousRequest:urlRequest
//                                                   queue:[NSOperationQueue mainQueue]
//                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                                           if (connectionError == nil && data != nil) {
//
//                                               userMarkerView *view =  [[[NSBundle mainBundle] loadNibNamed:@"UserMarkerView" owner:self options:nil] objectAtIndex:0];
//                                               view.userImage.image =[UIImage imageWithData:data];
//                                               view.userImage.layer.cornerRadius = 18.0f;
//                                               view.userImage.layer.masksToBounds =YES;
//
//                                               UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
//                                               [view.layer renderInContext:UIGraphicsGetCurrentContext()];
//
//                                               UIImage *imageScreen =UIGraphicsGetImageFromCurrentImageContext();
//                                               UIGraphicsEndImageContext();
//
//                                               self.userCustomMarker= imageScreen;
//                                               [self addTestMarker];
//
//                                           } else {
//                                               NSLog(@"Failed to load profile photo.");
//                                           }
//                                       }];
//            }
//
//        }
//
//
//
//        NSArray * array =[dict objectForKey:@"restaurants"];
//        NSLog(@"Name: %@", array[0]);
//        NSLog(@"num: %ld", array.count);
//
//        for (int i =0; i <array.count; i++) {
//
//            self.restaurantName = [array[i] objectForKey:@"name"];
//            NSLog(@"restaurantName: %@", self.restaurantName);
//
//            NSString *market_lat = [array[i] objectForKey:@"marker_lat"];
//            double lat = [market_lat doubleValue];
//            NSLog(@"lat: %f", lat);
//
//            NSString *market_lng = [array[i] objectForKey:@"marker_lng"];
//            double lng = [market_lng doubleValue];
//            NSLog(@"lng: %f", lng);
//
//            GMSMarker * markers = [[GMSMarker alloc]init];
//            markers.position = CLLocationCoordinate2DMake(lat, lng);
//            markers.userData=[NSString stringWithFormat:@"%@",  [array[i] objectForKey:@"id"]];
//            UIImageView * imageView =[[UIImageView alloc]init];
//            imageView.image =self.userCustomMarker;
//
//            //markers.icon =self.userCustomMarker;
//            markers.map = mapView;
//        }
//
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error!!!!!");
//    }];
//
//    [operation start];
//
//}



#pragma mark loadData from Parse

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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
