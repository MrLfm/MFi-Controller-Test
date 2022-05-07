/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Provides an interface for communication with an EASession. Also the delegate for the EASession input and output stream objects.
 */

#import "EADSessionController.h"
@interface EADSessionController ()

@property (nonatomic, strong) EASession *session;
@property (nonatomic, strong) NSMutableData *writeData;
@property (nonatomic, strong) NSMutableData *readData;

@end

NSString *EADSessionDataReceivedNotification = @"EADSessionDataReceivedNotification";
NSString *EADSessionEAAccessoryDidDisconnectedNotification = @"EADSessionEAAccessoryDidDisconnectedNotification";


@implementation EADSessionController

#pragma mark Internal

// low level write method - write data to the accessory while there is space available and data to write
- (void)_writeData {
    while (([[_session outputStream] hasSpaceAvailable]) && ([_writeData length] > 0))
    {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeData bytes] maxLength:[_writeData length]];
        if (bytesWritten == -1)
        {
            NSLog(@"write error");
            break;
        }
        else if (bytesWritten > 0)
        {
            [_writeData replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
            NSLog(@"bytesWritten %ld", (long)bytesWritten);
        }
    }
}

// low level read method - read data while there is data and space available in the input buffer
- (void)_readData {
#define EAD_INPUT_BUFFER_SIZE 128
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];
//    NSLog(@"XJLog func:%s  [Line %d]", __func__, __LINE__);
    while ([[_session inputStream] hasBytesAvailable])
    {
//        NSLog(@"XJLog func:%s  [Line %d]", __func__, __LINE__);
        NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
        if (_readData == nil) {
            _readData = [[NSMutableData alloc] init];
        }
        [_readData appendBytes:(void *)buf length:bytesRead];
//        NSLog(@"read %ld bytes from input stream", (long)bytesRead);
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:EADSessionDataReceivedNotification object:self userInfo:nil];
}

#pragma mark Public Methods

+ (EADSessionController *)sharedController
{
    static EADSessionController *sessionController = nil;
    if (sessionController == nil) {
        sessionController = [[EADSessionController alloc] init];
    }

    return sessionController;
}

- (void)dealloc
{
    [self closeSession];
    [self setupControllerForAccessory:nil withProtocolString:nil];
}

// initialize the accessory with the protocolString
- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString
{
    _accessory = accessory;
    _protocolString = [protocolString copy];
}

// open a session with the accessory and set up the input and output stream on the default run loop
- (BOOL)openSession
{
    [_accessory setDelegate:self];
    _session = [[EASession alloc] initWithAccessory:_accessory forProtocol:_protocolString];

    if (_session)
    {
        NSLog(@"Session created");

        [[_session inputStream] setDelegate:self];
        [[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session inputStream] open];

        [[_session outputStream] setDelegate:self];
        [[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session outputStream] open];
    }
    else
    {
        NSLog(@"Failed to create session");
    }

    return (_session != nil);
}

// close the session with the accessory.
- (void)closeSession
{
    NSLog(@"Close session：\n%@", _session);
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];

    _session = nil;

    _writeData = nil;
    _readData = nil;
}

// high level write data method
- (void)writeData:(NSData *)data
{
    if (_writeData == nil) {
        _writeData = [[NSMutableData alloc] init];
    }

    [_writeData appendData:data];
    [self _writeData];
}

// high level read method 
- (NSData *)readData:(NSUInteger)bytesToRead
{
#define EAD_INPUT_BUFFER_SIZE 128
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];

    NSData *data = nil;
//    if ([_readData length] >= bytesToRead) {
        NSRange range = NSMakeRange(0, bytesToRead);
        data = [_readData subdataWithRange:range];
        [_readData replaceBytesInRange:range withBytes:NULL length:0];
//        NSLog(@"XJLog func:%s  [Line %d]", __func__, __LINE__);
        if ([[_session inputStream] hasBytesAvailable])
        {
//            NSLog(@"XJLog func:%s  [Line %d]", __func__, __LINE__);
            NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
            if (_readData == nil) {
                _readData = [[NSMutableData alloc] init];
            }
            [_readData appendBytes:(void *)buf length:bytesRead];
//            NSLog(@"read %ld bytes from input stream", (long)bytesRead);
        }
        
        
//    }
    return data;
}

// get number of bytes read into local buffer
- (NSUInteger)readBytesAvailable
{
    return [_readData length];
}

#pragma mark EAAccessoryDelegate
- (void)accessoryDidDisconnect:(EAAccessory *)accessory
{
    // do something ...
//    NSLog(@"XJLog func:%s  [Line %d]", __func__, __LINE__);
//    [[NSNotificationCenter defaultCenter] postNotificationName:EADSessionEAAccessoryDidDisconnectedNotification object:self userInfo:nil];
}

#pragma mark NSStreamDelegateEventExtensions

// asynchronous NSStream handleEvent method
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
//    NSLog(@"XJLog func:%s eventCode:%@  [Line %d]", __func__, @(eventCode), __LINE__);
    switch (eventCode) {
        case NSStreamEventNone:{
//            NSLog(@"XJLog NSStreamEventNone eventCode:%@ func:%s  [Line %d]",@(eventCode), __func__, __LINE__);
        }
            break;
        case NSStreamEventOpenCompleted:{
//            NSLog(@"XJLog NSStreamEventOpenCompleted eventCode:%@  func:%s  [Line %d]",@(eventCode), __func__, __LINE__);
        }
            break;
        case NSStreamEventHasBytesAvailable: {
            [self _readData];
//            NSLog(@"XJLog NSStreamEventHasBytesAvailable eventCode:%@  func:%s  [Line %d]",@(eventCode), __func__, __LINE__);
        }
            break;
        case NSStreamEventHasSpaceAvailable:{
            [self _writeData];
//            NSLog(@"XJLog NSStreamEventHasSpaceAvailable eventCode:%@ func:%s  [Line %d]",@(eventCode), __func__, __LINE__);
        }
            break;
        case NSStreamEventErrorOccurred:{
//            NSLog(@"XJLog NSStreamEventErrorOccurred eventCode:%@ func:%s  [Line %d]",@(eventCode), __func__, __LINE__);
        }
            break;
        case NSStreamEventEndEncountered:{
//            NSLog(@"XJLog NSStreamEventEndEncountered eventCode:%@ func:%s  [Line %d]",@(eventCode), __func__, __LINE__);
        }
            break;
        default:
            break;
    }
}

#pragma mark Accessory
- (BOOL)checkConnectedAccessory {
    NSUInteger connectedAccessoriesCount = [EAAccessoryManager sharedAccessoryManager].connectedAccessories.count;
    
    if (connectedAccessoriesCount == 0) {
        return NO;
    }
    
    NSArray *supportedProtocols = [NSBundle.mainBundle objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];

    NSArray *accessorys = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    for (EAAccessory *accessory in accessorys) {
        NSArray *protocolStrings = accessory.protocolStrings;
        for(NSString *protocolString in protocolStrings) {
            if (accessory) {
                for (NSString *item in supportedProtocols) {
                    if ([item isEqualToString:protocolString]) {
                        return YES;
                    }
                }
            }
        }
    }

    return NO;
}

@end
