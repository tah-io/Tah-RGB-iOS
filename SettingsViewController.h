//
//  SettingsViewController.h
//  TAH
//
//  Created by DHIRAJ JADHAO on 11/05/14.
//  Copyright (c) 2014 DHIRAJJADHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAHble.h"


@class TAHble;
@class CBPeripheral;

@interface SettingsViewController : UIViewController<BTSmartSensorDelegate>
{
    

    

    IBOutlet UITextField *requiredName;
    IBOutlet UITextField *requiredPassword;

    IBOutlet UISegmentedControl *SecuritySetting;
    
    IBOutlet UIButton *ApplySettings;
    
    IBOutlet UILabel *ConnectionStatusLabel;
    
}


@property (strong, nonatomic) TAHble *sensor;
@property (strong, nonatomic) CBPeripheral *peripheral;


- (IBAction)ApplySettings:(id)sender;

- (IBAction)SecuritySetting:(id)sender;


@end
