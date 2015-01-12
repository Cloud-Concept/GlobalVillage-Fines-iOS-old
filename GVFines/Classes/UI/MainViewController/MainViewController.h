//
//  MainViewController.h
//  GVFines
//
//  Created by Mina Zaklama on 9/30/14.
//  Copyright (c) 2014 CloudConcept. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESCPOSPrinter.h"
#import "EABluetoothPort.h"

@class NewFinesTabViewController;
@class ExistingFinesViewController;

@interface MainViewController : UIViewController
{
    NewFinesTabViewController *newFinesTabViewController;
    ExistingFinesViewController *existingFinesViewController;
    ESCPOSPrinter *escp;
}

@property (strong, nonatomic) IBOutlet UIButton *finesNewButton;
@property (strong, nonatomic) IBOutlet UIButton *finesOldButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIView *containerView;

- (IBAction)LogoutButtonClicked:(id)sender;
- (IBAction)OldFinesButtonClicked:(id)sender;
- (IBAction)NewFineButtonClicked:(id)sender;

@end
