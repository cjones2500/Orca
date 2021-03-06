//
//  ORMPodCModel.h
//  Orca
//
//  Created by Mark Howe on Thurs Jan 6,2011
//  Copyright (c) 2011 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina Department of Physics and Astrophysics 
//sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ���Imported Files
#import "ORMPodCard.h"
#import "ORMPodProtocol.h"

@interface ORMPodCModel :  ORMPodCard <ORMPodProtocol>
{
	NSMutableArray*	connectionHistory;
	unsigned		ipNumberIndex;
	NSString*		IPNumber;
	NSTask*			pingTask;
	NSMutableDictionary* systemParams;
	BOOL			oldPower;
	double			queueCount;
    BOOL			verbose;
	NSMutableDictionary* dictionaryFromWebPage;
}

#pragma mark ***Accessors
- (BOOL) verbose;
- (void) setVerbose:(BOOL)aVerbose;
- (BOOL) power;
- (void) initConnectionHistory;
- (void) clearHistory;
- (unsigned) connectionHistoryCount;
- (id) connectionHistoryItem:(unsigned)index;
- (unsigned) ipNumberIndex;
- (NSString*) IPNumber;
- (void) setIPNumber:(NSString*)aIPNumber;
- (void) updateAllValues;
- (NSArray*) systemUpdateList;
- (void) processSystemResponseArray:(NSArray*)response;
- (int) systemParamAsInt:(NSString*)name;
- (id) systemParam:(NSString*)name;
- (void) togglePower;
- (void) setQueCount:(NSNumber*)n;
- (void) writeMaxTerminalVoltage;
- (void) writeMaxTemperature;
- (NSMutableDictionary*) systemParams;
#pragma mark ���Hardware Access
- (id) controllerCard;
- (void) ping;
- (BOOL) pingTaskRunning;
- (void) getValue:(NSString*)aCmd target:(id)aTarget selector:(SEL)aSelector priority:(NSOperationQueuePriority)aPriority;
- (void) getValue:(NSString*)aCmd target:(id)aTarget selector:(SEL)aSelector;
- (void) writeValue:(NSString*)aCmd target:(id)aTarget selector:(SEL)aSelector priority:(NSOperationQueuePriority)aPriority;
- (void) writeValue:(NSString*)aCmd target:(id)aTarget selector:(SEL)aSelector;
- (void) getValues:(NSArray*)cmds target:(id)aTarget selector:(SEL)aSelector;
- (void) getValues:(NSArray*)cmds target:(id)aTarget selector:(SEL)aSelector priority:(NSOperationQueuePriority)aPriority;
- (void) writeValues:(NSArray*)cmds target:(id)aTarget selector:(SEL)aSelector priority:(NSOperationQueuePriority)aPriority;
- (void) pollHardware;
- (void) pollHardwareAfterDelay;
- (void) callBackToTarget:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo;

#pragma mark ���Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;

@end


extern NSString* ORMPodCModelVerboseChanged;
extern NSString* ORMPodCModelCrateStatusChanged;
extern NSString* ORMPodCModelLock;
extern NSString* ORMPodCPingTask;
extern NSString* MPodCIPNumberChanged;
extern NSString* ORMPodCModelSystemParamsChanged;
extern NSString* MPodPowerFailedNotification;
extern NSString* MPodPowerRestoredNotification;
extern NSString* ORMPodCQueueCountChanged;

@interface NSObject (ORMpodCModel)
- (void) precessReadResponseArray:(NSArray*)response;
- (void) processSystemResponseArray:(NSArray*)response;
- (void) setDictionaryFromWebPage:(NSMutableDictionary*)aDictionary;

@end

@interface ORHvUrlParseOp : NSOperation {
	id                  delegate;
	NSString*           ipAddress;
}
- (id) initWithDelegate:(id)aDelegate;
- (void) dealloc;

#pragma mark ���Move Methods
- (void) main;
- (void) processSystemTable:(NSString*)aTable;
- (NSMutableDictionary*) processHVTable:(NSString*)aTable;

@property (copy)    NSString*   ipAddress;
@property (assign)  id          delegate;

@end

