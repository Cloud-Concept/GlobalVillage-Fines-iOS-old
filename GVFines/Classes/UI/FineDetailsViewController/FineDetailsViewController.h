//
//  FineDetailsViewController.h
//  GVFines
//
//  Created by Mina Zaklama on 10/16/14.
//  Copyright (c) 2014 CloudConcept. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"

@class Fine;

@protocol FineDetailsViewDelegate <NSObject>
@required
- (void)didFinishUpdatingFine;
- (void)closeFineDetailsPopup;
@end

@interface FineDetailsViewController : UIViewController <UIAlertViewDelegate, SFRestDelegate>
{
    Fine *currentFine;
    NSString *fineQueueId;
    NSString *GR1QueueId;
}

@property (strong, nonatomic) IBOutlet UILabel *fineNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *violationClauseLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UITextView *fineDescriptionTextView;
@property (strong, nonatomic) IBOutlet UITextView *commentsTextView;
@property (strong, nonatomic) IBOutlet UILabel *issuedByLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *statusBackgroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *rectifiedButton;
@property (strong, nonatomic) IBOutlet UIButton *rePrintButton;
@property (strong, nonatomic) IBOutlet UIButton *reIssueButton;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

@property (weak, nonatomic) id <FineDetailsViewDelegate> delegate;

- (IBAction)rectifiedButtonClicked:(id)sender;
- (IBAction)rePrintButtonClicked:(id)sender;
- (IBAction)reIsuueButtonClicked:(id)sender;
- (IBAction)closeButtonClicked:(id)sender;

- (id)initFineDetailsViewControllerWithFine:(Fine*)fine FineQueueId:(NSString*)fineQueueIdValue GR1QueueId:(NSString*)GR1QueueIdValue;

@end
