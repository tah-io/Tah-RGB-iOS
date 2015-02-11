//
//  SettingsViewController.m
//  TAH
//
//  Created by DHIRAJ JADHAO on 09/02/14.
//  Copyright (c) 2014 DHIRAJJADHAO. All rights reserved.
//

#import "SettingsViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SettingsViewController ()
{

}
@end

@implementation SettingsViewController

@synthesize sensor;
@synthesize peripheral;




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
    
    // Sets TAH class delegate
    self.sensor.delegate = self;
 
    // Set Connection Status Image
    [self UpdateConnectionStatusLabel];

    
    
    requiredPassword.enabled = NO; // disables device password field
    requiredPassword.alpha = 0.2; // and sets it alpha level
    
    
    requiredName.text = sensor.activePeripheral.name; // Fill Name text field with the name of currectly connected device
    
}


-(void)viewWillAppear:(BOOL)animated
{
    // Set Connection Status Image
    [self UpdateConnectionStatusLabel];
}




///////////// Update Device Connection Status Image //////////
-(void)UpdateConnectionStatusLabel
{
    
    
    if (sensor.activePeripheral.state)
    {
        
        ConnectionStatusLabel.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    else
    {
        
        ConnectionStatusLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:128.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
}




//received data

-(void) TAHbleCharValueUpdated:(NSString *)UUID value:(NSData *)data
{
    

}




-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if([requiredName resignFirstResponder])
    {
            [self updateDeviceName];
    }
    
    else if([requiredPassword resignFirstResponder])
    {
        [self updateDevicePassword];
        
        sleep(0.5);

    }
    
    return YES;
}


-(void)setConnect
{

    CFStringRef s = CFUUIDCreateString(kCFAllocatorDefault, (__bridge CFUUIDRef )sensor.activePeripheral.identifier);
    NSLog(@"%@",(__bridge NSString*)s);

}





-(void)setDisconnect
{

    //////// Local Alert Settings
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    /////////////////////////////////////////////
    
    
    // Set Connection Status Image
    [self UpdateConnectionStatusLabel];
    
}






- (IBAction)ApplySettings:(id)sender
{
    if (sensor.activePeripheral.state)
    {
       
        
        [self updateDeviceSecurity];
        
        sleep(0.5);
        

        [sensor updateSettings:sensor.activePeripheral]; //resets TAH
        
  
        
        //////// Local Alert Settings
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Updated"
                                                        message:@"Changes Updated"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        
        NSLog(@"Change Update Notification sent");
        /////////////////////////////////////////////
        
        
        
        
        [sensor disconnect:sensor.activePeripheral];
        
        [self UpdateConnectionStatusLabel];
        

        
        
        
    }
    
    

    
    else
    {
        //////// Local Alert Settings
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connect to Device"
                                                        message:@"Please Connect to TAH device first"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        
        NSLog(@"Change Update Notification sent");
        /////////////////////////////////////////////
    }
    
    


}



-(void)updateDeviceName
{
    if (requiredName.text.length >=1 && requiredName.text != sensor.activePeripheral.name)
    {
        [sensor setTAHDeviceName:sensor.activePeripheral Name:requiredName.text];
        
    }
}

-(void)updateDevicePassword
{
    if (SecuritySetting.selectedSegmentIndex == 1 && requiredPassword.text.length == 6)
    {
        [sensor setTAHSecurityPin:sensor.activePeripheral Pin:requiredPassword.text];
        
    }
}

-(void)updateDeviceSecurity
{
    
    if (SecuritySetting.selectedSegmentIndex == 0)
    {
        [sensor setTAHSecurityType:sensor.activePeripheral WithPin:NO];
        requiredPassword.enabled = NO;
        requiredPassword.alpha = 0.2;
    }

}




- (IBAction)SecuritySetting:(id)sender
{
    
    if (SecuritySetting.selectedSegmentIndex == 0)
    {
        [sensor setTAHSecurityType:sensor.activePeripheral WithPin:NO];
        NSLog(@"Device Pairing with PIN OFF");
        
        requiredPassword.enabled = NO;
        requiredPassword.alpha = 0.2;
    }
    
    
    else if (SecuritySetting.selectedSegmentIndex == 1)
    {
        [sensor setTAHSecurityType:sensor.activePeripheral WithPin:YES];
        NSLog(@"Device Pairing with PIN OFF");
        
        requiredPassword.enabled = YES;
        requiredPassword.alpha = 1.0;
    }
    
}



@end
