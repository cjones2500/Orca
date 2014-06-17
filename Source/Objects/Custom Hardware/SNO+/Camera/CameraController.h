//
//  CameraController.h
//  Orca
//
//  Created by Joulien on 5/4/14.
//
//

#import <Foundation/Foundation.h>

@interface CameraController : OrcaObjectController
{
    IBOutlet NSButton*      takePicButton;
    IBOutlet NSTextField*   runStateField;
}


-( id )     init;
-( void )   dealloc;

-( void )   updateWindow;
-( void )   registerNotificationObservers;


#pragma mark *** Interface Management

#pragma mark *** Actions

-( IBAction ) takePicAction : (id) sender;

@end