//
//  OSU_orderListViewController.m
//  CSE3241_Bookstore_Project
//
//  Created by FlyinGeek on 13-4-2.
//  Copyright (c) 2013 The Ohio State University. All rights reserved.
//

#import "OSU_orderListViewController.h"
#import "OSU_3BSQLiteDatabaseHandler.h"
#import "OSU_3BShoppingCart.h"
#import "OSU_3BOrderListCell.h"

@interface OSU_orderListViewController ()
@property (strong, nonatomic) IBOutlet UIView *upperBG;
@property (strong, nonatomic) IBOutlet UIView *lowerBG;
@property (strong, nonatomic) IBOutlet UIButton *updateProfileButton;
@property (strong, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (strong, nonatomic) IBOutlet UILabel *shippingLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;

@end

@implementation OSU_orderListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar_gray.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationController.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.navigationController.navigationBar.layer.shadowRadius = 3.0f;
    self.navigationController.navigationBar.layer.shadowOpacity = 0.8f;
 
    
    self.navigationItem.hidesBackButton = YES;
    
    [self addShadow:(UIImageView *)self.upperBG towardsUp:NO];
    [self addShadow:(UIImageView *)self.lowerBG towardsUp:YES];

    OSU_3BUser *currentUser = [[OSU_3BShoppingCart sharedInstance] getCurrentCustomer];
    self.customerNameLabel.text = [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName];
    self.streetAddressLabel.text = [NSString stringWithString:currentUser.address];
    self.cityStateAndZIPCodeLabel.text = [NSString stringWithFormat:@"%@, %@ %lu", currentUser.city, currentUser.state, (unsigned long)currentUser.ZIPCode];
    self.creditCardTypeAndNumberLabel.text = [NSString stringWithFormat:@"%@ %@", currentUser.creditCardType, currentUser.creditCardNumber];
    
    self.subtotalLabel.text = [NSString stringWithFormat:@"%.2f", [[OSU_3BShoppingCart sharedInstance] subtotalValue]];
    self.shippingLabel.text = [NSString stringWithFormat:@"%.2f", [[OSU_3BShoppingCart sharedInstance] numberOfItemsInShoppingCart] * 2.0];
    self.totalLabel.text = [NSString stringWithFormat:@"%.2f", [[OSU_3BShoppingCart sharedInstance] subtotalValue] + [[OSU_3BShoppingCart sharedInstance] numberOfItemsInShoppingCart] * 2.0];
    
    // set table view background image
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_bg.png"]];
    [tempImageView setFrame:self.orderListTable.frame];
    self.orderListTable.backgroundView = tempImageView;
    
}


- (IBAction)checkOutButtonPressed {
    
    // insert an order here...
    for (int i = 0; i < [[OSU_3BShoppingCart sharedInstance] numberOfDistinctItemsInShoppingCart]; i++) {
        OSU_3BBook *book = [[OSU_3BShoppingCart sharedInstance] objectAtIndexedSubscript:i];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yy"];
        
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"HH:mm:ss"];
        
        NSDate *now = [[NSDate alloc] init];
        
        NSString *theDate = [dateFormat stringFromDate:now];
        NSString *theTime = [timeFormat stringFromDate:now];
        
        [[OSU_3BSQLiteDatabaseHandler sharedInstance] insertAnOrder:[[OSU_3BOrder alloc] initWithISBN:book.ISBN
                                                                                             Username:[[OSU_3BShoppingCart sharedInstance] getCurrentCustomer].username
                                                                                                 Date:theDate
                                                                                                 Time:theTime
                                                                                         withQuantity:book.Quantity]];
    }
    
    // creat smart category of this customer
    OSU_3BUser *currentCustomer = [[OSU_3BShoppingCart sharedInstance] getCurrentCustomer];
    currentCustomer.smartCategory = [[OSU_3BShoppingCart sharedInstance] getSmartCategory];
    
    [[OSU_3BSQLiteDatabaseHandler sharedInstance] updateUser:currentCustomer withUserType:OSU_3BUserTypeCustomer];
    
}





- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addShadow: (UIImageView *)view towardsUp:(BOOL)towardsUp
{
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    if (towardsUp) {
        [view.layer setShadowOffset:CGSizeMake(0.0f, -10.0f)];
    }
    else {
        [view.layer setShadowOffset:CGSizeMake(0.0f, 10.0f)];
    }
    [view.layer setShadowOpacity:0.4];
    [view.layer setShadowRadius:6.0];
    
    // improve performance
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = path.CGPath;
}


#pragma -- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[OSU_3BShoppingCart sharedInstance] numberOfDistinctItemsInShoppingCart];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSU_3BOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderListCell"];
    
    cell.book = [[OSU_3BShoppingCart sharedInstance]objectAtIndexedSubscript:indexPath.row];
    cell.bookTitle.text = cell.book.Titile;
    cell.bookAuthor.text = cell.book.Author;
    cell.bookPrice.text = [NSString stringWithFormat:@"$ %.2f",cell.book.Price];
    cell.bookQuantity.text = [NSString stringWithFormat:@"%u", cell.book.Quantity];
    cell.bookTotalPrice.text = [NSString stringWithFormat:@"$ %.2f", cell.book.Price * cell.book.Quantity];
    
    return cell;
}

@end
