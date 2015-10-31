//
//  CaseTableViewCell.m
//  GVFines
//
//  Created by omer gawish on 9/9/15.
//  Copyright (c) 2015 CloudConcept. All rights reserved.
//

#import "CaseTableViewCell.h"
#import "Case.h"
@implementation CaseTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)init
{
    self = [super init];
        if (self)
    {
        // No need to re-assign self here... owner:self is all you need to get
        // your outlet wired up...
        UITableViewCell* xibView = [[[NSBundle mainBundle] loadNibNamed:@"CaseTableViewCell" owner:self options:nil] objectAtIndex:0];
        //xibView set
        // now add the view to ourselves...
        [self addSubview:xibView]; // we automatically retain this with -addSubview:
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCase:(Case *)someCase {
    [self.caseNumberLabel setText:someCase.caseNumber];
    [self.exhibitorName setText:someCase.exhibitorName];
    [self.serviceType setText:someCase.serviceType];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [format setDateFormat:@"yyyy-MM-dd"];
    [format setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString *createdDate = [format stringFromDate:someCase.CreatedDate];
    [self.applicationDate setText:createdDate];
    [self.status setText:someCase.Status];
    
}

@end
