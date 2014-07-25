//
//  ORPanicButtonControllerWindowController.m
//  Orca
//
//  Created by Chris Jones on 25/07/2014.
//
//

#import "ORPanicButtonController.h"


@implementation ORPanicButtonController

-(id)init
{
    self = [super initWithWindowNibName:@"panic"];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) updateWindow
{
	[super updateWindow];
    
}

- (void) registerNotificationObservers
{
	//NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
	[super registerNotificationObservers];
}

@end
