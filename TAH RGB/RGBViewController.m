//
//  RGBViewController.m
//  TAH RGB
//
//  Created by Dhiraj on 17/07/14.
//  Copyright (c) 2014 dhirajjadhao. All rights reserved.
//

#import "RGBViewController.h"
#import "TAHble.h"
#import <AudioToolbox/AudioToolbox.h>

@interface RGBViewController ()

@end

@implementation RGBViewController

@synthesize sensor;
@synthesize peripheral;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Settings Up Sensor Delegate
    self.sensor.delegate = self;
    
    // Set Connection Status Image
    [self UpdateConnectionStatusLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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




//recv data
-(void) TAHbleCharValueUpdated:(NSString *)UUID value:(NSData *)data
{
    NSString *value = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSLog(@"%@",value);
}



-(void)setConnect
{
    CFStringRef s = CFUUIDCreateString(kCFAllocatorDefault, (__bridge CFUUIDRef )sensor.activePeripheral.identifier);
    NSLog(@"%@",(__bridge NSString*)s);
    
}

-(void)setDisconnect
{
    
    [sensor disconnect:sensor.activePeripheral];
    
    NSLog(@"TAH Device Disconnected");
    
    
    //////// Local Alert Settings
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    /////////////////////////////////////////////
    
    // Set Connection Status Image
    [self UpdateConnectionStatusLabel];
    
    
}





- (IBAction)Aqua:(id)sender {
    NSString *command;
    command = @"0,131,246,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)Salmon:(id)sender {
    NSString *command;
    command = @"255,100,105,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)Banana:(id)sender {
    NSString *command;
    command = @"255,231,0,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];

}

- (IBAction)Grass:(id)sender {
    NSString *command;
    command = @"83,254,125,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)Grape:(id)sender {
    
    NSString *command;
    command = @"131,30,245,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)Tangerine:(id)sender {
    
    NSString *command;
    command = @"255,126,46,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)Ice:(id)sender {
    
    NSString *command;
    command = @"84,255,254,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)Clover:(id)sender {
    
    NSString *command;
    command = @"0,127,36,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)Strawberry:(id)sender {
    
    NSString *command;
    command = @"255,0,125,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)Honeydew:(id)sender {
    
    NSString *command;
    command = @"229,51,7,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)Snow:(id)sender {
    
    NSString *command;
    command = @"255,255,255,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)Plum:(id)sender {
    
    NSString *command;
    command = @"131,6,123,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)off:(id)sender
{
    
    NSString *command;
    command = @"0,0,0,1R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}

- (IBAction)rainbow:(id)sender {
    
    NSString *command;
    command = @"255,255,255,2R";
    NSData *feed = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [sensor write:sensor.activePeripheral data:feed];
}





@end
