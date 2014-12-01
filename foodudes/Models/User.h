//
//  User.h
//  foodudes
//
//  Created by PiHan Hsu on 2014/11/28.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface User : NSObject

@property (strong, nonatomic) NSString * userName;
@property (strong, nonatomic) NSString * userID;
@property (strong, nonatomic) NSString * email;
@property (strong, nonatomic) NSString * userPhotoURL;
@property (strong, nonatomic) NSString * mobileID;

-(void) getUserData;


@end
