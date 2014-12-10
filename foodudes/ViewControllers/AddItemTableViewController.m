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

@interface AddItemTableViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>


@property NSNumber * placeLat;
@property NSNumber * placeLng;

@end

@implementation AddItemTableViewController
@synthesize gs;

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.title = @"新增推薦地點";
    
    
    self.nameTextField =[[UITextField alloc]initWithFrame:CGRectMake(130, 0, 180, 40)];
    self.nameTextField.textColor =[UIColor lightGrayColor];
    self.nameTextField.delegate =self;
    self.nameTextField.textAlignment = NSTextAlignmentLeft;
    self.nameTextField.font =[UIFont systemFontOfSize:13];
    self.nameTextField.tag=101;

    self.addressTextField =[[UITextField alloc]initWithFrame:CGRectMake(130, 0, 180, 40)];
    self.addressTextField.textColor =[UIColor lightGrayColor];
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
    
    
    self.contentTextView  =[[UITextView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width -20, 150 )];
    self.contentTextView.textColor =[UIColor blackColor];
    self.contentTextView.delegate =self;
    self.contentTextView.editable =YES;
    self.contentTextView.backgroundColor = [UIColor lightGrayColor];
    self.contentTextView.textAlignment = NSTextAlignmentLeft;
    self.contentTextView.font =[UIFont systemFontOfSize:13];
    self.contentTextView.tag=104;

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [gestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        headerLabel.text = @"    餐廳資訊）";
    else if (section ==1)
        headerLabel.text =  @"    推薦原因";
   
    
    return headerLabel;
    
}


-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section ==1){
        UIView *footerView =[[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 120)];
        UIButton *addcharity = [UIButton buttonWithType:UIButtonTypeCustom];
        [addcharity setTitle:@"新增" forState:UIControlStateNormal];
        [addcharity addTarget:self action:@selector(checkLatnLng:) forControlEvents:UIControlEventTouchUpInside];
        [addcharity setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addcharity.frame = CGRectMake(14, 20, 292, 40);
        addcharity.backgroundColor = [UIColor greenColor];
        
        [addcharity.layer setCornerRadius:5.0f];
        [footerView addSubview:addcharity];

        return footerView;
    }else
        return nil;
    
}

-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    // 把section 2 以下多的空白切掉
    if (section ==1)
        return 200.0f;
    else
        return 0.0f;
}

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
                    cell.imageView.image = [UIImage imageNamed:@"img_info_account"];
                    cell.textLabel.text = @"餐廳名稱";
                    [cell.contentView addSubview:self.nameTextField];
                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"img_info_password"];
                    cell.textLabel.text = @"地址";
                    [cell.contentView addSubview:self.addressTextField];
                    break;
                case 2:
                    cell.imageView.image = [UIImage imageNamed:@"img_info_password"];
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
                    cell.imageView.image = [UIImage imageNamed:@"img_info_name"];
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
    if (!self.placeLat || !self.placeLng ) {
        NSLog(@"address: %@", self.addressTextField.text);
        
        [gs geocodeAddress:self.addressTextField.text];
        
        
        [self getLatAndLng];
    }
}

- (void) getLatAndLng
{
    self.placeLat = [gs.geocode objectForKey:@"lat"] ;
    self.placeLng = [gs.geocode objectForKey:@"lng"] ;
    NSLog(@"new place: %@, %@", self.placeLat, self.placeLng);


}

- (void) addNewPlaces
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://beta.foodudes.co/"]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mobileID =[NSString stringWithFormat:@"%@", [defaults objectForKey:@"mobile_ID"]] ;
    
    NSString * name=self.nameTextField.text;
    NSString * address= self.addressTextField.text;
    NSString * phone_number = self.telTextField.text;

    NSString * content= self.contentTextView.text;
    NSLog(@"content: %@", content);
    
    

    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            mobileID,         @"mobile_id",
                            name,             @"name",
                            address,          @"address",
                            phone_number,     @"phone_number",
                            self.placeLat, @"lat",
                            self.placeLng, @"lng",
                            content,          @"content",
                            nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@"api/v1/restaurants/recommend"
                                                      parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Completed!");
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error to add new data");
    }];
    
    [operation start];

    
    
    
}
//
//
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
