//--------------------------------------------------------
// ORSBC_LAMModel
// Created by Mark  A. Howe on Mon Aug 23 2004
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2004 CENPA, University of Washington. All rights reserved.
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

#pragma mark ***Imported Files


#import "ORCard.h"
#import "ORDataTaker.h"
#import "SBC_Config.h"
#import "SBC_Cmds.h"

@class ORReadOutList;

@interface ORSBC_LAMModel : ORCard <ORDataTaker>
{
	BOOL			busy;
	SBC_Packet		sbcPacket;
	ORReadOutList*  readoutGroup;
    NSMutableArray* variableNames;
	NSArray*		dataTakers;       //cache of data takers.
	unsigned long  cachedNumberOfDataTakers;
}

#pragma mark ***Initialization

- (id)   init;
- (void) dealloc;

#pragma mark ***Accessors
- (NSString*) identifier;
- (BOOL) acceptsGuardian: (OrcaObject *)aGuardian;
- (ORReadOutList*) readoutGroup;
- (void) setReadoutGroup:(ORReadOutList*)newreadoutGroup;
- (void) saveReadOutList:(NSFileHandle*)aFile;
- (void) loadReadOutList:(NSFileHandle*)aFile;
- (NSMutableArray*) children;
- (NSMutableArray *) variableNames;
- (void) setVariableNames: (NSMutableArray *) VariableNames;
- (BOOL) isBusy;
- (void) processPacket:(SBC_Packet*)aPacket;

#pragma mark •••DataTaker
- (void) runTaskStarted:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (void) takeData:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (void) runTaskStopped:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (int) load_HW_Config_Structure:(SBC_crate_config*)configStruct index:(int)index;
- (void) reset;
@end

#pragma mark •••Extern Definitions
extern NSString* ORSBC_LAMSlotChangedNotification;
extern NSString* ORSBC_LAMLock;