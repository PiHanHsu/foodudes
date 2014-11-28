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


@interface AddItemViewController ()

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getData
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://106.185.53.8/"]];
    NSString *token =[FBSession activeSession].accessTokenData.accessToken;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            token,    @"fb_token"
                            , nil];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
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
        
//        NSString *fooduduesID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
//        NSString *name = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
//        
        
    
        
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error");
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
