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
#import "AddItemTableViewController.h"


@interface SearchViewController ()<MBProgressHUDDelegate, UIScrollViewDelegate>
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
@property NSMutableArray *contentArray;
@property NSMutableArray *recommendUserArray;
@property UIScrollView *contentScrollView;


@property (strong, nonatomic) NSMutableDictionary *usersDictionary;


@property NSString * restaurantID;
@property NSString * restaurantName;
@property NSString * restaurantAddress;
@property NSString * restaurantTel;
@property NSString * restaurantLat;
@property NSString * restaurantLng;
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
   
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:25.023868 longitude:121.528976 zoom:15 bearing:0 viewingAngle:0];
    
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    mapView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-65);
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    mapView.delegate = self;
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 30)];
    self.searchBar.showsSearchResultsButton=YES;
    self.searchBar.searchBarStyle = UIBarStyleDefault;
    self.searchBar.placeholder=@"輸入地點,例如：台北北投、台北淡水...";
    self.searchBar.delegate=self;
    
    [self.view addSubview:self.searchBar];
    [self.view insertSubview:mapView atIndex:0];
    gs = [[GCGeocodingService alloc] init];
    
    
    
    
    //[self lodaDataFromParse];
    //[self loadData];
    //[self loadDateForInfoView];
    
    
    
    [self loadRestData];
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
//    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//        [self.locationManager requestWhenInUseAuthorization];
//    }
//    [self.locationManager startUpdatingLocation];
    
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    NSLog(@"%@", [locations lastObject]);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
 [[self navigationController] setNavigationBarHidden:YES animated:YES];
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
//    GMSMarker *options = [[GMSMarker alloc] init];
//    options.position = CLLocationCoordinate2DMake(lat, lng);
//    options.title = [gs.geocode objectForKey:@"address"];
//    options.appearAnimation= kGMSMarkerAnimationPop;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat                                                                longitude:lng                                                        zoom:15];
    [mapView setCamera:camera];
    //options.map=mapView;
}



#pragma mark loaddata from local

-(void) loadRestData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectiory =[paths objectAtIndex:0];
    NSString *uploadFile = [NSString stringWithFormat:@"rest.json"];
    
    NSString *filePath = [documentDirectiory stringByAppendingPathComponent:uploadFile];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *rest = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.restaurantArray = rest[@"restaurants"];
    
    NSLog(@"rest1: %@", self.restaurantArray[1]);
    NSString *market_lat = [NSString stringWithFormat:@"%@", [self.restaurantArray[1] objectForKey:@"marker_lat"]];
    double lat = [market_lat doubleValue];
    NSLog(@"lat: %f", lat);

    [self displayMarker];
}

-(void)displayMarker
{
    for (int i=0 ; i<self.restaurantArray.count; i++) {
        self.restaurantName = [self.restaurantArray[i] objectForKey:@"name"];
        //NSLog(@"restaurantName: %@", self.restaurantName);
        
        NSString *market_lat = [NSString stringWithFormat:@"%@", [self.restaurantArray[i] objectForKey:@"marker_lat"]];
        double lat = [market_lat doubleValue];
        //NSLog(@"lat: %f", lat);
        
        NSString *market_lng = [NSString stringWithFormat:@"%@", [self.restaurantArray[i] objectForKey:@"marker_lng"]];
        double lng = [market_lng doubleValue];
        //NSLog(@"lng: %f", lng);

        NSArray *recommenderArray = [self.restaurantArray[i] objectForKey:@"user"];
        
        //NSLog(@"recommender: %lu", recommenderArray.count);
        if (recommenderArray.count ==1) {
            
        NSString *userPhotoURLString = [NSString stringWithFormat:@"%@", [recommenderArray[0] objectForKey:@"image"]];
            
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
            
                }                                }];
         }
        }else if (recommenderArray.count >1){
             
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
                                                
                                                UILabel *numLable = [[UILabel alloc] initWithFrame:CGRectMake(30,0, 20, 20)];
                                                numLable.backgroundColor =[UIColor redColor];
                                                numLable.text = [NSString stringWithFormat:@"%lu",recommenderArray.count];
                                                numLable.textColor =[UIColor whiteColor];
                                                numLable.textAlignment=UITextAlignmentCenter;
                                                numLable.layer.cornerRadius =10.0f;
                                                numLable.layer.masksToBounds =YES;
                                                [view addSubview:numLable];
                                                UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
                                                [view.layer renderInContext:UIGraphicsGetCurrentContext()];
                                                UIImage *imageScreen =UIGraphicsGetImageFromCurrentImageContext();
                                                UIGraphicsEndImageContext();
                                                
                                                GMSMarker * markers = [[GMSMarker alloc]init];
                                                markers.position = CLLocationCoordinate2DMake(lat, lng);
                                                markers.icon =imageScreen;
                                                markers.map = mapView;
                                                markers.userData=[NSString stringWithFormat:@"%@",  [self.restaurantArray[i] objectForKey:@"id"]];
                                                
                                                
                                                //NSLog(@"Failed to load photo for Market");
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


#pragma mark custom marker method

-(UIImage *) NSURL:(NSURL *)userPhotoURLString NSURLRequest:(NSURLRequest *)urlRequest
{
    return nil;
}

#pragma mark markers and InfoWindow



- (BOOL)mapView:(GMSMapView *)mapView1 didTapMarker:(GMSMarker *)marker
{
    [self.infoView removeFromSuperview];
    [self.contentScrollView removeFromSuperview];
    CGPoint point = [mapView1.projection pointForCoordinate:marker.position];
    point.y = point.y - 157;
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
            self.restaurantLat= [NSString stringWithFormat:@"%@", restaurantDict[@"marker_lat"]];
            
            self.restaurantLng= [NSString stringWithFormat:@"%@", restaurantDict[@"marker_lng"]];
;
            self.recommendUserArray =restaurantDict[@"user"];
            //NSLog(@"recommender num: %lu", self.recommendUserArray.count );
            [self loadingRecommendContent];
            break;
        }
    }
    mapView1.selectedMarker = marker;

    return YES;
}

-(void)loadingRecommendContent
{
    [self.infoView removeFromSuperview];
    self.contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 65, 270, 200)];
    self.contentScrollView.backgroundColor = [UIColor colorWithRed:233/255.0 green:234/255.0 blue:237/255.0 alpha:1];
    
    int user_count = [[NSString stringWithFormat:@"%lu", self.recommendUserArray.count] intValue];
        
        for (int i = 0; i < user_count; i++) {
            NSDictionary * recommendUserDict = self.recommendUserArray[i];
            
            NSInteger y = 5 + (160 * i);
            UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(8, y, 254, 155)];
            contentView.backgroundColor = [UIColor whiteColor];
            contentView.layer.cornerRadius =5.0f;
            contentView.layer.masksToBounds =YES;
            contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            contentView.layer.borderWidth = 1.0f;
            
            UITextView * contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(5, 55, 250, 100)];
            contentTextView.backgroundColor = [UIColor whiteColor];
            contentTextView.textColor = [UIColor blackColor];
            contentView.layer.cornerRadius =1.0f;
            NSString * content = [recommendUserDict[@"content"] stringByReplacingOccurrencesOfString:@" \n" withString:@"\n"];
            
            contentTextView.text =content;
            //NSLog(@"Content: %@", contentTextView.text);
            
            contentTextView.editable =NO;
            UIButton * userButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
            
            UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 10, 150, 30)];
            
            userLabel.text =[NSString stringWithFormat:@"%@ 推薦",recommendUserDict[@"name"]];
            userLabel.textColor = [UIColor blackColor];
            NSString *userPhotoURLString = [NSString stringWithFormat:@"%@", [self.recommendUserArray[i] objectForKey:@"image"]];
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
                                           [userButton setImage:imageScreen forState:UIControlStateNormal];
                                           
                                           
                                           [contentView addSubview:contentTextView];
                                           [contentView addSubview:userLabel];
                                           [contentView addSubview:userButton];
                                           
                                           [self.contentScrollView addSubview:contentView];
                                       }
                                   }];
            if (i == (user_count -1)) {
                NSInteger h = 170 + (170 * (self.recommendUserArray.count-1));
                
                self.contentScrollView.contentSize = CGSizeMake(260, h);
                [self displayInfoWindowData];
                break;
            }
            
        }
        
    
 
}


- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    [self viewDismiss];
    [self.searchBar resignFirstResponder];
    //self.infoView.hidden =YES;
}

- (void)mapView:(GMSMapView *)mapView
didChangeCameraPosition:(GMSCameraPosition *)position{
//    self.infoView.hidden =YES;
//    [self.searchBar resignFirstResponder];
//    
}

#pragma mark diaplyData for InfoWindow
-(void) displayInfoWindowData
{
    infoWindowView *infoView =  [[[NSBundle mainBundle] loadNibNamed:@"infoWindowView" owner:self options:nil] objectAtIndex:0];
    self.infoView = infoView;
    
    infoView.restaurantName.text =self.restaurantName;
    infoView.address.text=self.restaurantAddress;
    infoView.tel.text=self.restaurantTel;
    [infoView addSubview:self.contentScrollView];
    UIButton * shareButton = [[UIButton alloc]initWithFrame:CGRectMake(125, 265, 150, 20)];
    
    [shareButton setTitle:@"加入我的推薦清單" forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [shareButton addTarget:self action:@selector(goAddItemPage:) forControlEvents:UIControlEventTouchUpInside];
    
    [infoView addSubview:shareButton];
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

#pragma mark push to AddItemPage

- (void)goAddItemPage:(id)sender
{

    [self _ViewControllerAnimated:YES];
    
}

- (void)_ViewControllerAnimated:(BOOL)animated {
    

    
    
//    UINavigationController *navController = [[self.tabBarController viewControllers] objectAtIndex:0];
//    AddItemTableViewController *addItemVC = [[navController viewControllers] objectAtIndex:0];
    AddItemTableViewController *addItemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addItemTableViewController"];


      addItemVC.nameText = self.restaurantName;
      addItemVC.addressText = self.restaurantAddress;
      addItemVC.telText = self.restaurantTel;
      addItemVC.placeLat = self.restaurantLat;
      addItemVC.placeLng = self.restaurantLng;
    
    [self.navigationController pushViewController:addItemVC animated:YES];
   // [self.tabBarController setSelectedIndex:0];
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
