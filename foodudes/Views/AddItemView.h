//
//  AddItemView.h
//  foodudes
//
//  Created by PiHan Hsu on 2014/12/8.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddItemView : UIView
@property (weak, nonatomic) IBOutlet UITextField *restaurantName;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *tel;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end
