//
//  ORPanicButtonModel.m
//  Orca
//
//  Created by Chris Jones on 25/07/2014.
//
//

#import "ORPanicButtonModel.h"

@implementation ORPanicButtonModel

- (void) setUpImage
{
    [self setImage:[NSImage imageNamed:@"panic"]];
}

- (void) makeMainController
{
    [self linkToController:@"ORPanicButtonController"];
}

- (void) wakeUp
{
    if([self aWake])return;
    [super wakeUp];
}

- (void) sleep
{
	[super sleep];
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[super dealloc];
}

@end
