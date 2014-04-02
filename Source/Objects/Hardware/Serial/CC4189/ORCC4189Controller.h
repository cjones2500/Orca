//--------------------------------------------------------
// ORCC4189Controller
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
@class ORSerialPortController;
@class ORCompositeTimeLineView;

@interface ORCC4189Controller : OrcaObjectController
{
	IBOutlet NSTabView*		tabView;	
	IBOutlet NSView*		totalView;
	IBOutlet NSTextField*	highLimit1Field;
	IBOutlet NSTextField*	highLimit0Field;
	IBOutlet NSTextField*	lowLimit1Field;
	IBOutlet NSTextField*	lowLimit0Field;
	IBOutlet NSButton*		shipValuesButton;
    IBOutlet NSButton*      lockButton;
    IBOutlet NSTextField*   temperatureField;
    IBOutlet NSTextField*   humidityField;
    IBOutlet NSTextField*   timeField;
	IBOutlet ORCompositeTimeLineView*    plotter0;
    IBOutlet ORSerialPortController* serialPortController;
	
	NSSize					basicOpsSize;
	NSSize					valuesSize;
	NSSize					plotSize;
	NSSize					processLimitSize;
	NSView*					blankView;
}

#pragma mark ***Initialization
- (id) init;
- (void) dealloc;
- (void) awakeFromNib;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark ***Interface Management
- (void) highLimit1Changed:(NSNotification*)aNote;
- (void) highLimit0Changed:(NSNotification*)aNote;
- (void) lowLimit1Changed:(NSNotification*)aNote;
- (void) lowLimit0Changed:(NSNotification*)aNote;
- (void) updateTimePlot:(NSNotification*)aNotification;
- (void) scaleAction:(NSNotification*)aNotification;
- (void) shipValuesChanged:(NSNotification*)aNotification;
- (void) lockChanged:(NSNotification*)aNotification;
- (void) temperatureChanged:(NSNotification*)aNotification;
- (void) humidityChanged:(NSNotification*)aNotification;
- (void) miscAttributesChanged:(NSNotification*)aNotification;
- (void) scaleAction:(NSNotification*)aNotification;
- (void) tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
- (void) windowDidResize:(NSNotification *)aNote;

#pragma mark ***Actions
- (IBAction) highLimit1Action:(id)sender;
- (IBAction) highLimit0Action:(id)sender;
- (IBAction) lowLimit1Action:(id)sender;
- (IBAction) lowLimit0Action:(id)sender;
- (IBAction) shipValuesAction:(id)sender;
- (IBAction) lockAction:(id) sender;

@end


