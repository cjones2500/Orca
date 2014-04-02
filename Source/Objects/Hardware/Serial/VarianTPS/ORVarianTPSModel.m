//--------------------------------------------------------
// ORVarianTPSModel
// Created by Mark  A. Howe on Wed 12/2/09
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2009 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Washington at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files

#import "ORVarianTPSModel.h"
#import "ORSerialPort.h"
#import "ORSerialPortAdditions.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"
#import "ORTimeRate.h"
#import "ORSafeQueue.h"

#pragma mark •••External Strings
NSString* ORVarianTPSModelRemoteChanged			= @"ORVarianTPSModelRemoteChanged";
NSString* ORVarianTPSModelPressureScaleChanged	= @"ORVarianTPSModelPressureScaleChanged";
NSString* ORVarianTPSModelStationPowerChanged	= @"ORVarianTPSModelStationPowerChanged";
NSString* ORVarianTPSModelPressureChanged		= @"ORVarianTPSModelPressureChanged";
NSString* ORVarianTPSModelMotorCurrentChanged	= @"ORVarianTPSModelMotorCurrentChanged";
NSString* ORVarianTPSModelActualRotorSpeedChanged = @"ORVarianTPSModelActualRotorSpeedChanged";
NSString* ORVarianTPSModelPollTimeChanged		= @"ORVarianTPSModelPollTimeChanged";
NSString* ORVarianTPSModelSerialPortChanged		= @"ORVarianTPSModelSerialPortChanged";
NSString* ORVarianTPSModelPortNameChanged		= @"ORVarianTPSModelPortNameChanged";
NSString* ORVarianTPSModelPortStateChanged		= @"ORVarianTPSModelPortStateChanged";
NSString* ORVarianTPSLock						= @"ORVarianTPSLock";
NSString* ORVarianTPSModelWindowStatusChanged	= @"ORVarianTPSModelWindowStatusChanged";
NSString* ORVarianTPSModelControllerTempChanged	= @"ORVarianTPSModelControllerTempChanged";

#pragma mark •••Status Parameters
#define kStationPower	10

#define kAck			0x6
#define kWinDisabled	0x35

#define kStx			0x02
#define kEtx			0x03
#define kRdCmd			0x30
#define kWrCmd			0x31
#define kAddrs			0x80

#define kStartStop		0
#define kLowSpeedAct	1
#define kRemoteOps		8
#define kSoftStart		100
#define kPressure		224
#define kMotorCurrent   200
#define kActualSpeed	226
#define kControllerTemp	216
#define kReadSpeedOp    167

@interface ORVarianTPSModel (private)
- (void)	timeout;
- (void)	processOneCommandFromQueue;
- (void)	enqueCmdData:(NSData*)someData;
- (void)	processReceivedData:(NSData*)aCommand;
- (BOOL)	extractBool:(NSData*)aCommand;
- (int)		extractInt:(NSData*)aCommand;
- (float)	extractFloat:(NSData*)aCommand;
- (int)		extractWindow:(NSData*)aCommand;
- (void)	pollPressures;
@end

@implementation ORVarianTPSModel

- (void) dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[cmdQueue release];
	[lastRequest release];
	[inComingData release];
	[statusString release];
	[super dealloc];
}

- (void)sleep
{
    [super sleep];
    	
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"VarianTPS.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORVarianTPSController"];
}

#pragma mark •••Accessors
- (int) controllerTemp
{
	return controllerTemp;
}
- (void) setControllerTemp:(int)aValue
{
    [[[self undoManager] prepareWithInvocationTarget:self] setControllerTemp:controllerTemp];
    controllerTemp = aValue;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORVarianTPSModelControllerTempChanged object:self];
}

- (BOOL) remote
{
    return remote;
}

- (void) setRemote:(BOOL)aRemote
{
    [[[self undoManager] prepareWithInvocationTarget:self] setRemote:remote];
    remote = aRemote;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORVarianTPSModelRemoteChanged object:self];
}

- (int) pollTime
{
    return pollTime;
}

- (void) setPollTime:(int)aPollTime
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPollTime:pollTime];
    pollTime = aPollTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORVarianTPSModelPollTimeChanged object:self];
	
	if(pollTime){
		[self performSelector:@selector(pollPressures) withObject:nil afterDelay:pollTime];
	}
	else {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollPressures) object:nil];
	}
}


- (float) pressureScaleValue
{
	return pressureScaleValue;
}

- (int) pressureScale
{
    return pressureScale;
}

- (void) setPressureScale:(int)aPressureScale
{
	if(aPressureScale<0)aPressureScale=0;
	else if(aPressureScale>11)aPressureScale=11;
	
    [[[self undoManager] prepareWithInvocationTarget:self] setPressureScale:pressureScale];
    
    pressureScale = aPressureScale;
	
	pressureScaleValue = powf(10.,(float)pressureScale);
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORVarianTPSModelPressureScaleChanged object:self];
}

- (ORTimeRate*)timeRate
{
	return timeRate;
}

- (BOOL) stationPower
{
    return stationPower;
}

- (void) setStationPower:(BOOL)aStationPower
{
    stationPower = aStationPower;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORVarianTPSModelStationPowerChanged object:self];
}


- (float) pressure
{
    return pressure;
}

- (void) setPressure:(float)aPressure
{
    pressure = aPressure;
	if(timeRate == nil) timeRate = [[ORTimeRate alloc] init];
	[timeRate addDataToTimeAverage:aPressure];
	time_t	ut_Time;
	time(&ut_Time);
	timeMeasured = ut_Time;
	[self shipPressure];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORVarianTPSModelPressureChanged object:self];
}

- (float) motorCurrent
{
    return motorCurrent;
}

- (void) setMotorCurrent:(float)aMotorCurrent
{
    motorCurrent = aMotorCurrent;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORVarianTPSModelMotorCurrentChanged object:self];
}


- (int) actualRotorSpeed
{
    return actualRotorSpeed;
}

- (void) setActualRotorSpeed:(int)aActualRotorSpeed
{
    actualRotorSpeed = aActualRotorSpeed;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORVarianTPSModelActualRotorSpeedChanged object:self];
}

- (NSData*) lastRequest
{
	return lastRequest;
}

- (void) setLastRequest:(NSData*)aCmdData
{
	[aCmdData retain];
	[lastRequest release];
	lastRequest = aCmdData;
}

- (void) openPort:(BOOL)state
{
    if(state) {
        [serialPort open];
		[serialPort setSpeed:9600];
		[serialPort setParityNone];
		[serialPort setStopBits2:NO];
		[serialPort setDataBits:8];
        [serialPort commitChanges];
		[serialPort setDelegate:self];
    }
    else {
		[serialPort close];
	}
    portWasOpen = [serialPort isOpen];
	if([serialPort isOpen]){
		[self sendRemoteMode];
		[self sendReadSpeedMode];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSerialPortModelPortStateChanged object:self];
    
}

#pragma mark •••Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setRemote:[decoder decodeBoolForKey:@"remote"]];
	[self setPollTime:		[decoder decodeIntForKey:	@"pollTime"]];
	[self setPressureScale:	[decoder decodeIntForKey:	@"pressureScale"]];
	[[self undoManager] enableUndoRegistration];
	cmdQueue = [[ORSafeQueue alloc] init];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeBool:remote forKey:@"remote"];
    [encoder encodeInt:pressureScale	forKey: @"pressureScale"];
    [encoder encodeInt:pollTime			forKey: @"pollTime"];
}

#pragma mark •••HW Methods

- (void) getPressure		{ [self read:kPressure];  }
- (void) getRemote			{ [self read:kRemoteOps];  }
- (void) getStationPower	{ [self read:kStartStop];  }
- (void) getMotorCurrent	{ [self read:kMotorCurrent];  }
- (void) getActualSpeed		{ [self read:kActualSpeed]; }
- (void) getControllerTemp	{ [self read:kControllerTemp];  }

- (void) updateAll
{
	[self getControllerTemp];
	[self getRemote];
	[self getActualSpeed];
	[self getPressure];
	[self getStationPower];
	[self getMotorCurrent];
}

- (void) sendRemoteMode
{
	[self write:kRemoteOps logicValue:0];
}

- (void) sendReadSpeedMode
{
	[self write:kReadSpeedOp logicValue:0];
}

- (void) turnStationOn
{
	[self write:kStartStop logicValue:1];
	[self updateAll];
}

- (void) turnStationOff
{
	[self write:kStartStop logicValue:0];
	[self updateAll];
}

#pragma mark •••Commands
- (int) crc:(unsigned char*)aCmd length:(int)len
{
	int i;
	int crc = 0;
	for(i=1;i<len;i++){
		crc ^= aCmd[i];
	}
	return crc;
}

- (void) write:(int)window logicValue:(BOOL)aValue 
{
	int d1 = window/100;
	int d2 = (window-d1*100)/10;
	int d3 = window - d1*100 - d2*10;
	unsigned char data[64];
	data[0] = kStx;	
	data[1] = kAddrs; //addr -- always 0x80 for rs232
	data[2] = '0'+ d1;
	data[3] = '0'+ d2;
	data[4] = '0'+ d3;
	data[5] = kWrCmd; 
	data[6] = '0'+ aValue;
	data[7] = kEtx;
	int crc = [self crc:data length:8];
	char c[64];
	sprintf(c,"%02X",crc);
	data[8] = c[0];
	data[9] = c[1];

	NSMutableData* cmdData = [NSMutableData dataWithBytes:data length:10];

	[self enqueCmdData:cmdData];
}
	
- (void) read:(int)window 
	{
	int d1 = window/100;
	int d2 = (window-d1*100)/10;
	int d3 = window - d1*100 - d2*10;
	unsigned char data[64];
	data[0] = kStx;	
	data[1] = kAddrs; //addr -- always 0x80 for rs232
	data[2] = '0'+ d1;
	data[3] = '0'+ d2;
	data[4] = '0'+ d3;
	data[5] = kRdCmd; 
	data[6] = kEtx;
	int crc = [self crc:data length:7];
	char c[64];
	sprintf(c,"%02X",crc);
	data[7] = c[0];
	data[8] = c[1];
	
	NSMutableData* cmdData = [NSMutableData dataWithBytes:data length:9];
	
	[self enqueCmdData:cmdData];
}
	

//---------------------------
//format of a command
//<STX> <Addr> <Win> <command> <data> <ETX> <CRC>
//Where:
//<STX> = 0x02
//<Addr>= 0x80
//<Win> = window number 0 - 999
//<command> = 0x30 to read, 0x31 to write
//<data> = data to be written (field not present for read)
//<ETX> = 0x03
//<CRC> = XOR of all characters subsequent to <STX> and including the <ETX> terminator
//---------------------------

- (void) sendDataSet:(int)aParamNum bool:(BOOL)aState 
{
}

- (void) sendDataSet:(int)aParamNum integer:(unsigned int)anInt 
{
}

- (void) sendDataSet:(int)aParamNum real:(float)aFloat 
{
}

- (void) sendDataSet:(int)aParamNum expo:(float)aFloat 
{
}

- (void) sendDataSet:(int)aParamNum shortInteger:(unsigned short)aShort 
{
}

#pragma mark •••Data Records
- (unsigned long) dataId { return dataId; }
- (void) setDataId: (unsigned long) DataId
{
    dataId = DataId;
}
- (void) setDataIds:(id)assigner
{
    dataId       = [assigner assignDataIds:kLongForm];
}

- (void) syncDataIdsWith:(id)anotherVarianTPS
{
    [self setDataId:[anotherVarianTPS dataId]];
}

- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"VarianTPSModel"];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        @"ORVarianTPSDecoderForPressure",	@"decoder",
        [NSNumber numberWithLong:dataId],   @"dataId",
        [NSNumber numberWithBool:NO],       @"variable",
        [NSNumber numberWithLong:4],        @"length",
        nil];
    [dataDictionary setObject:aDictionary forKey:@"Pressure"];
    
    return dataDictionary;
}

- (void) dataReceived:(NSNotification*)note
{
	if(!lastRequest)return;
	
    if([[note userInfo] objectForKey:@"serialPort"] == serialPort){
		if(!inComingData)inComingData = [[NSMutableData data] retain];
		[inComingData appendData:[[note userInfo] objectForKey:@"data"]];
		
		do {
			char* p = (char*)[inComingData bytes];
			int i;
			int n = [inComingData length];
			BOOL foundEnd = NO;
			for(i=0;i<n;i++){
				if(p[i] == kEtx && n>=i+2){
					[self processReceivedData:[NSData dataWithBytes:p length:i+3]];
					[inComingData replaceBytesInRange:NSMakeRange(0,i+3) withBytes:nil length:0];
					foundEnd = YES;
					break;
				} 
			}
			if(!foundEnd) break;
		} while([inComingData length]!=0);
	}
}
- (NSString*) windowName:(int)aValue
{
	switch(aValue){
		case kStartStop:	return @"Start/Stop";	
		case kLowSpeedAct:	return @"Low Speed Activation";
		case kRemoteOps:	return @"Remote Ops";
		case kSoftStart:	return @"Soft Start";
		default: return @"Undefined";
	}
}

- (NSString*) statusString
{
	if(!statusString)return @"";
	else return statusString;
}

- (void) showWindowDisabled:(NSData*)aCommand
{
	int lastWindow = [self extractWindow:lastRequest];
	[statusString release];
	statusString = [[NSString stringWithFormat:@"%@ Disabled",[self windowName:lastWindow]] retain];
	[[NSNotificationCenter defaultCenter] postNotificationName:ORVarianTPSModelWindowStatusChanged object:self];

	
	NSLog(@"%@\n",statusString);
}

- (void) decode:(int)paramNumber command:(NSData*)aCommand
{
	switch (paramNumber) {
		case kAck: 
//			[self decode:paramNumber command:lastRequest];
		break;
		case kWinDisabled:
			[self showWindowDisabled:aCommand];
		break;
			
		case kRemoteOps:	[self setRemote:			[self extractBool:aCommand]];  break;
		case kPressure:		[self setPressure:			[self extractFloat:aCommand]]; break;			
		case kStartStop:	[self setStationPower:		[self extractBool:aCommand]]; break;			
		case kMotorCurrent: [self setMotorCurrent:		[self extractInt:aCommand]]; break;
		case kActualSpeed:  [self setActualRotorSpeed:	[self extractInt:aCommand]];   break;
		case kControllerTemp: [self setControllerTemp:	[self extractInt:aCommand]]; break;
			
		default:
		break;
	}
}

- (void) shipPressure
{
    if([[ORGlobal sharedGlobal] runInProgress]){
		
		unsigned long data[4];
		data[0] = dataId | 4;
		data[1] = [self uniqueIdNumber]&0xfff;
		
		union {
			float asFloat;
			unsigned long asLong;
		}theData;
		theData.asFloat = pressure;
		data[2] = theData.asLong;			
		data[3] = timeMeasured;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORQueueRecordForShippingNotification 
															object:[NSData dataWithBytes:data length:sizeof(long)*4]];
	}
}

@end

@implementation ORVarianTPSModel (private)
- (int)   extractInt:  (NSData*)aCommand	
{ 
	NSString* s = [[NSString alloc] initWithData:[aCommand subdataWithRange:NSMakeRange(6,6)] encoding:NSASCIIStringEncoding];
	int theValue = [s intValue];
	[s release];
	return theValue;
}

- (BOOL)  extractBool: (NSData*)aCommand	
{ 
	NSString* s = [[NSString alloc] initWithData:[aCommand subdataWithRange:NSMakeRange(6,1)] encoding:NSASCIIStringEncoding];
	BOOL theValue = [s boolValue];
	[s release];
	return theValue; 
}

- (float) extractFloat:(NSData*)aCommand	
{ 
	if([aCommand length]>=16){
		NSString* s = [[NSString alloc] initWithData:[aCommand subdataWithRange:NSMakeRange(6,10)] encoding:NSASCIIStringEncoding];
		float theValue = [s floatValue];
		[s release];
		return theValue; 
	}
	else return 0;
}

- (void) timeout
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
	NSLogError(@"command timeout",@"VarianTPS",nil);
	[self setLastRequest:nil];
	[cmdQueue removeAllObjects];
	[self processOneCommandFromQueue];	 //do the next command in the queue
}

- (void) processOneCommandFromQueue
{
	if([cmdQueue count] == 0) return;
	NSData* cmdData = [cmdQueue dequeue];
	[self setLastRequest:cmdData];
	[serialPort writeDataInBackground:cmdData];
	[self performSelector:@selector(timeout) withObject:nil afterDelay:.5];
}

- (void) enqueCmdData:(NSData*)someData
{
	if([serialPort isOpen]){
		[cmdQueue enqueue:someData];
		if(!lastRequest)[self processOneCommandFromQueue];
	}
}

- (int) extractWindow:(NSData*)aCommand
{
	unsigned char* p = (unsigned char*)[aCommand bytes];
	int receivedWindow = 0;
	if(p[3] == kEtx)receivedWindow = p[2];
	else receivedWindow = (p[2]-'0')*100 + (p[3]-'0')*10 + (p[4]-'0');
	return receivedWindow;
}

- (void) processReceivedData:(NSData*)aCommand
{
	BOOL doNextCommand = NO;
	int receivedWindow = [self extractWindow:aCommand];
	[self decode:receivedWindow command:aCommand];
		
	if(lastRequest){
		
		//if the param number matches the last cmd sent, then assume a match and remove the timeout
		unsigned char* p = (unsigned char*)[lastRequest bytes];
		int lastWindow = [self extractWindow:lastRequest];
		if(receivedWindow == lastWindow || p[2] == 0x06){
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
			[self setLastRequest:nil];			 //clear the last request
			doNextCommand = YES;
		}
	}
	
	if(doNextCommand){
		[ORTimer delay:.1];
		[self processOneCommandFromQueue];	 //do the next command in the queue
	}
}
- (void) pollPressures
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollPressures) object:nil];
	[self updateAll];
	[self performSelector:@selector(pollPressures) withObject:nil afterDelay:pollTime];
}

@end