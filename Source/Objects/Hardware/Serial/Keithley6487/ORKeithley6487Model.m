//--------------------------------------------------------
// ORKeithley6487Model
// Created by Mark  A. Howe on Fri Jul 22 2005
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
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

#import "ORKeithley6487Model.h"
#import "ORSerialPort.h"
#import "ORSerialPortList.h"
#import "ORSerialPort.h"
#import "ORSerialPortAdditions.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"
#import "ORTimeRate.h"

#pragma mark ***External Strings
NSString* ORKeithley6487ModelShipCurrentChanged = @"ORKeithley6487ModelShipCurrentChanged";
NSString* ORKeithley6487ModelPollTimeChanged	= @"ORKeithley6487ModelPollTimeChanged";
NSString* ORKeithley6487ModelSerialPortChanged	= @"ORKeithley6487ModelSerialPortChanged";
NSString* ORKeithley6487ModelPortNameChanged	= @"ORKeithley6487ModelPortNameChanged";
NSString* ORKeithley6487ModelPortStateChanged	= @"ORKeithley6487ModelPortStateChanged";
NSString* ORKeithley6487CurrentChanged			= @"ORKeithley6487CurrentChanged";

NSString* ORKeithley6487Lock = @"ORKeithley6487Lock";

@interface ORKeithley6487Model (private)
- (void) runStarted:(NSNotification*)aNote;
- (void) runStopped:(NSNotification*)aNote;
- (void) timeout;
- (void) processOneCommandFromQueue;
- (void) pollCurrent;
//- (void) process_xrdg_response:(NSString*)theResponse args:(NSArray*)cmdArgs;
@end

@implementation ORKeithley6487Model
- (id) init
{
	self = [super init];
    [self registerNotificationObservers];
	return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [buffer release];
	[cmdQueue release];
	[lastRequest release];
    [portName release];
    if([serialPort isOpen]){
        [serialPort close];
    }
    [serialPort release];
	[timeRate release];


	[super dealloc];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"Keithley6487"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORKeithley6487Controller"];
}

//- (NSString*) helpURL
//{
//	return @"RS232/LakeShore_210.html";
//}

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];

    [notifyCenter addObserver : self
                     selector : @selector(dataReceived:)
                         name : ORSerialPortDataReceived
                       object : nil];

    [notifyCenter addObserver: self
                     selector: @selector(runStarted:)
                         name: ORRunStartedNotification
                       object: nil];
    
    [notifyCenter addObserver: self
                     selector: @selector(runStopped:)
                         name: ORRunStoppedNotification
                       object: nil];

}

- (void) dataReceived:(NSNotification*)note
{
    if([[note userInfo] objectForKey:@"serialPort"] == serialPort){
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
        NSString* theString = [[[[NSString alloc] initWithData:[[note userInfo] objectForKey:@"data"] 
												      encoding:NSASCIIStringEncoding] autorelease] uppercaseString];

		//the serial port may break the data up into small chunks, so we have to accumulate the chunks until
		//we get a full piece.
        theString = [[theString componentsSeparatedByString:@"\n"] componentsJoinedByString:@""];
        if(!buffer)buffer = [[NSMutableString string] retain];
        [buffer appendString:theString];					
		
        do {
            NSRange lineRange = [buffer rangeOfString:@"\r"];
            if(lineRange.location!= NSNotFound){
                NSMutableString* theResponse = [[[buffer substringToIndex:lineRange.location+1] mutableCopy] autorelease];
                [buffer deleteCharactersInRange:NSMakeRange(0,lineRange.location+1)];      //take the cmd out of the buffer
				//NSArray* lastCmdParts = [lastRequest componentsSeparatedByString:@" "];
				//NSString* lastCmd = [lastCmdParts objectAtIndex:0];
				NSLog(@"Received: <%@>\n",theResponse);
				//if([lastCmd isEqualToString: @"KRDG?"])      [self process_xrdg_response:theResponse args:lastCmdParts];
				//else if([lastCmd isEqualToString: @"CRDG?"]) [self process_xrdg_response:theResponse args:lastCmdParts];
		
				[self setLastRequest:nil];			 //clear the last request
				[self processOneCommandFromQueue];	 //do the next command in the queue
            }
        } while([buffer rangeOfString:@"\r"].location!= NSNotFound);
	}
}


- (void) shipCurrentValue
{
    if([[ORGlobal sharedGlobal] runInProgress]){
		
		unsigned long data[4];
		data[0] = dataId | 4;
		data[1] =  ([self uniqueIdNumber]&0x0000fffff);
		
		union {
			float asFloat;
			unsigned long asLong;
		}theData;
		theData.asFloat = current;
		data[2] = theData.asLong;
		data[3] = timeMeasured;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORQueueRecordForShippingNotification 
															object:[NSData dataWithBytes:data length:sizeof(long)*4]];
	}
}


#pragma mark ***Accessors
- (ORTimeRate*)timeRate
{
	return timeRate;
}

- (BOOL) shipCurrent
{
    return shipCurrent;
}

- (void) setShipCurrent:(BOOL)aFlag
{
    [[[self undoManager] prepareWithInvocationTarget:self] setShipCurrent:shipCurrent];
    
    shipCurrent = aFlag;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORKeithley6487ModelShipCurrentChanged object:self];
}

- (int) pollTime
{
    return pollTime;
}

- (void) setPollTime:(int)aPollTime
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPollTime:pollTime];
    pollTime = aPollTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORKeithley6487ModelPollTimeChanged object:self];

	if(pollTime){
		[self performSelector:@selector(pollCurrent) withObject:nil afterDelay:2];
	}
	else {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollCurrent) object:nil];
	}
}


- (float) current
{
	return current;
}

- (unsigned long) timeMeasured
{
	return timeMeasured;
}

- (void) setCurrent:(float)aValue;
{
	current = aValue;
	//get the time(UT!)
	time_t	ut_Time;
	time(&ut_Time);
	//struct tm* theTimeGMTAsStruct = gmtime(&theTime);
	timeMeasured = ut_Time;

	[[NSNotificationCenter defaultCenter] postNotificationName:ORKeithley6487CurrentChanged 
														object:self 
													userInfo:nil];

	if(timeRate == nil) timeRate = [[ORTimeRate alloc] init];
	[timeRate addDataToTimeAverage:aValue];

}

- (NSString*) lastRequest
{
	return lastRequest;
}

- (void) setLastRequest:(NSString*)aRequest
{
	[lastRequest autorelease];
	lastRequest = [aRequest copy];    
}

- (BOOL) portWasOpen
{
    return portWasOpen;
}

- (void) setPortWasOpen:(BOOL)aPortWasOpen
{
    portWasOpen = aPortWasOpen;
}

- (NSString*) portName
{
    return portName;
}

- (void) setPortName:(NSString*)aPortName
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPortName:portName];
    
    if(![aPortName isEqualToString:portName]){
        [portName autorelease];
        portName = [aPortName copy];    

        BOOL valid = NO;
        NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
        ORSerialPort *aPort;
        while (aPort = [enumerator nextObject]) {
            if([portName isEqualToString:[aPort name]]){
                [self setSerialPort:aPort];
                if(portWasOpen){
                    [self openPort:YES];
                 }
                valid = YES;
                break;
            }
        } 
        if(!valid){
            [self setSerialPort:nil];
        }       
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:ORKeithley6487ModelPortNameChanged object:self];
}

- (ORSerialPort*) serialPort
{
    return serialPort;
}

- (void) setSerialPort:(ORSerialPort*)aSerialPort
{
    [aSerialPort retain];
    [serialPort release];
    serialPort = aSerialPort;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORKeithley6487ModelSerialPortChanged object:self];
}

- (void) openPort:(BOOL)state
{
    if(state) {
        [serialPort open];
		[serialPort setSpeed:9600];
		[serialPort setParityOdd];
		[serialPort setStopBits2:1];
		[serialPort setDataBits:7];
		[serialPort commitChanges];
    }
    else      [serialPort close];
    portWasOpen = [serialPort isOpen];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORKeithley6487ModelPortStateChanged object:self];
    
}


#pragma mark ***Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setShipCurrent:	[decoder decodeBoolForKey:@"shipCurrent"]];
	[self setPollTime:		[decoder decodeIntForKey:@"pollTime"]];
	[self setPortWasOpen:	[decoder decodeBoolForKey:@"portWasOpen"]];
    [self setPortName:		[decoder decodeObjectForKey: @"portName"]];
	[[self undoManager] enableUndoRegistration];
	timeRate = [[ORTimeRate alloc] init];

    [self registerNotificationObservers];

	return self;
}
- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeBool:shipCurrent forKey:@"shipCurrent"];
    [encoder encodeInt:pollTime		forKey:@"pollTime"];
    [encoder encodeBool:portWasOpen forKey:@"portWasOpen"];
    [encoder encodeObject:portName	forKey: @"portName"];
}

#pragma mark *** Commands
- (void) addCmdToQueue:(NSString*)aCmd
{
    if([serialPort isOpen]){ 
		if(!cmdQueue)cmdQueue = [[NSMutableArray array] retain];
		[cmdQueue addObject:aCmd];
		if(!lastRequest){
			[self processOneCommandFromQueue];
		}
	}
}

- (void) readCurrent
{
	[self addCmdToQueue:@"FETCH?"];
}

#pragma mark ***Data Records
- (unsigned long) dataId { return dataId; }
- (void) setDataId: (unsigned long) DataId
{
    dataId = DataId;
}
- (void) setDataIds:(id)assigner
{
    dataId       = [assigner assignDataIds:kLongForm];
}

- (void) syncDataIdsWith:(id)anotherKeithley6487
{
    [self setDataId:[anotherKeithley6487 dataId]];
}

- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"Keithley6487Model"];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        @"ORKeithley6487DecoderForCurrent",@"decoder",
        [NSNumber numberWithLong:dataId],   @"dataId",
        [NSNumber numberWithBool:NO],       @"variable",
        [NSNumber numberWithLong:18],       @"length",
        nil];
    [dataDictionary setObject:aDictionary forKey:@"Current"];
    
    return dataDictionary;
}

@end

@implementation ORKeithley6487Model (private)
- (void) runStarted:(NSNotification*)aNote
{
}

- (void) runStopped:(NSNotification*)aNote
{
}

- (void) timeout
{
	NSLogError(@"command timeout",@"Keithley 6487",nil);
	[self setLastRequest:nil];
	[self processOneCommandFromQueue];	 //do the next command in the queue
}

- (void) processOneCommandFromQueue
{
	if([cmdQueue count] == 0) return;
	NSString* aCmd = [[[cmdQueue objectAtIndex:0] retain] autorelease];
	[cmdQueue removeObjectAtIndex:0];
	
	if([aCmd rangeOfString:@"?"].location != NSNotFound){
		[self setLastRequest:aCmd];
		[self performSelector:@selector(timeout) withObject:nil afterDelay:3];
	}
	if(![aCmd hasSuffix:@"\r\n"]) aCmd = [aCmd stringByAppendingString:@"\r\n"];
	[serialPort writeString:aCmd];
	if(!lastRequest){
		[self performSelector:@selector(processOneCommandFromQueue) withObject:nil afterDelay:.01];
	}
}

//- (void) process_xrdg_response:(NSString*)theResponse args:(NSArray*)cmdArgs
//{
//	NSArray* t = [theResponse componentsSeparatedByString:@","];
//	[self setCurrent:[[t objectAtIndex:i] floatValue]];
//	if(shipCurrent) [self shipCurrent];
//}
- (void) pollCurrent
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollCurrent) object:nil];
	[self readCurrent];
	
	//---for testing---	
	//	testValue = testValue+2;
	//	[self setCurrent:200 + 10 + testValue];
	
	//	if(shipCurrent) [self shipCurrent];
	//-------------	
	
	[self performSelector:@selector(pollCurrent) withObject:nil afterDelay:pollTime];
}

@end