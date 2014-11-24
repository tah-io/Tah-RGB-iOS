//
//  SocialViewController.h
//  TAH
//
//  Created by DHIRAJ JADHAO on 21/05/14.
//  Copyright (c) 2014 DHIRAJJADHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TAHble.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@class CBPeripheral;
@class TAHble;

@interface SocialViewController : UIViewController<BTSmartSensorDelegate>

{
    IBOutlet UILabel *ConnectionStatusLabel;

    SLComposeViewController *fbsheet,*tweetsheet;
}

@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) TAHble *sensor;

- (IBAction)fbpost:(id)sender;
- (IBAction)tweetpost:(id)sender;




@end
