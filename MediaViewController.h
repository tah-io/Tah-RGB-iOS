//
//  MediaViewController.h
//  TAH
//
//  Created by DHIRAJ JADHAO on 19/05/14.
//  Copyright (c) 2014 DHIRAJJADHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TAHble.h"

@class CBPeripheral;
@class TAHble;

@interface MediaViewController : UIViewController<BTSmartSensorDelegate>
{

    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *activityind;
    NSTimer *timer;
    
    IBOutlet UILabel *ConnectionStatusLabel;
    
    
}

@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) TAHble *sensor;


@end
