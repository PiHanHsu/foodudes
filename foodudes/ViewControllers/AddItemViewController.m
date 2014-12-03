//
//  AddItemViewController.m
//  foodudes
//
//  Created by PiHan Hsu on 2014/11/19.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import "AddItemViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"
#import "User.h"

@interface AddItemViewController ()<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>


@property(strong, nonatomic) NSString * mobileID;
@property UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    User * currentUser = [[User alloc]init];
//    [currentUser getUserData];
//    
    //NSLog(@"Username: %@", currentUser.userName);
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 30)];
    self.searchBar.showsSearchResultsButton=YES;
    self.searchBar.searchBarStyle = UIBarStyleDefault;
    self.searchBar.placeholder=@"搜尋餐廳";
    self.searchBar.delegate=self;
    
    [self.view addSubview:self.searchBar];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"TableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    } else {
        NSLog(@"I have been initialize. Row = %li", (long)indexPath.row);
    }
    
    cell.textLabel.text =@"Restanuant Name";
    cell.detailTextLabel.text = @"address";
    cell.imageView.image = [UIImage imageNamed:@"restaurant"];
    
    return cell;
    
}

#pragma getData
-(void)getData
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://106.185.53.8/"]];
    NSString *token =[FBSession activeSession].accessTokenData.accessToken;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            token,    @"fb_token"
                            , nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@"api/v1/auth/log_in"
                                                      parameters:params];
    //2.準備operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    //3.準備callback block
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
    NSLog(@"mobileID: %@", mobileID);
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            mobileID,    @"mobile_id"
                            , nil];
    //NSLog(@"mobile_id: %@", mobileID);
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:@"api/v1/maps/index"
                                                      parameters:params];
    //2.準備operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    //3.準備callback block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"Completed!");
        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        NSData *rawData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"Query2 Data: %@", dict);
        NSString * restaurants = [NSString stringWithFormat:@"%@", [dict objectForKey:@"restaurants"]];
        NSLog(@"Restaurant Data: %@", restaurants);
        
        NSString * users = [NSString stringWithFormat:@"%@", [dict objectForKey:@"users"]];
        NSLog(@"users Data: %@", users);
        
        
        NSArray * array =[dict objectForKey:@"restaurants"];
        NSLog(@"Name: %@", array[0]);
        
        NSString *userName = [array[0] objectForKey:@"name"];
        NSLog(@"user name: %@", userName);
        
        NSString *market_lat = [array[0] objectForKey:@"marker_lat"];
        double lat = [market_lat doubleValue];
        NSLog(@"lat: %f", lat);
        
        NSString *market_lng = [array[0] objectForKey:@"marker_lng"];
        double lng = [market_lng doubleValue];
        NSLog(@"lng: %f", lng);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error!!!!!");
    }];
    
    //4. Start傳輸
    [operation start];

    
    
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
