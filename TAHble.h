//
//  TAHble.h
//  Created by Dhiraj Jadhao on 9/06/2014.
//  Copyright (c) 2014 www.tah.io
//  All rights reserved.


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID     0xFFE0
#define CHAR_UUID        0xFFE1

#define HIGH 1
#define LOW 0


// Trakpad
#define Up    256
#define Down  257
#define Right 258
#define Left  259

// Volume
#define VolumeUp 260
#define VolumeDown 261

// Tah Keyboard Modifiers

#define A 65 #define a 97
#define B 66 #define b 98
#define C 67 #define c 99
#define D 68 #define d 100
#define E 69 #define e 101
#define F 70 #define f 102
#define G 71 #define g 103
#define H 72 #define h 104
#define I 73 #define i 105
#define J 74 #define j 106
#define K 75 #define k 107
#define L 76 #define l 108
#define M 77 #define m 109
#define N 78 #define n 110
#define O 79 #define o 111
#define P 80 #define p 112
#define Q 81 #define q 113
#define R 82 #define r 114
#define S 83 #define s 115
#define T 84 #define t 116
#define U 85 #define u 117
#define V 86 #define v 118
#define W 87 #define w 119
#define X 88 #define x 120
#define Y 89 #define y 121
#define Z 90 #define z 122


#define KEY_LEFT_CTRL	 128
#define KEY_LEFT_SHIFT	 129
#define KEY_LEFT_ALT	 130
#define KEY_LEFT_GUI	 131
#define KEY_RIGHT_CTRL	 132
#define KEY_RIGHT_SHIFT	 133
#define KEY_RIGHT_ALT	 134
#define KEY_RIGHT_GUI	 135
#define KEY_UP_ARROW	 218
#define KEY_DOWN_ARROW	 217
#define KEY_LEFT_ARROW	 216
#define KEY_RIGHT_ARROW	 215
#define KEY_SPACE         32
#define KEY_BACKSPACE	 178
#define KEY_TAB	     	 179
#define KEY_RETURN	     176
#define KEY_ESC	         177
#define KEY_INSERT	 	 209
#define KEY_DELETE	 	 212
#define KEY_PAGE_UP	 	 211
#define KEY_PAGE_DOWN	 214
#define KEY_HOME	 	 210
#define KEY_END	    	 213
#define KEY_CAPS_LOCK	 193
#define KEY_F1	 	 194
#define KEY_F2	 	 195
#define KEY_F3	 	 196
#define KEY_F4	 	 197
#define KEY_F5	 	 198
#define KEY_F6	 	 199
#define KEY_F7	 	 200
#define KEY_F8	 	 201
#define KEY_F9	 	 202
#define KEY_F10	 	 203
#define KEY_F11	 	 204
#define KEY_F12	 	 205

///////////////////////

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

-(void) TAHdigitalWrite:(CBPeripheral *)peripheral PinNumber:(int)Pin Value:(int)Value;


//////// TAH Pins Analog Value Write control

-(void) TAHanalogWrite:(CBPeripheral *)peripheral PinNumber:(int)Pin Value:(int)Value;




//////// TAH PWM Servo control Write pins

-(void) TAHservoWrite:(CBPeripheral *)peripheral PinNumber:(int)Pin Angle:(int)Angle;


//////////////////////////////////////////////////////



/////////// TAH Keyboard and Mouse Control //////////

-(void) TAHkeyPress:(CBPeripheral *)peripheral Press:(int)key;

-(void) TAHMouseMove:(CBPeripheral *)peripheral Xaxis:(float)Xaxis Yaxis:(float)Yaxis Scroll:(float)Scroll;

-(void) TAHTrackPad:(CBPeripheral *)peripheral Swipe:(int)Swipe;

//////////////////////////////////////////////////////



////////////////// TAH AT Command Set //////////////////

// ble parameters which has been chanegd will only take effect after updateSettings function, tah will get disconnect after calling this funtion.


-(void)getTAHadvertisinginterval:(CBPeripheral *)peripheral;
-(void)setTAHadvertisinginterval:(CBPeripheral *)peripheral interval:(int)interval;

-(void)getTAHBaudRate:(CBPeripheral *)peripheral;
-(void)setTAHBaudRate:(CBPeripheral *)peripheral baud:(int)baud;

-(void)getTAHBeaconMode:(CBPeripheral *)peripheral;
-(void)setTAHBeaconMode:(CBPeripheral *)peripheral iBeaconModeON:(BOOL)mode;

-(void)getTAHBeaconUUID0:(CBPeripheral *)peripheral;
-(void)setTAHBeaconUUID0:(CBPeripheral *)peripheral UUID0:(char)UUID0;

-(void)getTAHBeaconUUID1:(CBPeripheral *)peripheral;
-(void)setTAHBeaconUUID1:(CBPeripheral *)peripheral UUID1:(char)UUID1;

-(void)getTAHBeaconUUID2:(CBPeripheral *)peripheral;
-(void)setTAHBeaconUUID2:(CBPeripheral *)peripheral UUID2:(char)UUID2;

-(void)getTAHBeaconUUID3:(CBPeripheral *)peripheral;
-(void)setTAHBeaconUUID3:(CBPeripheral *)peripheral UUID3:(char)UUID3;

-(void)getTAHBeaconMajor:(CBPeripheral *)peripheral;
-(void)setTAHBeaconMajor:(CBPeripheral *)peripheral Major:(char)Major;

-(void)getTAHBeaconMinor:(CBPeripheral *)peripheral;
-(void)setTAHBeaconMinor:(CBPeripheral *)peripheral Minor:(char)Minor;


-(void)getTAHWorkingMode:(CBPeripheral *)peripheral;
-(void)setTAHWorkingMode:(CBPeripheral *)peripheral TransmissionMode:(BOOL)mode;
-(void)setTAHWorkingMode:(CBPeripheral *)peripheral GPIOCollectionMode:(BOOL)mode;
-(void)setTAHWorkingMode:(CBPeripheral *)peripheral RemoteControlMode:(BOOL)mode;

-(void)getTAHDeviceName:(CBPeripheral *)peripheral;
-(void)setTAHDeviceName:(CBPeripheral *)peripheral Name:(NSString *)Name;

-(void)getTAHSecurityPin:(CBPeripheral *)peripheral;
-(void)setTAHSecurityPin:(CBPeripheral *)peripheral Pin:(NSString *)Pin;

-(void)getTAHTransmissionPower:(CBPeripheral *)peripheral;
-(void)setTAHTransmissionPower:(CBPeripheral *)peripheral Power:(NSString *)Power;

-(void)getTAHSleepModeType:(CBPeripheral *)peripheral;
-(void)setTAHSleepModeType:(CBPeripheral *)peripheral AutoSleepOn:(BOOL)AutoSleepOn;

-(void)getTAHSecurityType:(CBPeripheral *)peripheral;
-(void)setTAHSecurityType:(CBPeripheral *)peripheral WithPin:(BOOL)WithPin;


-(void)restoreTAHfactorysettings:(CBPeripheral *)peripheral;



-(void)getTAHRSSIValue:(CBPeripheral *)peripheral;
-(void)putTAHonSleepMode:(CBPeripheral *)peripheral;
-(void)getTAHServiceUUID:(CBPeripheral *)peripheral;
-(void)getTAHcharacteristicsValue:(CBPeripheral *)peripheral;
-(void)updateSettings:(CBPeripheral *)peripheral;
-(void)getTAHMacAddress:(CBPeripheral *)peripheral;
-(void)getTAHbatterylevel:(CBPeripheral *)peripheral;
-(void)getTAHNotificationParameter:(CBPeripheral *)peripheral;
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
