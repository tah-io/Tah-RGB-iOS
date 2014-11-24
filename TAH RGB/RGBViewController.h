//
//  RGBViewController.h
//  TAH RGB
//
//  Created by Dhiraj on 17/07/14.
//  Copyright (c) 2014 dhirajjadhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAHble.h"



@class CBPeripheral;
@class TAHble;

@interface RGBViewController : UIViewController<BTSmartSensorDelegate>
{

    IBOutlet UIButton *Aqua;
    IBOutlet UIButton *Salmon;
    IBOutlet UIButton *Banana;
    IBOutlet UIButton *Grass;
    IBOutlet UIButton *Grape;
    IBOutlet UIButton *Tangerine;
    IBOutlet UIButton *Ice;
    IBOutlet UIButton *Clover;
    IBOutlet UIButton *Strawberry;
    IBOutlet UIButton *Honwydew;
    IBOutlet UIButton *Snow;
    IBOutlet UIButton *Plum;
    
    
    IBOutlet UIButton *rainbow;
    IBOutlet UIButton *off;
    IBOutlet UILabel *ConnectionStatusLabel;
    

}



@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) TAHble *sensor;


- (IBAction)Aqua:(id)sender;
- (IBAction)Salmon:(id)sender;
- (IBAction)Banana:(id)sender;
- (IBAction)Grass:(id)sender;
- (IBAction)Grape:(id)sender;
- (IBAction)Tangerine:(id)sender;
- (IBAction)Ice:(id)sender;
- (IBAction)Clover:(id)sender;
- (IBAction)Strawberry:(id)sender;
- (IBAction)Honeydew:(id)sender;
- (IBAction)Snow:(id)sender;
- (IBAction)Plum:(id)sender;



- (IBAction)off:(id)sender;
- (IBAction)rainbow:(id)sender;




@end
