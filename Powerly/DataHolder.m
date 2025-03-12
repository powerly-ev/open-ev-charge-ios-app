//
//  CategoryViewController.m
//  kazumi
//
//  Created by Yashvir on 14/11/15.
//  Copyright © 2015 Nishkrant Media. All rights reserved.
//

#import "CategoryViewController.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.barButtonCat.target = self.revealViewController;
    self.barButtonCat.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    objglobalValues = [GlobalValues   sharedManager];
    self.title = @"Categories";
    //WEBSERVICE CALL
    [self  getAllCategoriesList];
    [self cartBarButton];
    
}


-(void)cartBarButton
{
    
    
    MKNumberBadgeView *number = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(25, -10,20,20)];
    number.value = objglobalValues.strCartCount.integerValue;
    number.shadow = NO;
    number.shine = YES;
    number.font = [UIFont  fontWithName:kFontSFUIDisplay_Bold size:14];
    number.strokeColor = UIColorFromRGBWithAlpha(kazumiRedColor, 1.0);
    number.layer.cornerRadius = 2.0;
    
    
    
    UIImage * imgcart = [UIImage  imageNamed:@"cart"];
    // Allocate UIButton
    UIButton *btn = [UIButton  buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0,30,30);
    [btn setImage:imgcart forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn addSubview:number]; //Add NKNumberBadgeView as a subview on UIButton
    
    // Initialize UIBarbuttonitem...
    UIBarButtonItem *proe = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = proe;
    
}





-(IBAction)cartButtonClicked:(id)sender
{
    
    if (objglobalValues.strCartCount.integerValue == 0) {
        [TSMessage  showNotificationInViewController:self title:@"Cart" subtitle:@"No Product Available in Cart" type:TSMessageNotificationTypeMessage];
    }
    else
    {
        CartViewController * objCartVC = [self.storyboard   instantiateViewControllerWithIdentifier:@"CartViewController"];
        [self.navigationController pushViewController:objCartVC animated:YES];
        
    }
}


#pragma mark
#pragma mark - WEBSERVICE CALL
#pragma mark
-(void)getAllCategoriesList
{
    if ([Reachability isConnected]) {
        //WEBSERVICE CALL
        [DejalBezelActivityView   activityViewForView:self.view withLabel:@"Please Wait"];
        NSDictionary *dict = @{@"action" : @"listcategories"};
        
        [Network  getWebserviceWithBaseUrl:kBaseURL withParameters:dict andCompletionHandler:^(id result, NSError *error) {
            if (error) {
                [DejalBezelActivityView  removeViewAnimated:YES];
                NSLog(@"%@",error);
            }
            else
            {
                [DejalBezelActivityView  removeViewAnimated:YES];
                NSLog(@"%@",result);
                if ([[result  objectForKey:@"statusCode"] integerValue] == 1) {
                    
                    marrCatModelData = [[NSMutableArray  alloc] init];
                    
                    for (NSDictionary * dict in [result  objectForKey:@"Result"]) {
                        CatModel * objCatModel = [CatModel  new];
                        objCatModel.catId = [dict  objectForKey:@"cat_id"];
                        objCatModel.strsubcount = [dict  objectForKey:@"subcount"];
                        objCatModel.catName = [dict  objectForKey:@"category_name"];
                        [marrCatModelData   addObject:objCatModel];
                    }
                    
                    
                    
                    [self.tblvCatList  reloadData];
                }
                else
                {
                    
                }
            }
        }];
    }
    else
    {
        [TSMessage showNotificationWithTitle:kAlertNoNetworkTitle
                                    subtitle:kAlertNoNetworkMsg
                                        type:TSMessageNotificationTypeError];
        
    }
    
}




#pragma mark
#pragma mark TABLEVIEW DATASOURCE
#pragma mark
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger intReturn;
    intReturn = marrCatModelData?marrCatModelData.count:0;
    return intReturn;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger intReturn;
    intReturn = marrCatModelData?1:0;
    return intReturn;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    static NSString *cellIdentifier = @"Cell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        //Selected bg
        UIView * viewcellbg = [[UIView alloc] init];
        viewcellbg.backgroundColor = UIColorFromRGBWithAlpha(kazumiRedColor,1.0);
        cell.selectedBackgroundView = viewcellbg;
    }
    
    //Text label
    cell.textLabel.font = [UIFont fontWithName:kFontSFUIDisplay_Regular size:17];
    cell.textLabel.textColor = UIColorFromRGBWithAlpha(kazumiRedColor,1.0);
    
    //Accessory Type
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    CatModel * objCatModel = [marrCatModelData objectAtIndex:indexPath.section];
    cell.textLabel.text = objCatModel.catName;
    
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    return 30;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor whiteColor];
    
    ProductListViewController * objPLVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductListViewControllerIdent"];
    CatModel * objCatModel = [marrCatModelData objectAtIndex:indexPath.section];
    objPLVc.objCatModelPass = objCatModel;
    
    [self.navigationController pushViewController:objPLVc animated:YES];
    
    
     
  
    
}



-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    CatModel * objCatModel = [marrCatModelData objectAtIndex:section];
    return objCatModel.catName;
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = UIColorFromRGBWithAlpha(kazumiRedColor, 1.0);
}





@end
