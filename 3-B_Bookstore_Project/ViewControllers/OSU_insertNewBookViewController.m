//
//  OSU_insertNewBookViewController.m
//  CSE3241_Bookstore_Project
//
//  Created by FlyinGeek on 13-4-5.
//  Copyright (c) 2013 The Ohio State University. All rights reserved.
//

#import "OSU_insertNewBookViewController.h"
#import "OSU_3BSQLiteDatabaseHandler.h"
#import "OSU_3BBook.h"
#import "KGStatusBar.h"


@interface OSU_insertNewBookViewController () 

@property (strong, nonatomic) NIDropDown *categoryDropUp;
@property (strong, nonatomic) NSArray *category;
@property (strong, nonatomic) URBAlertView *alertView;
@property (strong, nonatomic) URBAlertView *ISBNIssueAlertView;

@end

@implementation OSU_insertNewBookViewController

- (NSArray *)category
{
    if (!_category) {
        _category = [NSArray arrayWithArray:[[OSU_3BSQLiteDatabaseHandler sharedInstance] getCategoriesFromDatabase]];
    }
    return _category;
}

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
    
    self.navigationItem.hidesBackButton = YES;

    [self.authorField.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.authorField.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [self.authorField.layer setBorderWidth: 1.0];
    [self.authorField.layer setCornerRadius:8.0f];
    [self.authorField.layer setMasksToBounds:YES];
    
    [self.reviewsField.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.reviewsField.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [self.reviewsField.layer setBorderWidth: 1.0];
    [self.reviewsField.layer setCornerRadius:8.0f];
    [self.reviewsField.layer setMasksToBounds:YES];
    
    [self.categoryButton setTitle:@"Select a Category" forState:UIControlStateNormal];
    self.minQtyField.text = @"0";
    
    URBAlertView *alertView = [URBAlertView dialogWithTitle:@"Attention:" subtitle:@"Please fill out all fields!"];
	alertView.blurBackground = NO;
	[alertView addButtonWithTitle:@"OK"];
	[alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        // do stuff here
		[self.alertView hideWithCompletionBlock:^{
		}];
	}];
    
    self.alertView = alertView;
    
    
    URBAlertView *ISBNIssueAlertView = [URBAlertView dialogWithTitle:@"Sorry:" subtitle:@"Book already exists!"];
	ISBNIssueAlertView.blurBackground = NO;
	[ISBNIssueAlertView addButtonWithTitle:@"OK"];
	[ISBNIssueAlertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *ISBNIssueAlertView) {
        // do stuff here
		[self.ISBNIssueAlertView hideWithCompletionBlock:^{
		}];
	}];
    
    self.ISBNIssueAlertView = ISBNIssueAlertView;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)GoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)insertButtonPressed:(UIButton *)sender {
    if (![self.ISBNField.text isEqualToString:@""] && ![self.titleField.text isEqualToString:@""] &&
        ![self.authorField.text isEqualToString:@""] && ![self.publisherField.text isEqualToString:@""] &&
        ![self.yearField.text isEqualToString:@""] && ![self.priceField.text isEqualToString:@""] &&
        ![self.minQtyField.text isEqualToString:@""] && ![self.categoryButton.titleLabel.text isEqualToString:@"Select a Category"]) {
        

        
        if ([[OSU_3BSQLiteDatabaseHandler sharedInstance] bookIsInDatabase:self.ISBNField.text]) {
            [self.ISBNIssueAlertView showWithAnimation:URBAlertAnimationTumble];
        }
        else {
            // everything is clear
            OSU_3BBook *newBook = [[OSU_3BBook alloc] initWithISBN:self.ISBNField.text
                                                             Title:self.titleField.text
                                                            Author:self.authorField.text
                                                         Publisher:self.publisherField.text
                                                              Year:(NSUInteger)[self.yearField.text integerValue]
                                                             Price:[[NSString stringWithFormat:@"%.2f", [self.priceField.text doubleValue]]doubleValue]
                                                          Category:self.categoryButton.titleLabel.text
                                                           Reviews:self.reviewsField.text
                                                    MinQtyRequired:[self.minQtyField.text integerValue]];
            
            [[OSU_3BSQLiteDatabaseHandler sharedInstance]insertNewBook:newBook];
            
            [KGStatusBar showSuccessWithStatus:@"Insert Successfully"];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    else {
        [self.alertView showWithAnimation:URBAlertAnimationDefault];
    }
}

- (IBAction)creditCardTypeButtonPressed:(UIButton *)sender {
    
    if(_categoryDropUp == nil) {
        NSArray *arr = [NSArray arrayWithArray:self.category];
        
        CGFloat f = 200;
        _categoryDropUp = [[NIDropDown alloc] initDropDown:sender Height:&f Array:arr Direction:@"up"];
        _categoryDropUp.delegate = self;
        _categoryDropUp.identifier = @"categoryDropUp";
    }
    else {
        [self.categoryDropUp hideDropDown:sender];
        self.categoryDropUp = nil;
    }
}

#pragma -- Protocols

- (IBAction)userDidTapOnBackground:(UITapGestureRecognizer *)sender {
    [self.ISBNField resignFirstResponder];
    [self.titleField resignFirstResponder];
    [self.authorField resignFirstResponder];
    [self.publisherField resignFirstResponder];
    [self.yearField resignFirstResponder];
    [self.priceField resignFirstResponder];
    [self.minQtyField resignFirstResponder];
    [self.reviewsField resignFirstResponder];
    [self.categoryButton resignFirstResponder];
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect frame = textView.frame;
    int offset = frame.origin.y + frame.size.height - (self.view.frame.size.height - 216.0);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];

}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    self.categoryDropUp = nil;
}

@end
