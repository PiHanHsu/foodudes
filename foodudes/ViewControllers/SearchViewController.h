//
//  SearchViewController.h
//  foodudes
//
//  Created by PiHan Hsu on 2014/11/19.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GCGeocodingService.h"

@interface SearchViewController : UIViewController < UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate >
@property (strong,nonatomic) GCGeocodingService *gs;
@property (strong, nonatomic) CLLocationManager *locationManager;


@end
