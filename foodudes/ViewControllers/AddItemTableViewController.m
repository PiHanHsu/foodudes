//
//  AddItemTableViewController.m
//  foodudes
//
//  Created by PiHan Hsu on 2014/12/10.
//  Copyright (c) 2014年 PiHan Hsu. All rights reserved.
//

#import "AddItemTableViewController.h"
#import "AFNetworking.h"
#import "GCGeocodingService.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "SPGooglePlacesAutocomplete.h"

#define API_KEY @"AIzaSyAFsaDn7vyI8pS53zBgYRxu0HfRwYqH-9E"

@interface AddItemTableViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UITextViewDelegate,MBProgressHUDDelegate, UISearchBarDelegate>
{
    MBProgressHUD  *progressHUD;
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    
    BOOL shouldBeginEditing;

}

@property (strong, nonatomic) NSMutableString * placeDetailURL;

@end

@implementation AddItemTableViewController
@synthesize gs;

- (void)viewDidLoad {
    [super viewDidLoad];
     [[self navigationController] setNavigationBarHidden:NO animated:YES];
    gs = [[GCGeocodingService alloc] init];
    
    // set up TextFields
    self.nameTextField =[[UITextField alloc]initWithFrame:CGRectMake(130, 0, 180, 40)];
    self.nameTextField.textColor =[UIColor blackColor];
    self.nameTextField.delegate =self;
    self.nameTextField.textAlignment = NSTextAlignmentLeft;
    self.nameTextField.font =[UIFont systemFontOfSize:13];
    self.nameTextField.tag=101;
    
    
    self.addressTextField =[[UITextField alloc]initWithFrame:CGRectMake(130, 0, 180, 40)];
    self.addressTextField.textColor =[UIColor blackColor];
    self.addressTextField.delegate =self;
    self.addressTextField.textAlignment = NSTextAlignmentLeft;
    self.addressTextField.font =[UIFont systemFontOfSize:13];
    self.addressTextField.tag=102;
    
    
    self.telTextField =[[UITextField alloc]initWithFrame:CGRectMake(130, 0, 180, 40)];
    self.telTextField.textColor =[UIColor blackColor];
    self.telTextField.delegate =self;
    self.telTextField.textAlignment = NSTextAlignmentLeft;
    self.telTextField.font =[UIFont systemFontOfSize:13];
    self.telTextField.tag=103;
//    self.telTextField.text = self.telText;
//    self.telTextField.placeholder = @"輸入電話";
    
    self.contentTextView  =[[UITextView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width -20, 150 )];
    self.contentTextView.textColor =[UIColor blackColor];
    self.contentTextView.delegate =self;
    self.contentTextView.editable =YES;
    self.contentTextView.backgroundColor = [UIColor whiteColor];
    self.contentTextView.textAlignment = NSTextAlignmentLeft;
    self.contentTextView.font =[UIFont systemFontOfSize:13];
    self.contentTextView.tag=104;
    
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [gestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:gestureRecognizer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    self.nameTextField.text = self.nameText;
    self.nameTextField.placeholder=@"輸入餐廳名稱";
    if (self.nameTextField.text.length >1) {
        self.nameTextField.enabled =NO;
        self.nameTextField.textColor = [UIColor grayColor];
    }else{
        self.nameTextField.enabled =YES;
        self.nameTextField.textColor = [UIColor blackColor];
    }
    
    self.addressTextField.text =self.addressText;
    self.addressTextField.placeholder=@"輸入地址";

    self.telTextField.text = self.telText;
    self.telTextField.placeholder = @"輸入電話";
    
}

-(void) viewDidDisappear:(BOOL)animated{
    NSLog(@"viewDidDisappear");
    self.nameText=@"";
    self.addressText=@"";
    self.telText=@"";
}

-(void) hideKeyboard
{
    [self.view endEditing:YES];
    
}

#pragma mark - Table view data source


#pragma tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}


//欄位高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 40.0;
        
    }else
    {
        return 170.0;
    }
    
}
//要顯示幾個欄位
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
        
    }else
    {
        return 1;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc]init];
    
    headerLabel.frame = CGRectMake(0, 0, 300, 35.0);
    headerLabel.textColor =[ UIColor grayColor];
    headerLabel.font = [UIFont systemFontOfSize:12.0f];
    
    if (section ==0)
    {
        headerLabel.text = @"    餐廳資訊";
        headerLabel.font = [UIFont systemFontOfSize:15];
    }
    else if (section ==1)
    {
        headerLabel.text =  @"    推薦原因";
        headerLabel.font = [UIFont systemFontOfSize:15];
    }
    return headerLabel;
    
}


-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section ==1){
        UIView *footerView =[[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 120)];
        UIButton *addcharity = [[UIButton alloc]initWithFrame:CGRectMake(14, 20, (self.view.frame.size.width/2)- 20, 40)];
        [addcharity setTitle:@"新增" forState:UIControlStateNormal];
        [addcharity addTarget:self action:@selector(checkLatnLng:) forControlEvents:UIControlEventTouchUpInside];
        [addcharity setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                addcharity.backgroundColor = [UIColor greenColor];
        
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2)+6, 20, (self.view.frame.size.width/2)- 20, 40)];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cencelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        cancelButton.backgroundColor = [UIColor greenColor];
        
        
        [addcharity.layer setCornerRadius:5.0f];
        [cancelButton.layer setCornerRadius:5.0f];
        [footerView addSubview:addcharity];
        [footerView addSubview:cancelButton];

        return footerView;
    }else
        return nil;
    
}

- (void) cencelButtonPressed: (id) sender{
    
    self.nameTextField.text=@"";
    self.addressTextField.text=@"";
    self.telTextField.text=@"";
    self.placeLat=@"";
    self.placeLng=@"";
    self.contentTextView.text=@"";

}

//-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
//{
//    // 把section 2 以下多的空白切掉
//    if (section ==1)
//        return 200.0f;
//    else
//        return 0.0f;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *requestIdentifier = @"LoginCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:requestIdentifier];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:requestIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14.0];
        cell.detailTextLabel.font =[UIFont fontWithName:@"STHeitiSC-Medium" size:14.0];
        cell.accessoryType =UITableViewCellAccessoryNone;
        cell.textLabel.textAlignment= NSTextAlignmentLeft;
        cell.textLabel.textColor =[UIColor colorWithRed:121/255.0 green:121/255.0 blue:121/255.0 alpha:1];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        
    }
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    //cell.imageView.image = [UIImage imageNamed:@"img_info_account"];
                    cell.textLabel.text = @"餐廳名稱";
                    [cell.contentView addSubview:self.nameTextField];
                    break;
                case 1:
                    //cell.imageView.image = [UIImage imageNamed:@"img_info_password"];
                    cell.textLabel.text = @"地址";
                    [cell.contentView addSubview:self.addressTextField];
                    break;
                case 2:
                    //cell.imageView.image = [UIImage imageNamed:@"img_info_password"];
                    cell.textLabel.text = @"電話";
                    [cell.contentView addSubview:self.telTextField];
                    break;
                default:
                    break;
            }
            
            break;
        }
            
        case 1: {
            switch (indexPath.row) {
                case 0:
                    //cell.imageView.image = [UIImage imageNamed:@"img_info_name"];
                    cell.textLabel.text = @"推薦原因";
                    [cell.contentView addSubview:self.contentTextView];
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        
    
    return cell;
    
}

#pragma mark AddNewPlaces
- (void) checkLatnLng: (id)sender
{
    [self initializeProgressHUD:@"儲存中..."];
    if (!self.placeLat || !self.placeLng ) {
        
        //NSString * tmp = self.addressTextField.text;
        [gs geocodeAddress:self.addressTextField.text];
        [self getLatAndLng];
    }else{
        NSLog(@"lat: %@, Lng:%@", self.placeLat, self.placeLng);
         [self addNewPlaces];
    }
   
}

- (void) getLatAndLng
{
    self.placeLat = [gs.geocode objectForKey:@"lat"] ;
    self.placeLng = [gs.geocode objectForKey:@"lng"] ;
    NSLog(@"new place: %@, %@", self.placeLat, self.placeLng);
    [self addNewPlaces];

}

- (void) addNewPlaces
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://beta.foodudes.co/"]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mobileID =[NSString stringWithFormat:@"%@", [defaults objectForKey:@"mobile_ID"]] ;
    
    NSString * name=self.nameTextField.text;
    NSString * address= self.addressTextField.text;
    NSString * phone_number = self.telTextField.text;
    NSString * lat =[NSString stringWithFormat:@"%@", self.placeLat];
    NSString * lng =[NSString stringWithFormat:@"%@", self.placeLng];
    NSString * content= self.contentTextView.text;
    NSLog(@"content: %@", content);

    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            mobileID,         @"mobile_id",
                            name,             @"name",
                            address,          @"address",
                            phone_number,     @"phone_number",
                            lat,              @"lat",
                            lng,              @"lng",
                            content,          @"content",
                            nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@"api/v1/restaurants/recommend"
                                                      parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Completed!");
        User *currentUser = [[User alloc]init];
        [currentUser getUserData];

        [[NSNotificationCenter defaultCenter]
         addObserverForName:@"loadingDataFinished"
         object:nil
         queue:[NSOperationQueue mainQueue]
         usingBlock:^(NSNotification *notification) {
             if ([notification.name isEqualToString:@"loadingDataFinished"]) {
                 NSLog(@"Loading Data Finished!");
                 [progressHUD hide:YES];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新增成功"
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 [self _ViewControllerAnimated:YES];

             }
         }];

        
        
        
        self.nameTextField.text=@"";
        self.addressTextField.text=@"";
        self.telTextField.text=@"";
        self.placeLat=@"";
        self.placeLng=@"";
        self.contentTextView.text=@"";

        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error to add new data");
    }];
    
    [operation start];

}
- (void)_ViewControllerAnimated:(BOOL)animated {
    
    UITabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [tabBarVC setSelectedIndex:1];
    [self presentViewController:tabBarVC animated:YES completion:nil];
    //    [self.navigationController pushViewController:tabBarVC animated:animated];
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


//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 2;
//}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
