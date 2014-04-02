//--------------------------------------------------------
// ORMks660BModel
// Created by Mark Howe on Wednesday, April 25, 2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files
#import "ORAdcProcessing.h"
#import "ORSerialPortWithQueueModel.h"

@class ORTimeRate;

@interface ORMks660BModel : ORSerialPortWithQueueModel <ORAdcProcessing>
{
    @private
        unsigned long		dataId;
		float				pressure;
		int					lowSetPoint[2];
		int					highSetPoint[2];
	
		unsigned long		timeMeasured;
		int					pollTime;
        NSMutableString*    buffer;
		BOOL				shipPressures;
		ORTimeRate*			timeRates;

		BOOL				loadDialog;
		int					decimalPtPosition;
		int					highHysteresis;
		int					lowHysteresis;
		int					calibrationNumber;
		int					fullScaleRB;
		float				highAlarm;
		float				highLimit;
		float				lowAlarm;
		BOOL				delay;
		BOOL				readOnce;
		BOOL				involvedInProcess;
}

#pragma mark •••Initialization
- (void) dealloc;
- (void) dataReceived:(NSNotification*)note;

#pragma mark •••Accessors
- (BOOL) involvedInProcess;
- (void) setInvolvedInProcess:(BOOL)aInvolvedInProcess;
- (float) lowAlarm;
- (void) setLowAlarm:(float)aLowAlarm;
- (float) highLimit;
- (void) setHighLimit:(float)aHighLimit;
- (float) highAlarm;
- (void) setHighAlarm:(float)aHighAlarm;
- (int) fullScaleRB;
- (void) setFullScaleRB:(int)aFullScaleRB;
- (int) calibrationNumber;
- (void) setCalibrationNumber:(int)aCalibrationNumber;
- (int) lowHysteresis;
- (void) setLowHysteresis:(int)aLowHysteresis;
- (int) highHysteresis;
- (void) setHighHysteresis:(int)aHighHysteresis;
- (int) decimalPtPosition;
- (void) setDecimalPtPosition:(int)aDecimalPtPosition;
- (ORTimeRate*)timeRate;
- (BOOL) shipPressures;
- (void) setShipPressures:(BOOL)aShipPressures;
- (int)  pollTime;
- (void) setPollTime:(int)aPollTime;
- (float) pressure;
- (unsigned long) timeMeasured;
- (void) setPressure:(float)aValue;
- (int) lowSetPoint:(int)index;
- (int) highSetPoint:(int)index;
- (void) setLowSetPoint:(int)index withValue:(int)aValue;
- (void) setHighSetPoint:(int)index withValue:(int)aValue;

#pragma mark •••Data Records
- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (NSDictionary*) dataRecordDescription;
- (unsigned long) dataId;
- (void) setDataId: (unsigned long) DataId;
- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherMks660B;
- (void) shipPressureValues;
- (void) addCmdToQueue:(NSString*)aCmd waitForResponse:(BOOL)waitForResponse;

#pragma mark •••Commands
- (void) readAndLoad;
- (void) readPressure;
- (void) readSetPoints;
- (void) readFullScale;
- (void) readDecimalPtPosition;
- (void) readHysteresis;

- (void) writeZeroDisplay;
- (void) writeFullScale;
- (void) writeCalibrationNumber;
- (void) writeSetPoints;
- (void) writeHysteresis;
- (void) writeCalibrationNumber;
- (void) writeDecimalPtPosition;

- (void) pollHardware;
- (void) initHardware;
- (void) readAndCompare;

- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;

#pragma mark •••Adc Processing Protocol
- (void) processIsStarting;
- (void) processIsStopping;
- (void) startProcessCycle;
- (void) endProcessCycle;
- (NSString*) identifier;
- (NSString*) processingTitle;
- (double) convertedValue:(int)aChan;
- (double) maxValueForChan:(int)aChan;
- (double) minValueForChan:(int)aChan;
- (void) getAlarmRangeLow:(double*)theLowLimit high:(double*)theHighLimit channel:(int)aChan;
- (BOOL) processValue:(int)channel;
- (void) setProcessOutput:(int)channel value:(int)value;

@end

@interface ORMks660BCmd : NSObject
{
	BOOL waitForResponse;
	NSString* cmd;
}

@property (nonatomic,assign) BOOL waitForResponse;
@property (nonatomic,copy) NSString* cmd;
@end


extern NSString* ORMks660BModelLowAlarmChanged;
extern NSString* ORMks660BModelHighLimitChanged;
extern NSString* ORMks660BModelHighAlarmChanged;
extern NSString* ORMks660BModelFullScaleRBChanged;
extern NSString* ORMks660BModelCalibrationNumberChanged;
extern NSString* ORMks660BModelLowHysteresisChanged;
extern NSString* ORMks660BModelHighHysteresisChanged;
extern NSString* ORMks660BModelDecimalPtPositionChanged;
extern NSString* ORMks660BShipPressuresChanged;
extern NSString* ORMks660BPollTimeChanged;
extern NSString* ORMks660BPressureChanged;
extern NSString* ORMks660BLowSetPointChanged;
extern NSString* ORMks660BHighSetPointChanged;
extern NSString* ORMks660BInvolvedInProcessChanged;
extern NSString* ORMks660BLock;
