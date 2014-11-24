//
//  SocialViewController.m
//  TAH
//
//  Created by DHIRAJ JADHAO on 21/05/14.
//  Copyright (c) 2014 DHIRAJJADHAO. All rights reserved.
//

#import "SocialViewController.h"

@interface SocialViewController ()

@end

@implementation SocialViewController

@synthesize peripheral;
@synthesize sensor;

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
    // Do any additional setup after loading the view.
    
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







- (IBAction)fbpost:(id)sender {
    
    fbsheet = [[SLComposeViewController alloc] init];
    fbsheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [fbsheet setInitialText:@"Hi Guys, Check out this cool innovation platform: http://www.tah.io"];
   
    
    [self presentViewController:fbsheet animated:YES completion:nil];
}

- (IBAction)tweetpost:(id)sender {
    
    tweetsheet = [[SLComposeViewController alloc] init];
    tweetsheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetsheet setInitialText:@"Hi Guys, Check out this cool innovation platform: http://www.tah.io"];
    
    
    [self presentViewController:tweetsheet animated:YES completion:nil];
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

@end
