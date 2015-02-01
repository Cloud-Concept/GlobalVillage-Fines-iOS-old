//
//  FineDetailsViewController.m
//  GVFines
//
//  Created by Mina Zaklama on 10/16/14.
//  Copyright (c) 2014 CloudConcept. All rights reserved.
//

#import "FineDetailsViewController.h"
#import "Fine.h"
#import "HelperClass.h"
#import "SFRestRequest.h"
#import "SFUserAccountManager.h"

@interface FineDetailsViewController ()

@end

@implementation FineDetailsViewController

- (id)initFineDetailsViewControllerWithFine:(Fine*)fine FineQueueId:(NSString*)fineQueueIdValue GR1QueueId:(NSString*)GR1QueueIdValue {
    self =  [super initWithNibName:nil bundle:nil];
    
    currentFine = fine;
    fineQueueId = fineQueueIdValue;
    GR1QueueId = GR1QueueIdValue;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.fineNumberLabel setText:currentFine.CaseNumber];
    [self.violationClauseLabel setText:currentFine.ViolationClause];
    [self.categoryLabel setText:[NSString stringWithFormat:@"%@ - %@", currentFine.BusinessCategory, currentFine.SubCategory]];
    [self.fineDescriptionTextView setText:currentFine.ViolationDescription];
    [self.fineDescriptionTextView setFont:[UIFont systemFontOfSize:16]];
    [self.commentsTextView setText:currentFine.Comments];
    [self.commentsTextView setFont:[UIFont systemFontOfSize:16]];
    [self.issuedByLabel setText:currentFine.CreatedBy];
    [self.statusLabel setText:currentFine.Status];
    [self.createdDateLabel setText:[HelperClass formatDateTimeToString:currentFine.CreatedDate]];
    
    [HelperClass setStatusBackground:currentFine ImageView:self.statusBackgroundImageView];
    
    [self setButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rectifiedButtonClicked:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Rectify" message:@"Are you sure you want to rectify this fine?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    alert.tag = 1;
    
    [alert show];
}

- (IBAction)rePrintButtonClicked:(id)sender {
    [HelperClass printReceiptForFine:currentFine];
}

- (IBAction)reIsuueButtonClicked:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Re-Issue" message:@"Are you sure you want to re-issue this fine?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeAlphabet];
    [[alert textFieldAtIndex:0] setText:currentFine.Comments];
    
    alert.tag = 2;
    
    [alert show];
}

- (IBAction)closeButtonClicked:(id)sender {
    [self.delegate closeFineDetailsPopup];
}

- (void)setButtons {
    if ([currentFine.Status isEqualToString:@"Rectified"] ||
        [currentFine.Status isEqualToString:@"Fine Rejected"] ||
        [currentFine.Status isEqualToString:@"1st Fine Printed"] ||
        [currentFine.Status isEqualToString:@"2nd Fine Printed"] ||
        [currentFine.Status isEqualToString:@"3rd Fine Printed"] ||
        [currentFine.Status isEqualToString:@"3rd Fine Approved"])
    {
        [self.rectifiedButton setEnabled:NO];
        [self.reIssueButton setEnabled:NO];
    }
    
    if ([currentFine.Status isEqualToString:@"Rectified"] ||
        [currentFine.Status isEqualToString:@"Fine Rejected"])
    {
        [self.rePrintButton setEnabled:NO];
    }
}

- (void)initializeAndStartActivityIndicatorSpinner {
    if(![self.loadingView isHidden])
        return;
    
    [self.loadingView setHidden:NO];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

- (void)stopActivityIndicatorSpinner {
    [self.loadingView setHidden:YES];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        return;
    
    if (alertView.tag == 1 && buttonIndex == 1) //Rectify AlertView
    {
        [self initializeAndStartActivityIndicatorSpinner];
        SFRestRequest *request = [[SFRestAPI sharedInstance] requestForUpdateWithObjectType:@"Case" objectId:currentFine.Id fields:[NSDictionary dictionaryWithObject:@"Rectified" forKey:@"Status"]];
        
        [[SFRestAPI sharedInstance] send:request delegate:self];
    }
    else if(alertView.tag == 2 && buttonIndex == 1) //Re-Issue AlertView
    {
        [self initializeAndStartActivityIndicatorSpinner];
        
        NSString *newStatus = @"";
        NSString *ownerId = @"";
        
        UITextField *alertTextField = [alertView textFieldAtIndex:0];
        NSString *commetns = alertTextField.text;
        
        if ([currentFine.Status isEqualToString:@"1st Fine Approved"]) {
            newStatus = @"2nd Fine Printed";
            ownerId = fineQueueId;
        }
        else if ([currentFine.Status isEqualToString:@"2nd Fine Approved"]) {
            newStatus = @"3rd Fine Printed";
            ownerId = GR1QueueId;
        }
        else if ([currentFine.Status isEqualToString:@"3rd Fine Open"]) {
            newStatus = @"3rd Fine Printed";
            ownerId = GR1QueueId;
        }
        
        SFUserAccountManager *accountManager = [SFUserAccountManager sharedInstance];
        
        SFRestRequest *request = [[SFRestAPI sharedInstance] requestForUpdateWithObjectType:@"Case"
                                                                                   objectId:currentFine.Id
                                                                                     fields:[NSDictionary dictionaryWithObjects:@[newStatus, ownerId, commetns, accountManager.currentUser.credentials.userId]
                                                                                                                        forKeys:@[@"Status", @"OwnerId", @"Comments__c", @"Latest_Fine_Issuer__c"]]];
        
        [[SFRestAPI sharedInstance] send:request delegate:self];
    }
}

#pragma SFRestDelegate
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    
    currentFine.Status = [request.queryParams objectForKey:@"Status"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopActivityIndicatorSpinner];
        if (![currentFine.Status isEqualToString:@"Rectified"])
            [HelperClass printReceiptForFine:currentFine];
        [self.delegate didFinishUpdatingFine];
    });
}

- (void)request:(SFRestRequest *)request didFailLoadWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopActivityIndicatorSpinner];
        [HelperClass messageBox:@"An error occured while updating the fine." withTitle:@"Error"];
    });
}

@end
