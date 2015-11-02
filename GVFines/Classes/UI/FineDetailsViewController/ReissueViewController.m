//
//  ReissueViewController.m
//  GVFines
//
//  Created by omer gawish on 10/28/15.
//  Copyright © 2015 CloudConcept. All rights reserved.
//

#import "ReissueViewController.h"
#import "SVProgressHUD.h"

@interface ReissueViewController ()
@property (weak, nonatomic) IBOutlet UITextView *commentsView;

@end

@implementation ReissueViewController


- (id)initWithFine:(Fine*)fine FineQueueId:(NSString*)fineQueueIdValue GR1QueueId:(NSString*)GR1QueueIdValue BusinessCategory:(BusinessCategory *)category SubCategory:(SubCategory *)subCategory {
    self =  [super initWithNibName:nil bundle:nil];
    
    self.fine = fine;
    self.category = category;
    self.subCategory = subCategory;
    self.fineQueueId = fineQueueIdValue;
    self.GR1QueueId = GR1QueueIdValue;
    
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commentsView.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelBtnClicked:(id)sender {
    [self.delegate closeFineDetailsPopup];
}
- (IBAction)printClicked:(id)sender {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Loading..."];
        NSString *newStatus = @"";
        NSString *ownerId = @"";
        //        UIAlertController *addImages = [UIAlertController alertControllerWithTitle:@"More Images" message:@"Do went to upload more images?" preferredStyle:UIAlertControllerStyleAlert];
        //        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //            [self cameraButtonClicked:self];
        //        }];
        //        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //            //[self cameraButtonClicked:self];
        //        }];
        //        [addImages addAction:yesAction];
        //        [addImages addAction:noAction];
        //
        //        dispatch_sync(dispatch_get_main_queue(), ^{
        //        [self presentViewController:addImages animated:YES completion:nil];
        //        });
        //UITextField *alertTextField = [alertView textFieldAtIndex:0];
        NSString *commetns = self.commentsView.text;
        NSLog(@"%@",self.fine.Status);
        if ([self.fine.Status isEqualToString:@"1st Fine Approved"]) {
            newStatus = @"2nd Fine Printed";
            ownerId = self.fineQueueId;
        }
        else if ([self.fine.Status isEqualToString:@"2nd Fine Approved"]) {
            newStatus = @"3rd Fine Printed";
            ownerId = self.GR1QueueId;
        }
        else if ([self.fine.Status isEqualToString:@"3rd Fine Open"]) {
            newStatus = @"3rd Fine Printed";
            ownerId = self.GR1QueueId;
        }
        else if([self.fine.Status isEqualToString:@"Warning Approved"]){ //Discuss
            newStatus = @"1nd Fine Printed";
            ownerId = self.GR1QueueId;
        }
        /*NewFinesView *fineview = [[NewFinesView alloc] initWithFine:currentFine];
         [self presentViewController:fineview animated:YES completion:nil];*/
        
        SFUserAccountManager *accountManager = [SFUserAccountManager sharedInstance];
        
        /* SFRestRequest *request = [[SFRestAPI sharedInstance] requestForUpdateWithObjectType:@"Case"
         objectId:currentFine.Id
         fields:[NSDictionary dictionaryWithObjects:@[newStatus, ownerId, commetns, accountManager.currentUser.credentials.userId]
         forKeys:@[@"Status", @"OwnerId", @"Comments__c", @"Latest_Fine_Issuer__c"]]];
         */
        NSString *dateInString = [SFDateUtil toSOQLDateTimeString:[NSDate date] isDateTime:true];
        //selectedPavilionFineObject.Id, @"Pavilion_Fine_Type__c",
        NSDictionary *fields = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.fine.Id,@"Parent_Fine__c",
                                ownerId, @"OwnerId",
                                accountManager.currentUser.credentials.userId, @"Latest_Fine_Issuer__c",
                                @"012g00000000l68", @"RecordTypeId",
                                self.category.Id, @"AccountId",
                                self.subCategory.Id, @"Shop__c",
                                self.fine.Comments, @"Comments__c",
                                newStatus,@"Status",
                                dateInString, @"Fine_Last_Status_Update_Date__c",
                                nil];
        SFRestRequest *request = [[SFRestAPI sharedInstance] requestForCreateWithObjectType:@"Case" fields:fields];
        
        [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (IBAction)cameraButtonClicked:(id)sender {
    //[self dismissKeyboard];
    
    CaptureImagesViewController *captureImagesController = [[CaptureImagesViewController alloc] init];
    
    captureImagesController.mainViewController = self.parentViewController;
    //captureImagesController.mainViewController = self;
    captureImagesController.imagesArray = [[NSMutableArray alloc] initWithArray:self.imagesArray];
    captureImagesController.delegate = self;
    
    self.imagesSelectionPopover = [[UIPopoverController alloc] initWithContentViewController:captureImagesController];
    self.imagesSelectionPopover.popoverContentSize = captureImagesController.view.frame.size;
    
    self.imagesSelectionPopover.delegate = self;
    
    UIButton *senderButton = (UIButton*)sender;
    
    [self.imagesSelectionPopover presentPopoverFromRect:senderButton.frame inView:senderButton.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)uploadAttachmentsWithCaseId:(NSString *)caseId{
    //[self initializeAndStartActivityIndicatorSpinner];
    
//    int totalAttachmentsToUpload = self.imagesArray.count;
//    attachmentsReturned = 0;
//    failedImagedArray = [NSMutableArray new];
//    attachmentParentId = caseId;
    
    for (UIImage *image in self.imagesArray) {
        
        void (^errorBlock) (NSError*) = ^(NSError *e) {
//            [failedImagedArray addObject:image];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self uploadDidReturn];
//            });
        };
        
        void (^successBlock)(NSDictionary *dict) = ^(NSDictionary *dict) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self uploadDidReturn];
//            });
        };
        
        UIImage *resizedImage = [HelperClass imageWithImage:image ScaledToSize:CGSizeMake(480, 640)];
        
        NSData *imageData = UIImagePNGRepresentation(resizedImage);
        
        NSString *string = [imageData base64EncodedStringWithOptions:0];
        
        NSDictionary *fields = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"Image", @"Name",
                                @"image", @"ContentType",
                                caseId, @"ParentId",
                                string, @"Body",
                                nil];
        
        //isUploadingAttachments = YES;
        [[SFRestAPI sharedInstance] performCreateWithObjectType:@"Attachment"
                                                         fields:fields
                                                      failBlock:errorBlock
                                                  completeBlock:successBlock];
    }
}

#pragma CaptureImagesViewControllerDelegate
- (void)refreshImagesArray:(NSMutableArray*)imagesMutableArray {
    self.imagesArray = [NSArray arrayWithArray:imagesMutableArray];
}

#pragma SFRestDelegate
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSLog(@"%@",jsonResponse);
    
    self.fine.Status = [request.queryParams objectForKey:@"Status"];
    [self uploadAttachmentsWithCaseId:jsonResponse];
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self stopActivityIndicatorSpinner];
        if (![self.fine.Status isEqualToString:@"Rectified"])
            [HelperClass printReceiptForFine:self.fine];
        [self.delegate didFinishUpdatingFine];
         [SVProgressHUD dismiss];
    });
}

- (void)request:(SFRestRequest *)request didFailLoadWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self stopActivityIndicatorSpinner];
         [SVProgressHUD dismiss];
        [HelperClass messageBox:@"An error occured while updating the fine." withTitle:@"Error"];
    });
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Comments"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Comments";
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
