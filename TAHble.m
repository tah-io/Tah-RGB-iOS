//
//  TAHble.m
//  Created by Dhiraj Jadhao on 9/06/2014.
//  Copyright (c) 2014 www.tah.io
//  All rights reserved.


#import "TAHble.h"

@implementation TAHble

@synthesize delegate;
@synthesize peripherals;
@synthesize manager;
@synthesize activePeripheral;



/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16
 *
 *  @return Byteswapped UInt16
 */

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}



/*
 * (void) setup
 * enable CoreBluetooth CentralManager and set the delegate for TAHble
 *
 */

-(void) setup
{
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}



/*
 * -(int) findTAHPeripherals:(int)timeout
 *
 */
-(int) findTAHPeripherals:(int)timeout
{
    if ([manager state] != CBCentralManagerStatePoweredOn) {
        printf("CoreBluetooth is not correctly initialized !\n");
        return -1;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    //[manager scanForPeripheralsWithServices:[NSArray arrayWithObject:serviceUUID] options:0]; // start Scanning
    [manager scanForPeripheralsWithServices:nil options:0];
    return 0;
}



/*
 * scanTimer
 * when findTAHPeripherals is timeout, this function will be called
 *
 */
-(void) scanTimer:(NSTimer *)timer
{
    [manager stopScan];
}



/*
 *  @method printPeripheralInfo:
 *
 *  @param peripheral Peripheral to print info of
 *
 *  @discussion printPeripheralInfo prints detailed info about peripheral
 *
 */
- (void) printPeripheralInfo:(CBPeripheral*)peripheral {
    CFStringRef s = CFUUIDCreateString(NULL, (__bridge CFUUIDRef )peripheral.identifier);
    printf("------------------------------------\r\n");
    printf("Peripheral Info :\r\n");
    printf("UUID : %s\r\n",CFStringGetCStringPtr(s, 0));
    printf("RSSI : %d\r\n",[peripheral.RSSI intValue]);
    printf("Name : %s\r\n",[peripheral.name cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    printf("isConnected : %d\r\n",peripheral.state == CBPeripheralStateConnected);
    printf("-------------------------------------\r\n");
    
}



/*
 * connect
 * connect to a given peripheral
 *
 */
-(void) connect:(CBPeripheral *)peripheral
{
    if (!(peripheral.state == CBPeripheralStateConnected)) {
        [manager connectPeripheral:peripheral options:nil];
    }
}

-(void) stopScan
{
    [manager stopScan];
}



/*
 * disconnect
 * disconnect to a given peripheral
 *
 */
-(void) disconnect:(CBPeripheral *)peripheral
{
    [manager cancelPeripheralConnection:peripheral];
}




#pragma mark - basic operations for TAHble service
-(void) write:(CBPeripheral *)peripheral data:(NSData *)data
{
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}



-(void) read:(CBPeripheral *)peripheral
{
    printf("begin reading\n");
    //[peripheral readValueForCharacteristic:dataRecvrCharacteristic];
    printf("now reading......\n");
}



-(void) notify: (CBPeripheral *)peripheral on:(BOOL)on
{
    [self notification:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral on:YES];
}




#pragma mark - CBCentralManager Delegates

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //TODO: to handle the state updates
}



- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    printf("New Device Found\n");
    if (!peripherals)
    {
        peripherals = [[NSMutableArray alloc] initWithObjects:peripheral, nil];
        for (int i = 0; i < [peripherals count]; i++) {
            [delegate peripheralFound: peripheral];
        }
    }
    
    else
    {
        if((__bridge CFUUIDRef )peripheral.identifier == NULL) return;
        //if(peripheral.name == NULL) return;
        //if(peripheral.name == nil) return;
        if(peripheral.name.length < 1) return;
        // Add the new peripheral to the peripherals array
        for (int i = 0; i < [peripherals count]; i++) {
            CBPeripheral *p = [peripherals objectAtIndex:i];
            if((__bridge CFUUIDRef )p.identifier == NULL) continue;
            CFUUIDBytes b1 = CFUUIDGetUUIDBytes((__bridge CFUUIDRef )p.identifier);
            CFUUIDBytes b2 = CFUUIDGetUUIDBytes((__bridge CFUUIDRef )peripheral.identifier);
            if (memcmp(&b1, &b2, 16) == 0) {
                // these are the same, and replace the old peripheral information
                [peripherals replaceObjectAtIndex:i withObject:peripheral];
                printf("Known Device Found...\n");
                //[delegate peripheralFound: peripheral];
                return;
            }
        }
        printf("New Device Found\n");
        [peripherals addObject:peripheral];
        [delegate peripheralFound:peripheral];
        return;
    }
}



-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    
    [activePeripheral discoverServices:nil];
    //[self notify:peripheral on:YES];
    
    [self printPeripheralInfo:peripheral];
    
    printf("Connected to active peripheral Device\n");
}



-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    printf("Disconnected from the active peripheral Device\n");
    if(activePeripheral != nil)
        [delegate setDisconnect];
    activePeripheral = nil;
}



-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect active peripheral %@: %@\n", [peripheral name], [error localizedDescription]);
}



#pragma mark - CBPeripheral delegates

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    printf("Updating Value For Characteristic function\n");
    
    if (error) {
        printf("Updating Value For Characteristic Failed\n");
        return;
    }
    [delegate TAHbleCharValueUpdated:@"FFE1" value:characteristic.value];
    
}

//////////////////////////////////////////////////////////////////////////////////////////////



- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}



- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}



- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}



/*
 *  @method getAllCharacteristicsFromKeyfob
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllCharacteristicsFromKeyfob starts a characteristics discovery on a peripheral
 *  pointed to by p
 *
 */
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p{
    for (int i=0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        printf("Fetching characteristics for service with UUID : %s\r\n",[self CBUUIDToString:s.UUID]);
        [p discoverCharacteristics:nil forService:s];
    }
}



/*
 *  @method didDiscoverServices
 *
 *  @param peripheral Pheripheral that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverServices is called when CoreBluetooth has discovered services on a
 *  peripheral after the discoverServices routine has been called on the peripheral
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        printf("Services of peripheral with UUID : %s found\r\n",[self UUIDToString:(__bridge CFUUIDRef )peripheral.identifier]);
        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else {
        printf("Service discovery was unsuccessfull !\r\n");
    }
}



/*
 *  @method didDiscoverCharacteristicsForService
 *
 *  @param peripheral Pheripheral that got updated
 *  @param service Service that characteristics where found on
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverCharacteristicsForService is called when CoreBluetooth has discovered
 *  characteristics on a service, on a peripheral after the discoverCharacteristics routine has been called on the service
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        printf("Characteristics of service with UUID : %s found\r\n",[self CBUUIDToString:service.UUID]);
        for(int i = 0; i < service.characteristics.count; i++) { //Show every one
            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
            printf("Found characteristic %s\r\n",[ self CBUUIDToString:c.UUID]);
        }
        
        char t[16];
        t[0] = (SERVICE_UUID >> 8) & 0xFF;
        t[1] = SERVICE_UUID & 0xFF;
        NSData *data = [[NSData alloc] initWithBytes:t length:16];
        CBUUID *uuid = [CBUUID UUIDWithData:data];
        //CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
        if([self compareCBUUID:service.UUID UUID2:uuid]) {
            printf("Try to open notify\n");
            [self notify:peripheral on:YES];
        }
    }
    else {
        printf("Characteristic discorvery unsuccessfull !\r\n");
    }
}





- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        printf("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:(__bridge CFUUIDRef )peripheral.identifier]);
        [delegate setConnect];
        
    }
    else {
        printf("Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:(__bridge CFUUIDRef )peripheral.identifier]);
        printf("Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
}



/*
 *  @method CBUUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using printf()
 *
 */
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}




/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}



/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}




/*
 *  @method findServiceFromUUID:
 *
 *  @param UUID CBUUID to find in service list
 *  @param p Peripheral to find service on
 *
 *  @return pointer to CBService if found, nil if not
 *
 *  @discussion findServiceFromUUID searches through the services list of a peripheral to find a
 *  service with a specific UUID
 *
 */
-(CBService *) findServiceFromUUIDEx:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}



/*
 *  @method findCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in Characteristic list of service
 *  @param service Pointer to CBService to search for charateristics on
 *
 *  @return pointer to CBCharacteristic if found, nil if not
 *
 *  @discussion findCharacteristicFromUUID searches through the characteristic list of a given service
 *  to find a characteristic with a specific UUID
 *
 */
-(CBCharacteristic *) findCharacteristicFromUUIDEx:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}




/*
 *  @method notification:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for enabling and disabling notification services. It converts integers
 *  into CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, the notfication is set.
 *
 */
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}




/*!
 *  @method writeValue:
 *
 *  @param serviceUUID Service UUID to write to (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to write to (e.g. 0x2401)
 *  @param data Data to write to peripheral
 *  @param p CBPeripheral to write to
 *
 *  @discussion Main routine for writeValue request, writes without feedback. It converts integer into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, value is written. If not nothing is done.
 *
 */

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    
    if(characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
    {
        [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }else
    {
        [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}




/*!
 *  @method readValue:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for read value request. It converts integers into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, the read value is started. When value is read the didUpdateValueForCharacteristic
 *  routine is called.
 *
 *  @see didUpdateValueForCharacteristic
 */

-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p {
    printf("Reading Value..");
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    [p readValueForCharacteristic:characteristic];
    
    
}


//////////////////////////////////// TAH Pin Controls /////////////////////////////////

////////////////// TAH Pins Digital Value control ///////////////////


-(void) TAHdigitalWrite:(CBPeripheral *)peripheral PinNumber:(int)Pin Value:(int)Value
{
    NSString *str1 = @"0,";
    NSString *str2 = [NSString stringWithFormat:@"%d",Pin];
    NSString *str3 = [NSString stringWithFormat:@"%@%d%@",@",",Value,@"R"];
    
    NSString *dataString = [NSString stringWithFormat:@"%@%@%@",str1,str2,str3];
    
    
    NSData *data = [dataString dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
    
}


////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////// TAH Pins Analog Value control ////////////////////////////

-(void) TAHanalogWrite:(CBPeripheral *)peripheral PinNumber:(int)Pin Value:(int)Value
{
    NSString *str1 = @"1,";
    NSString *str2 = [NSString stringWithFormat:@"%d",Pin];
    NSString *str3 = [NSString stringWithFormat:@"%@%d%@",@",",Value,@"R"];
    
    NSString *dataString = [NSString stringWithFormat:@"%@%@%@",str1,str2,str3];
    
    
    NSData *data = [dataString dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}




//////////////////////  TAH PWM Servo control pins //////////////////////


-(void) TAHservoWrite:(CBPeripheral *)peripheral PinNumber:(int)Pin Angle:(int)Angle
{
    
    NSString *str1 = @"2,";
    NSString *str2 = [NSString stringWithFormat:@"%d",Pin];
    NSString *str3 = [NSString stringWithFormat:@"%@%d%@",@",",Angle,@"R"];
    
    NSString *dataString = [NSString stringWithFormat:@"%@%@%@",str1,str2,str3];
    
    
    NSData *data = [dataString dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}
//////////////////////////////////////////////////////////////////////////////////////



/////////// TAH Keyboard and Mouse Control //////////




-(void) TAHkeyPress:(CBPeripheral *)peripheral Press:(int)key
{
    
    NSString *string1 = @"0,0,0,";
    NSString *end = @"M";
    NSString *command = [NSString stringWithFormat:@"%@%d%@",string1,key,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}





-(void) TAHMouseMove:(CBPeripheral *)peripheral Xaxis:(float)Xaxis Yaxis:(float)Yaxis Scroll:(float)Scroll
{
    
    NSString *command,*mouseX,*mouseY,*scroll,*keypress,*end,*seperator;
    
    mouseX = [NSString stringWithFormat:@"%.0f",Xaxis];
    mouseY = [NSString stringWithFormat:@"%.0f",Yaxis];
    scroll = [NSString stringWithFormat:@"%.0f",Scroll];
    keypress = @"0";
    seperator = @",";
    end = @"M";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",mouseX,seperator,mouseY,seperator,scroll,seperator,keypress,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}





-(void) TAHTrackPad:(CBPeripheral *)peripheral Swipe:(int)Swipe
{
    if (Swipe == Up)
    {
        NSData *data = [@"0,0,0,256M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
    else if (Swipe == Down)
    {
        NSData *data = [@"0,0,0,257M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
    
    else if (Swipe == Right)
    {
        NSData *data = [@"0,0,0,258M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
    
    else if (Swipe == Left)
    {
        NSData *data = [@"0,0,0,259M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
}



//////////////////////////////////////////////////////


////////////////// TAH AT Command Set //////////////////

// Parameters which are altered takes effect only after Reboot

// Resets TAH
-(void)updateSettings:(CBPeripheral *)peripheral
{
    
    NSData *data = [@"AT+RESET" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}


// Get TAH Mac Address

-(void)getTAHMacAddress:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+ADDR?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}

// Get TAH Advertising Interval

-(void)getTAHadvertisinginterval:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+ADVI?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}

// Get TAH Battery Level

-(void)getTAHbatterylevel:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+BATT?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}

// Get TAH Baud Rate

-(void)getTAHBaudRate:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+BAUD?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}

// Get TAH Characteristics Value

-(void)getTAHcharacteristicsValue:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+CHAR?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}



// Get TAH Beacon Mode

-(void)getTAHBeaconMode:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+IBEA?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Beacon UUID 0

-(void)getTAHBeaconUUID0:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+IBE0?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}

// Get TAH Beacon UUID 1

-(void)getTAHBeaconUUID1:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+IBE1?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Beacon UUID 2

-(void)getTAHBeaconUUID2:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+IBE2?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Beacon UUID 3

-(void)getTAHBeaconUUID3:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+IBE3?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


-(void)setTAHBeaconUUID0:(CBPeripheral *)peripheral UUID0:(char)UUID0
{
    if (UUID0 >=7)
    {
        NSString *str1 = @"AT+IBE0";
        NSString *str2 = [NSString stringWithFormat:@"%hhd", UUID0];
        
        NSString *str3 = [NSString stringWithFormat:@"%@%@", str1,str2];
        
        NSData *data = [str3 dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
}



-(void)setTAHBeaconUUID1:(CBPeripheral *)peripheral UUID1:(char)UUID1
{
    if (UUID1 >=7)
    {
        NSString *str1 = @"AT+IBE1";
        NSString *str2 = [NSString stringWithFormat:@"%hhd", UUID1];
        
        NSString *str3 = [NSString stringWithFormat:@"%@%@", str1,str2];
        
        NSData *data = [str3 dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
}



-(void)setTAHBeaconUUID2:(CBPeripheral *)peripheral UUID2:(char)UUID2
{
    if (UUID2 >=7)
    {
        NSString *str1 = @"AT+IBE2";
        NSString *str2 = [NSString stringWithFormat:@"%hhd", UUID2];
        
        NSString *str3 = [NSString stringWithFormat:@"%@%@", str1,str2];
        
        NSData *data = [str3 dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
}




-(void)setTAHBeaconUUID3:(CBPeripheral *)peripheral UUID3:(char)UUID3
{
    if (UUID3 >=7)
    {
        NSString *str1 = @"AT+IBE3";
        NSString *str2 = [NSString stringWithFormat:@"%hhd", UUID3];
        
        NSString *str3 = [NSString stringWithFormat:@"%@%@", str1,str2];
        
        NSData *data = [str3 dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
}





// Get TAH Beacon Major Value

-(void)getTAHBeaconMajor:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+MARJ?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Beacon Minor Value

-(void)getTAHBeaconMinor:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+MINO?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}




-(void)setTAHBeaconMajor:(CBPeripheral *)peripheral Major:(char)Major
{
    if (Major >=3)
    {
        NSString *str1 = @"AT+MARJ0x";
        NSString *str2 = [NSString stringWithFormat:@"%hhd", Major];
        
        NSString *str3 = [NSString stringWithFormat:@"%@%@", str1,str2];
        
        NSData *data = [str3 dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}


-(void)setTAHBeaconMinor:(CBPeripheral *)peripheral Minor:(char)Minor
{
    if (Minor >=3)
    {
        NSString *str1 = @"AT+MINO0x";
        NSString *str2 = [NSString stringWithFormat:@"%hhd", Minor];
        
        NSString *str3 = [NSString stringWithFormat:@"%@%@", str1,str2];
        
        NSData *data = [str3 dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}





// Get TAH Working Mode

-(void)getTAHWorkingMode:(CBPeripheral *)peripheral;
{
    NSData *data = [@"AT+MODE?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Notification Mode

-(void)getTAHNotificationParameter:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+NOTI?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Device Name

-(void)getTAHDeviceName:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+NAME?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Security Pin Number

-(void)getTAHSecurityPin:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+PASS?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Tranmission Power

-(void)getTAHTransmissionPower:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+POWE?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Sleep Mode Type

-(void)getTAHSleepModeType:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+PWRM?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Restore TAH to Factory Settings

-(void)restoreTAHfactorysettings:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+RENEW?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}




// Get TAH RSSI Value

-(void)getTAHRSSIValue:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+RSSI?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Secrity Type

-(void)getTAHSecurityType:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+TYPE?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Service UUID

-(void)getTAHServiceUUID:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+UUID?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Get TAH Firmware Version

-(void)getTAHfirmwareVersion:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+VERS?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}



// Set TAH Advertising Interval

-(void)setTAHadvertisinginterval:(CBPeripheral *)peripheral interval:(int)interval
{
    NSData *data;
    
    if (interval == 100)
    {
        data = [@"AT+ADVI0" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (interval == 1285)
    {
        data = [@"AT+ADVI1" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (interval == 2000)
    {
        data = [@"AT+ADVI2" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (interval ==  3000)
    {
        data = [@"AT+ADVI3" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    else if (interval ==  4000)
    {
        data = [@"AT+ADVI4" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (interval ==  5000)
    {
        data = [@"AT+ADVI5" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (interval ==  6000)
    {
        data = [@"AT+ADVI6" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (interval ==  7000)
    {
        data = [@"AT+ADVI7" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (interval ==  8000)
    {
        data = [@"AT+ADVI8" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    
    else if (interval ==  9000)
    {
        data = [@"AT+ADVI9" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}



// Set TAH Baud Rate

-(void)setTAHBaudRate:(CBPeripheral *)peripheral baud:(int)baud
{
    NSData *data;
    
    if (baud == 9600)
    {
        data = [@"AT+BAUD0" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (baud == 19200)
    {
        data = [@"AT+BAUD1" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (baud == 38400)
    {
        data = [@"AT+BAUD2" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (baud == 57600)
    {
        data = [@"AT+BAUD3" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    else if (baud == 115200)
    {
        data = [@"AT+BAUD4" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (baud == 4800)
    {
        data = [@"AT+BAUD5" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (baud == 2400)
    {
        data = [@"AT+BAUD6" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (baud == 1200)
    {
        data = [@"AT+BAUD7" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else if (baud == 230400)
    {
        data = [@"AT+BAUD8" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}


// Set iBeacon Mode

-(void)setTAHBeaconMode:(CBPeripheral *)peripheral iBeaconModeON:(BOOL)mode
{
    NSData *data;
    
    if (mode)
    {
        data = [@"AT+IBEA1" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    else
    {
        data = [@"AT+IBEA0" dataUsingEncoding:[NSString defaultCStringEncoding]];
    }
    
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}


// Set TAH in Transmission Mode

-(void)setTAHWorkingMode:(CBPeripheral *)peripheral TransmissionMode:(BOOL)mode
{
    
    if(mode)
    {
        NSData *data = [@"AT+MODE0" dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}



// Set TAH in GPIO Collection Mode

-(void)setTAHWorkingMode:(CBPeripheral *)peripheral GPIOCollectionMode:(BOOL)mode
{
    if (mode)
    {
        NSData *data = [@"AT+MODE1" dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
}


// Set TAH in Remote Control Mode

-(void)setTAHWorkingMode:(CBPeripheral *)peripheral RemoteControlMode:(BOOL)mode
{
    if (mode)
    {
        NSData *data = [@"AT+MODE2" dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
}


// Set TAH Device Name

-(void)setTAHDeviceName:(CBPeripheral *)peripheral Name:(NSString *)Name
{
    
    
    NSData *AT = [@"AT+NAME" dataUsingEncoding:[NSString defaultCStringEncoding]];
    NSData *DeviceName = [Name dataUsingEncoding:[NSString defaultCStringEncoding]];
    NSMutableData *data = [NSMutableData data];
    
    [data appendData:AT];
    [data appendData:DeviceName];
    
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Set TAH Device Security Pin

-(void)setTAHSecurityPin:(CBPeripheral *)peripheral Pin:(NSString *)Pin;
{
    NSData *AT = [@"AT+PASS" dataUsingEncoding:[NSString defaultCStringEncoding]];
    NSData *DevicePin = [Pin dataUsingEncoding:[NSString defaultCStringEncoding]];
    NSMutableData *data = [NSMutableData data];
    
    [data appendData:AT];
    [data appendData:DevicePin];
    
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Set TAH Transmission Power

-(void)setTAHTransmissionPower:(CBPeripheral *)peripheral Power:(NSString *)Power
{
    NSString *power;
    
    if ([Power  isEqual: @"-23"])
    {
        power = @"0";
    }
    
    else if ([Power  isEqual: @"-6"])
    {
        power = @"1";
    }
    
    else if ([Power  isEqual: @"0"])
    {
        power = @"2";
    }
    
    else if ([Power  isEqual: @"6"])
    {
        power = @"3";
    }
    
    NSData *AT = [@"AT+POWE" dataUsingEncoding:[NSString defaultCStringEncoding]];
    NSData *DevicePower = [power dataUsingEncoding:[NSString defaultCStringEncoding]];
    NSMutableData *data = [NSMutableData data];
    
    [data appendData:AT];
    [data appendData:DevicePower];
    
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Set TAH Auto Sleep Type

-(void)setTAHSleepModeType:(CBPeripheral *)peripheral AutoSleepOn:(BOOL)AutoSleepOn
{
    if (AutoSleepOn)
    {
        NSData *data = [@"AT+PWRM0" dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
    else
    {
        NSData *data = [@"AT+PWRM1" dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}


// Put TAH On Sleep Mode

-(void)putTAHonSleepMode:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+SLEEP" dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
}


// Set TAH Security Type

-(void)setTAHSecurityType:(CBPeripheral *)peripheral WithPin:(BOOL)WithPin
{
    if (WithPin)
    {
        NSData *data = [@"AT+TYPE2" dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
    
    else
    {
        NSData *data = [@"AT+TYPE0" dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        
    }
}


// Update Current Analog State of TAH

-(void)updateTAHAnalogStatus:(CBPeripheral *)peripheral UpdateStatus:(BOOL)UpdateStatus
{
    NSData *data = [@"3,0,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    NSLog(@"TAH Status Updated");
    
}


// Update Current Digital State of TAH

-(void)updateTAHDigitalStatus:(CBPeripheral *)peripheral UpdateStatus:(BOOL)UpdateStatus
{
    NSData *data = [@"4,0,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    NSLog(@"TAH Status Updated");
}

///////////////////////////////////////////////////////////



////////////// TAH Sensor Value Updates //////////////


// Sonar Sensor

-(void) getTAHSonarSensorUpdate:(CBPeripheral *)peripheral SensorPin:(int)SensorPin
{
    NSString *SensorType,*seperator,*end, *command;
    
    SensorType = @"0";
    seperator = @",";
    end = @"S";
    
    command = [NSString stringWithFormat:@"%@%@%d%@",SensorType,seperator,SensorPin,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}


// Temparature Sensor

-(void) getTAHTemperatureSensorUpdate:(CBPeripheral *)peripheral AnalogPin:(int)SensorPin
{
    NSString *SensorType,*seperator,*end, *command;
    
    
    if (SensorPin == 0)
    {
        SensorPin = 410;
    }
    
    else if (SensorPin == 1)
    {
        SensorPin = 411;
    }
    
    else if (SensorPin == 2)
    {
        SensorPin = 412;
    }
    
    else if (SensorPin == 3)
    {
        SensorPin = 413;
    }
    
    else if (SensorPin == 4)
    {
        SensorPin = 414;
    }
    
    else if (SensorPin == 5)
    {
        SensorPin = 415;
    }
    
    
    SensorType = @"1";
    seperator = @",";
    end = @"S";
    
    command = [NSString stringWithFormat:@"%@%@%d%@",SensorType,seperator,SensorPin,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    NSLog(@"Temperature Sensor Value Updated");
    
}


// Touch Sensor
-(void) getTAHTouchSensorUpdate:(CBPeripheral *)peripheral SensorPin:(int)SensorPin
{
    NSString *SensorType,*seperator,*end, *command;
    
    SensorType = @"2";
    seperator = @",";
    end = @"S";
    
    command = [NSString stringWithFormat:@"%@%@%d%@",SensorType,seperator,SensorPin,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    NSLog(@"Touch Sensor Value Updated");
}


// Light Sensor
-(void) getTAHLightSensorUpdate:(CBPeripheral *)peripheral AnalogPin:(int)SensorPin
{
    NSString *SensorType,*seperator,*end, *command;
    
    
    if (SensorPin == 0)
    {
        SensorPin = 410;
    }
    
    else if (SensorPin == 1)
    {
        SensorPin = 411;
    }
    
    else if (SensorPin == 2)
    {
        SensorPin = 412;
    }
    
    else if (SensorPin == 3)
    {
        SensorPin = 413;
    }
    
    else if (SensorPin == 4)
    {
        SensorPin = 414;
    }
    
    else if (SensorPin == 5)
    {
        SensorPin = 415;
    }
    
    
    SensorType = @"3";
    seperator = @",";
    end = @"S";
    
    command = [NSString stringWithFormat:@"%@%@%d%@",SensorType,seperator,SensorPin,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    NSLog(@"Light Sensor Value Updated");
}


// Rain Sensor
-(void) getTAHRainSensorUpdate:(CBPeripheral *)peripheral AnalogPin:(int)SensorPin
{
    NSString *SensorType,*seperator,*end, *command;
    
    
    if (SensorPin == 0)
    {
        SensorPin = 410;
    }
    
    else if (SensorPin == 1)
    {
        SensorPin = 411;
    }
    
    else if (SensorPin == 2)
    {
        SensorPin = 412;
    }
    
    else if (SensorPin == 3)
    {
        SensorPin = 413;
    }
    
    else if (SensorPin == 4)
    {
        SensorPin = 414;
    }
    
    else if (SensorPin == 5)
    {
        SensorPin = 415;
    }
    
    
    SensorType = @"4";
    seperator = @",";
    end = @"S";
    
    command = [NSString stringWithFormat:@"%@%@%d%@",SensorType,seperator,SensorPin,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    NSLog(@"Rain Sensor Value Updated");
}


// Wind Sensor
-(void) getTAHWindSensorUpdate:(CBPeripheral *)peripheral AnalogPin:(int)SensorPin
{
    NSString *SensorType,*seperator,*end, *command;
    
    
    if (SensorPin == 0)
    {
        SensorPin = 410;
    }
    
    else if (SensorPin == 1)
    {
        SensorPin = 411;
    }
    
    else if (SensorPin == 2)
    {
        SensorPin = 412;
    }
    
    else if (SensorPin == 3)
    {
        SensorPin = 413;
    }
    
    else if (SensorPin == 4)
    {
        SensorPin = 414;
    }
    
    else if (SensorPin == 5)
    {
        SensorPin = 415;
    }
    
    
    SensorType = @"5";
    seperator = @",";
    end = @"S";
    
    command = [NSString stringWithFormat:@"%@%@%d%@",SensorType,seperator,SensorPin,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    NSLog(@"Wind Sensor Value Updated");
}


// PIR Motion Sensor
-(void) getTAHPIRMotionSensorUpdate:(CBPeripheral *)peripheral SensorPin:(int)SensorPin
{
    NSString *SensorType,*seperator,*end, *command;
    
    SensorType = @"6";
    seperator = @",";
    end = @"S";
    
    command = [NSString stringWithFormat:@"%@%@%d%@",SensorType,seperator,SensorPin,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    NSLog(@"PIR Motion Sensor Value Updated");
}


// Soil Moisture Sensor
-(void) getTAHSoilMoistureSensorUpdate:(CBPeripheral *)peripheral AnalogPin:(int)SensorPin
{
    NSString *SensorType,*seperator,*end, *command;
    
    
    if (SensorPin == 0)
    {
        SensorPin = 410;
    }
    
    else if (SensorPin == 1)
    {
        SensorPin = 411;
    }
    
    else if (SensorPin == 2)
    {
        SensorPin = 412;
    }
    
    else if (SensorPin == 3)
    {
        SensorPin = 413;
    }
    
    else if (SensorPin == 4)
    {
        SensorPin = 414;
    }
    
    else if (SensorPin == 5)
    {
        SensorPin = 415;
    }
    
    
    SensorType = @"7";
    seperator = @",";
    end = @"S";
    
    command = [NSString stringWithFormat:@"%@%@%d%@",SensorType,seperator,SensorPin,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    NSLog(@"Soil Moisture Sensor Value Updated");
}


//////////////////////////////////////////////////////



@end
