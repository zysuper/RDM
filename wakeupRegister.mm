#include "wakeupRegister.h"
#import <Foundation/Foundation.h>
#include <IOKit/pwr_mgt/IOPMLib.h>
#include <IOKit/IOMessage.h>
#include <stdlib.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "utils.h"
#import "SRApplicationDelegate.h"

io_connect_t  root_port; // a reference to the Root Power Domain IOService

void
MySleepCallBack( void * refCon, io_service_t service,
        natural_t messageType, void * messageArgument ) {
    SRApplicationDelegate* delegate = (SRApplicationDelegate*)refCon;

    switch ( messageType ) {
        case kIOMessageSystemWillSleep:
            fprintf(stderr,"kIOMessageSystemWillSleep--\n");
            break;
        case kIOMessageSystemHasPoweredOn:
            fprintf(stderr,"kIOMessageSystemHasPoweredOn--\n");
            //resetDisplay();
            break;
        case kIOMessageSystemWillPowerOn:
            fprintf(stderr,"kIOMessageSystemWillPowerOn--\n");
            [delegate performSelectorOnMainThread:@selector(resetDisplay) withObject:nil waitUntilDone:false];
            break;
        case kIOMessageCanSystemSleep:
            fprintf(stderr,"kIOMessageCanSystemSleep--\n");
            break;
        case kIOMessageSystemWillNotSleep:
            fprintf(stderr,"kIOMessageSystemWillNotSleep--\n");
            break;
        default:
            fprintf(stderr, "messageType %08lx, arg %08lx\n",
                    (long unsigned int)messageType,
                    (long unsigned int)messageArgument );
    }
}

int registerWakeup(void* delegate) {
    fprintf(stderr,"register ok\n");
     // notification port allocated by IORegisterForSystemPower
    IONotificationPortRef  notifyPortRef;

    // notifier object, used to deregister later
    io_object_t            notifierObject;
    // this parameter is passed to the callback
    // void*                  refCon;

    root_port = IORegisterForSystemPower(delegate, &notifyPortRef, MySleepCallBack, &notifierObject );
    if ( root_port == 0 )
    {
        printf("IORegisterForSystemPower failed\n");
        return 1;
    }

    // add the notification port to the application runloop
    CFRunLoopAddSource( CFRunLoopGetCurrent(),
            IONotificationPortGetRunLoopSource(notifyPortRef), kCFRunLoopCommonModes );

    return 0;
}