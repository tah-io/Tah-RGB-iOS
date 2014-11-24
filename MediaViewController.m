//
//  MediaViewController.m
//  TAH
//
//  Created by DHIRAJ JADHAO on 19/05/14.
//  Copyright (c) 2014 DHIRAJJADHAO. All rights reserved.
//

#import "MediaViewController.h"

@interface MediaViewController ()
{

    NSString *youtube;
    

}
@end

@implementation MediaViewController

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
    
    
    youtube = @"https://www.youtube.com/channel/UCY7RNCi0S8jQDE3BZQw5Gwg/videos";
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:youtube]]];



    //[webView addSubview:activityind];
    timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/2.0)
                                             target:self
                                           selector:@selector(loading)
                                           userInfo:nil
                                            repeats:YES];
    




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




-(void)loading {
    if (!webView.loading)
        [activityind stopAnimating];
    else
        [activityind startAnimating];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
