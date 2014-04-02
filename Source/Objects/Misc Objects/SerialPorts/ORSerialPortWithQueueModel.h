//--------------------------------------------------------
// ORSerialPortWithQueueModel.h
// Created by Mark  A. Howe on Wed 7/27/2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina  sponsored in part by the United States 
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
#import "ORSerialPortModel.h"

@class ORSafeQueue;
@class ORAlarm;

@interface ORSerialPortWithQueueModel : ORSerialPortModel
{
    @protected
	ORSafeQueue*	cmdQueue;
	id				lastRequest;
	BOOL			isValid;
	ORAlarm*		timeoutAlarm;
	int				timeoutCount;
}

- (void) dealloc;

#pragma mark •••Accessors
- (id) lastRequest;
- (void) setLastRequest:(id)aCmd;
- (BOOL) isValid;
- (void) setIsValid:(BOOL)aState;
- (void) openPort:(BOOL)state;
- (void) setUpPort;
- (void) firstActionAfterOpeningPort;

#pragma mark •••Cmd Handling
- (id) nextCmd;
- (void) enqueueCmd:(id)aCmd;
- (void) cancelTimeout;
- (void) startTimeout:(int)aDelay;
- (void) setTimeoutCount:(int)aValue;
- (void) timeout;
- (void) clearTimeoutAlarm;
- (void) postTimeoutAlarm;
- (void) recoverFromTimeout;
- (int) timeoutCount;
@end

extern NSString* ORSerialPortWithQueueModelIsValidChanged;
extern NSString* ORSerialPortWithQueueModelPortClosedAfterTimeout;
extern NSString* ORSerialPortWithQueueModelTimeoutCountChanged;
