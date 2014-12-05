
//  User.m
//  foodudes
//
//  Created by PiHan Hsu on 2014/11/28.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import "User.h"
#import "AFNetworking.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation User
-(void) getUserData{
    
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
        //轉資料
        NSData *rawData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"dict from user: %@",dict);
        //存資料
        NSError *e2;
        NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&e2];
        //NSLog(@"json data: %@",jsondata);
            
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectiory =[paths objectAtIndex:0];
        NSString *uploadFile = [NSString stringWithFormat:@"user.json"];
        
        NSString *filePath = [documentDirectiory stringByAppendingPathComponent:uploadFile];
        //NSLog(@"filePath: %@", filePath);
        
        [jsondata writeToFile:filePath atomically:YES];
 
        //NSLog(@"Data from Fung: %@", dict);
        
        NSString *email= [NSString stringWithFormat:@"%@", [dict objectForKey:@"email"]];
        NSString *fooduduesID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
        NSString *photoURL = [NSString stringWithFormat:@"%@", [dict objectForKey:@"image"]];
        NSString *mobileID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"mobile_id"]];
        NSString *name = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
        
        self.email=email;
        self.userID =fooduduesID;
        self.userPhotoURL=photoURL;
        self.mobileID=mobileID;
        self.userName=name;
       
        //NSLog(@"user name: %@", self.userName);
        [self getRestData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error");
    }];
    
    //4. Start傳輸
    [operation start];

}

-(void)getRestData
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
            
            NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            NSLog(@"rest data: %@",dict);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectiory =[paths objectAtIndex:0];
            NSString *uploadFile = [NSString stringWithFormat:@"rest.json"];
            
            NSString *filePath = [documentDirectiory stringByAppendingPathComponent:uploadFile];
            
            [jsondata writeToFile:filePath atomically:YES];
            
//            NSLog(@"Query2 Data: %@", dict);
//            NSString * restaurants = [NSString stringWithFormat:@"%@", [dict objectForKey:@"restaurants"]];
//            NSLog(@"Restaurant Data: %@", restaurants);
//    
//            NSString * users = [NSString stringWithFormat:@"%@", [dict objectForKey:@"users"]];
//            NSLog(@"users Data: %@", users);
//    
//            NSArray * array =[dict objectForKey:@"restaurants"];
//            NSLog(@"Name: %@", array[0]);
//            NSLog(@"num: %ld", array.count);
//    
//            for (int i =0; i <array.count; i++) {
//    
//                NSString *restaurantName = [array[i] objectForKey:@"name"];
//                NSLog(@"restaurantName: %@", restaurantName);
//    
//    
//                NSString *market_lat = [array[i] objectForKey:@"marker_lat"];
//                double lat = [market_lat doubleValue];
//                NSLog(@"lat: %f", lat);
//    
//                NSString *market_lng = [array[i] objectForKey:@"marker_lng"];
//                double lng = [market_lng doubleValue];
//                NSLog(@"lng: %f", lng);
//    
//                NSString *restaurantID = [array[i] objectForKey:@"id"];
//                NSLog(@"restaurantID: %@", restaurantID);
//    
//            }
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error!!!!!");
        }];
        
        [operation start];
}

@end
