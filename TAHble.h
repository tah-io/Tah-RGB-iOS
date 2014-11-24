//
//  TAHble.h
//  Created by Dhiraj Jadhao on 9/06/2014.
//  Copyright (c) 2012 www.tah.io
//  All rights reserved.


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID     0xFFE0
#define CHAR_UUID        0xFFE1

@protocol BTSmartSensorDelegate

@optional

- (void) peripheralFound:(CBPeripheral *)peripheral;
- (void) TAHbleCharValueUpdated: (NSString *)UUID value: (NSData *)data;
- (void) setConnect;
- (void) setDisconnect;
////////////////// TAH BLE Configuration Parameters ///////////////////


///////////////////////////////////////////////////////////////////////

@end

@interface TAHble : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    
    NSData *receivedData;
    
}

@property (nonatomic, assign) id <BTSmartSensorDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) CBCentralManager *manager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;


#pragma mark - Methods for controlling the TAH Sensor

////////////////// TAH Pin Controls //////////////////

-(void)updateTAHAnalogStatus:(CBPeripheral *)peripheral UpdateStatus:(BOOL)UpdateStatus;
-(void)updateTAHDigitalStatus:(CBPeripheral *)peripheral UpdateStatus:(BOOL)UpdateStatus;

//////// TAH Pins Digital Value Write control

-(void) TAHPin2digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin3digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin4digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin5digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin6digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin7digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin8digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin9digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin10digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin11digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin12digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;
-(void) TAHPin13digitalWrite:(CBPeripheral *)peripheral HIGH:(BOOL)state;


//////// TAH Pins Analog Value Write control

-(void) TAHPin3analogWrite:(CBPeripheral *)peripheral Value:(int)state;
-(void) TAHPin5analogWrite:(CBPeripheral *)peripheral Value:(int)state;
-(void) TAHPin6analogWrite:(CBPeripheral *)peripheral Value:(int)state;
-(void) TAHPin9analogWrite:(CBPeripheral *)peripheral Value:(int)state;
-(void) TAHPin10analogWrite:(CBPeripheral *)peripheral Value:(int)state;
-(void) TAHPin11analogWrite:(CBPeripheral *)peripheral Value:(int)state;
-(void) TAHPin13analogWrite:(CBPeripheral *)peripheral Value:(int)state;


//////// TAH PWM Servo control Write pins

-(void) TAHPin3Servo:(CBPeripheral *)peripheral angle:(int)angle;
-(void) TAHPin5Servo:(CBPeripheral *)peripheral angle:(int)angle;
-(void) TAHPin6Servo:(CBPeripheral *)peripheral angle:(int)angle;
-(void) TAHPin9Servo:(CBPeripheral *)peripheral angle:(int)angle;
-(void) TAHPin10Servo:(CBPeripheral *)peripheral angle:(int)angle;
-(void) TAHPin11Servo:(CBPeripheral *)peripheral angle:(int)angle;
-(void) TAHPin13Servo:(CBPeripheral *)peripheral angle:(int)angle;

//////////////////////////////////////////////////////

/////////// TAH Keyboard and Mouse Control //////////

-(void) TAHKeyboardUpArrowKey:(CBPeripheral *)peripheral Pressed:(BOOL)Pressed;
-(void) TAHKeyboardDownArrowKey:(CBPeripheral *)peripheral Pressed:(BOOL)Pressed;
-(void) TAHKeyboardLeftArrowKey:(CBPeripheral *)peripheral Pressed:(BOOL)Pressed;
-(void) TAHKeyboardRightArrowKey:(CBPeripheral *)peripheral Pressed:(BOOL)Pressed;
-(void) TAHMosueMove:(CBPeripheral *)peripheral X:(float)Xaxis Y:(float)Yaxis Scroll:(float)Scroll;

-(void) TAHTrackPad:(CBPeripheral *)peripheral SwipeUp:(BOOL)SwipeUp;
-(void) TAHTrackPad:(CBPeripheral *)peripheral SwipeDown:(BOOL)SwipeDown;
-(void) TAHTrackPad:(CBPeripheral *)peripheral SwipeRight:(BOOL)SwipeRight;
-(void) TAHTrackPad:(CBPeripheral *)peripheral SwipeLeft:(BOOL)SwipeLeft;


//////////////////////////////////////////////////////

////////////////// TAH AT Command Set //////////////////

// Parameters which are altered takes effect only after Reboot

-(void)resetTAH:(CBPeripheral *)peripheral;
-(void)getTAHMacAddress:(CBPeripheral *)peripheral;

-(void)getTAHadvertisinginterval:(CBPeripheral *)peripheral;
-(void)setTAHadvertisinginterval:(CBPeripheral *)peripheral interval:(int)interval;

-(void)getTAHbatterylevel:(CBPeripheral *)peripheral;

-(void)getTAHBaudRate:(CBPeripheral *)peripheral;
-(void)setTAHBaudRate:(CBPeripheral *)peripheral baud:(int)baud;

-(void)getTAHcharacteristicsValue:(CBPeripheral *)peripheral;

-(void)getTAHBeaconMode:(CBPeripheral *)peripheral;
-(void)setTAHBeaconMode:(CBPeripheral *)peripheral iBeaconModeON:(BOOL)mode;

-(void)getTAHBeaconUUID0:(CBPeripheral *)peripheral;
-(void)getTAHBeaconUUID1:(CBPeripheral *)peripheral;
-(void)getTAHBeaconUUID2:(CBPeripheral *)peripheral;
-(void)getTAHBeaconUUID3:(CBPeripheral *)peripheral;

-(void)getTAHBeaconMajor:(CBPeripheral *)peripheral;
-(void)getTAHBeaconMinor:(CBPeripheral *)peripheral;

-(void)getTAHWorkingMode:(CBPeripheral *)peripheral;
-(void)setTAHWorkingMode:(CBPeripheral *)peripheral TransmissionMode:(BOOL)mode;
-(void)setTAHWorkingMode:(CBPeripheral *)peripheral GPIOCollectionMode:(BOOL)mode;
-(void)setTAHWorkingMode:(CBPeripheral *)peripheral RemoteControlMode:(BOOL)mode;

-(void)getTAHNotificationParameter:(CBPeripheral *)peripheral;

-(void)getTAHDeviceName:(CBPeripheral *)peripheral;
-(void)setTAHDeviceName:(CBPeripheral *)peripheral Name:(NSString *)Name;

-(void)getTAHSecurityPin:(CBPeripheral *)peripheral;
-(void)setTAHSecurityPin:(CBPeripheral *)peripheral Pin:(NSString *)Pin;

-(void)getTAHTransmissionPower:(CBPeripheral *)peripheral;
-(void)setTAHTransmissionPower:(CBPeripheral *)peripheral Power:(int)Power;

-(void)getTAHSleepModeType:(CBPeripheral *)peripheral;
-(void)setTAHSleepModeType:(CBPeripheral *)peripheral AutoSleepOn:(BOOL)AutoSleepOn;

-(void)restoreTAHfactorysettings:(CBPeripheral *)peripheral;

-(void)getTAHDeviceRole:(CBPeripheral *)peripheral;

-(void)getTAHRSSIValue:(CBPeripheral *)peripheral;

-(void)putTAHonSleepMode:(CBPeripheral *)peripheral;

-(void)getTAHSecurityType:(CBPeripheral *)peripheral;
-(void)setTAHSecurityType:(CBPeripheral *)peripheral WithPin:(BOOL)WithPin;

-(void)getTAHServiceUUID:(CBPeripheral *)peripheral;

-(void)getTAHfirmwareVersion:(CBPeripheral *)peripheral;

//////////////////////////////////////////////////////



////////////// TAH Sensor Value Updates //////////////

-(void) getTAHSonarSensorUpdate:(CBPeripheral *)peripheral SensorPin:(int)SensorPin;
-(void) getTAHTemperatureSensorUpdate:(CBPeripheral *)peripheral AnalogPin:(int)SensorPin;
-(void) getTAHTouchSensorUpdate:(CBPeripheral *)peripheral SensorPin:(int)SensorPin;
-(void) getTAHLightSensorUpdate:(CBPeripheral *)peripheral AnalogPin:(int)SensorPin;
-(void) getTAHRainSensorUpdate:(CBPeripheral *)peripheral AnalogPin:(int)SensorPin;
-(void) getTAHWindSensorUpdate:(CBPeripheral *)peripheral AnalogPin:(int)SensorPin;
-(void) getTAHPIRMotionSensorUpdate:(CBPeripheral *)peripheral SensorPin:(int)SensorPin;
-(void) getTAHSoilMoistureSensorUpdate:(CBPeripheral *)peripheral AnalogPin:(int)SensorPin;

//////////////////////////////////////////////////////



-(void) setup; //controller setup
-(void) stopScan;

-(int) findTAHPeripherals:(int)timeout;
-(void) scanTimer: (NSTimer *)timer;

-(void) connect: (CBPeripheral *)peripheral;
-(void) disconnect: (CBPeripheral *)peripheral;


-(void) write:(CBPeripheral *)peripheral data:(NSData *)data;
-(void) read:(CBPeripheral *)peripheral;
-(void) notify:(CBPeripheral *)peripheral on:(BOOL)on;



- (void) printPeripheralInfo:(CBPeripheral*)peripheral;

-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on;
-(UInt16) swap:(UInt16)s;

-(CBService *) findServiceFromUUIDEx:(CBUUID *)UUID p:(CBPeripheral *)p;
-(CBCharacteristic *) findCharacteristicFromUUIDEx:(CBUUID *)UUID service:(CBService*)service;
-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data;
-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p;

@end
