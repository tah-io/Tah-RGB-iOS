//
//  BLEDeviceViewController.h
//  TAH
//
//  Created by TAHs on 7/13/12.
//  Copyright (c) 2012 jnhuamao.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TAHble.h"

@class BLEDeviceViewController;

@interface TAHbleTableController : UIViewController<BTSmartSensorDelegate, UITableViewDelegate, UITableViewDataSource>
{

    IBOutlet UIButton *home;
    
    IBOutlet UILabel *ConnectionStatusLabel;

}

@property (strong, nonatomic) TAHble *sensor;
@property (nonatomic, retain) NSMutableArray *peripheralViewControllerArray;

- (IBAction)scanTAHDevices:(id)sender;

-(void) scanTimer:(NSTimer *)timer;

@property (weak, nonatomic) IBOutlet UITableView *TAHTableView;

@property (weak, nonatomic) IBOutlet UIButton *Scan;

- (IBAction)home:(id)sender;


@end
