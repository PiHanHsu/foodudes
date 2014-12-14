//
//  AddItemTableViewController.h
//  foodudes
//
//  Created by PiHan Hsu on 2014/12/10.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GCGeocodingService.h"

@interface AddItemTableViewController : UITableViewController

@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UITextField *addressTextField;
@property (strong, nonatomic) UITextField *telTextField;
@property (strong, nonatomic) NSString *nameText;
@property (strong, nonatomic) NSString *addressText;
@property (strong, nonatomic) NSString *telText;

@property (strong, nonatomic) UITextView *contentTextView;
@property (strong,nonatomic) GCGeocodingService *gs;

@property NSString * placeLat;
@property NSString * placeLng;

@end
