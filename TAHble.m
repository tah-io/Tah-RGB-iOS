//
//  TAHble.m
//  Created by Dhiraj Jadhao on 9/06/2014.
//  Copyright (c) 2012 www.tah.io
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
    printf("now can reading......\n");
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
    printf("Now we found device\n");
    if (!peripherals) {
        peripherals = [[NSMutableArray alloc] initWithObjects:peripheral, nil];
        for (int i = 0; i < [peripherals count]; i++) {
            [delegate peripheralFound: peripheral];
        }
    }
    
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
                printf("Duplicated peripheral is found...\n");
                //[delegate peripheralFound: peripheral];
                return;
            }
        }
        printf("New peripheral is found...\n");
        [peripherals addObject:peripheral];
        [delegate peripheralFound:peripheral];
        return;
    }
    printf("%s\n", __FUNCTION__);
}



-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    
    [activePeripheral discoverServices:nil];
    //[self notify:peripheral on:YES];
    
    [self printPeripheralInfo:peripheral];
    
    printf("connected to the active peripheral\n");
}



-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    printf("disconnected to the active peripheral\n");
    if(activePeripheral != nil)
    [delegate setDisconnect];
     activePeripheral = nil;
}



-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"failed to connect to peripheral %@: %@\n", [peripheral name], [error localizedDescription]);
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
    printf("In read Value");
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


/////// Pin 2 Control

-(void) TAHPin2digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,2,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 2 On");
    }
    
    else
    {
        NSData *data = [@"0,2,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 2 off");
    }
    
}



/////// Pin 3 Control


-(void) TAHPin3digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,3,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 3 On");
    }
    
    else
    {
        NSData *data = [@"0,3,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 3 off");
    }
    
}




/////// Pin 4 Control

-(void) TAHPin4digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,4,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 4 On");
    }
    
    else
    {
        NSData *data = [@"0,4,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 4 off");
    }
    
}




/////// Pin 5 Control

-(void) TAHPin5digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,5,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 5 On");
    }
    
    else
    {
        NSData *data = [@"0,5,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 5 off");
    }
    
}




/////// Pin 6 Control

-(void) TAHPin6digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,6,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 6 On");
    }
    
    else
    {
        NSData *data = [@"0,6,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 6 off");
    }
    
}



/////// Pin 7 Control

-(void) TAHPin7digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,7,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 7 On");
    }
    
    else
    {
        NSData *data = [@"0,7,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 7 off");
    }
    
}




/////// Pin 8 Control

-(void) TAHPin8digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,8,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 8 On");
    }
    
    else
    {
        NSData *data = [@"0,8,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 8 off");
    }
    
}




/////// Pin 9 Control

-(void) TAHPin9digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,9,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 9 On");
    }
    
    else
    {
        NSData *data = [@"0,9,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 9 off");
    }
    
}




/////// Pin 10 Control

-(void) TAHPin10digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,10,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 10 On");
    }
    
    else
    {
        NSData *data = [@"0,10,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 10 off");
    }
    
}




/////// Pin 11 Control

-(void) TAHPin11digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,11,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 11 On");
    }
    
    else
    {
        NSData *data = [@"0,11,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 11 off");
    }
    
}




/////// Pin 12 Control

-(void) TAHPin12digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
    
    if (state)
    {
        NSData *data = [@"0,12,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 12 On");
    }
    
    else
    {
        NSData *data = [@"0,12,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        //NSLog(@"TAH Pin 12 off");
    }
    
}



/////// Pin 13 Control


-(void) TAHPin13digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state
{
   
    if (state)
    {
        NSData *data = [@"0,13,1R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
         NSLog(@"TAH Pin 13 on");
    }
    
    else
    {
        NSData *data = [@"0,13,0R" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
        NSLog(@"TAH Pin 13 off");
    }

}

////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////// TAH Pins Analog Value control ////////////////////////////

/////// Pin 3 Control

-(void) TAHPin3analogWrite:(CBPeripheral *)peripheral Value:(int)state;
{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"1";
    PinNumber = @"3";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,state,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
   
    
}



/////// Pin 5 Control

-(void) TAHPin5analogWrite:(CBPeripheral *)peripheral Value:(int)state;
{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"1";
    PinNumber = @"5";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,state,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
    
    
}


/////// Pin 6 Control

-(void) TAHPin6analogWrite:(CBPeripheral *)peripheral Value:(int)state;
{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"1";
    PinNumber = @"6";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,state,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
    
    
}



/////// Pin 9 Control

-(void) TAHPin9analogWrite:(CBPeripheral *)peripheral Value:(int)state;
{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"1";
    PinNumber = @"9";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,state,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
    
    
}



/////// Pin 10 Control

-(void) TAHPin10analogWrite:(CBPeripheral *)peripheral Value:(int)state;
{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"1";
    PinNumber = @"10";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,state,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
    
    
}



/////// Pin 11 Control

-(void) TAHPin11analogWrite:(CBPeripheral *)peripheral Value:(int)state;
{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"1";
    PinNumber = @"11";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,state,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
    
    
}



/////// Pin 13 Control

-(void) TAHPin13analogWrite:(CBPeripheral *)peripheral Value:(int)state;
{

        NSString *command,*PinType,*PinNumber,*end,*seperator;
    
        PinType = @"1";
        PinNumber = @"13";
        seperator = @",";
        end = @"R";
    
        command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,state,end];
    
        NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
        
   

}



//////////////////////  TAH PWM Servo control pins //////////////////////


/////// Pin 3 Control

-(void) TAHPin3Servo:(CBPeripheral *)peripheral angle:(int)angle;

{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"2";
    PinNumber = @"3";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,angle,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];

}



/////// Pin 5 Control

-(void) TAHPin5Servo:(CBPeripheral *)peripheral angle:(int)angle;

{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"2";
    PinNumber = @"5";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,angle,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}



/////// Pin 6 Control

-(void) TAHPin6Servo:(CBPeripheral *)peripheral angle:(int)angle;

{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"2";
    PinNumber = @"6";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,angle,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}



/////// Pin 9 Control

-(void) TAHPin9Servo:(CBPeripheral *)peripheral angle:(int)angle;

{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"2";
    PinNumber = @"9";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,angle,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}



/////// Pin 10 Control

-(void) TAHPin10Servo:(CBPeripheral *)peripheral angle:(int)angle;

{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"2";
    PinNumber = @"10";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,angle,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}



/////// Pin 11 Control

-(void) TAHPin11Servo:(CBPeripheral *)peripheral angle:(int)angle;

{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"2";
    PinNumber = @"11";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,angle,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}



/////// Pin 13 Control

-(void) TAHPin13Servo:(CBPeripheral *)peripheral angle:(int)angle;

{
    
    NSString *command,*PinType,*PinNumber,*end,*seperator;
    
    PinType = @"2";
    PinNumber = @"13";
    seperator = @",";
    end = @"R";
    
    command = [NSString stringWithFormat:@"%@%@%@%@%d%@",PinType,seperator,PinNumber,seperator,angle,end];
    
    NSData *data = [command dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    
}



//////////////////////////////////////////////////////////////////////////////////////



/////////// TAH Keyboard and Mouse Control //////////

-(void) TAHKeyboardUpArrowKey:(CBPeripheral *)peripheral Pressed:(BOOL)Pressed
{
    if (Pressed)
    {
        NSData *data = [@"0,0,0,256M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }


}


-(void) TAHKeyboardDownArrowKey:(CBPeripheral *)peripheral Pressed:(BOOL)Pressed
{
    if (Pressed)
    {
        NSData *data = [@"0,0,0,257M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}


-(void) TAHKeyboardRightArrowKey:(CBPeripheral *)peripheral Pressed:(BOOL)Pressed
{
    if (Pressed)
    {
        NSData *data = [@"0,0,0,258M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}


-(void) TAHKeyboardLeftArrowKey:(CBPeripheral *)peripheral Pressed:(BOOL)Pressed
{
    if (Pressed)
    {
        NSData *data = [@"0,0,0,259M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}


-(void) TAHMosueMove:(CBPeripheral *)peripheral X:(float)Xaxis Y:(float)Yaxis Scroll:(float)Scroll
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


-(void) TAHTrackPad:(CBPeripheral *)peripheral SwipeUp:(BOOL)SwipeUp
{
    if (SwipeUp)
    {
        NSData *data = [@"0,0,0,260M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}
-(void) TAHTrackPad:(CBPeripheral *)peripheral SwipeDown:(BOOL)SwipeDown
{
    if (SwipeDown)
    {
        NSData *data = [@"0,0,0,261M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}
-(void) TAHTrackPad:(CBPeripheral *)peripheral SwipeRight:(BOOL)SwipeRight
{
    if (SwipeRight)
    {
        NSData *data = [@"0,0,0,262M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}
-(void) TAHTrackPad:(CBPeripheral *)peripheral SwipeLeft:(BOOL)SwipeLeft
{
    if (SwipeLeft)
    {
        NSData *data = [@"0,0,0,263M" dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral data:data];
    }
}


//////////////////////////////////////////////////////


////////////////// TAH AT Command Set //////////////////

// Parameters which are altered takes effect only after Reboot

// Resets TAH
-(void)resetTAH:(CBPeripheral *)peripheral
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


// Get TAH Device Role

-(void)getTAHDeviceRole:(CBPeripheral *)peripheral
{
    NSData *data = [@"AT+ROLE?" dataUsingEncoding:[NSString defaultCStringEncoding]];
    
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

-(void)setTAHTransmissionPower:(CBPeripheral *)peripheral Power:(int)Power
{
    NSString *power;
    
    if (Power == -23)
    {
      power = @"0";
    }
    
    else if (Power == -6)
    {
      power = @"1";
    }
    
    else if (Power == 0)
    {
      power = @"2";
    }
    
    else if (Power == 6)
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
