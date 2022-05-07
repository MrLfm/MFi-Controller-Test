//
//  GSGameControllerManager.m
//  gameController
//
//  Created by César Manuel Pinto Castillo on 02/05/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "GSGameControllerManager.h"
#import "GSGameController.h"

@implementation GSGameControllerManager

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static GSGameControllerManager *shared;
    dispatch_once(&onceToken, ^{
        shared = [GSGameControllerManager new];
        
        [[NSNotificationCenter defaultCenter] addObserver:shared
                                                 selector:@selector(gameControllerConnected:)
                                                     name:GCControllerDidConnectNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:shared
                                                 selector:@selector(gameControllerDisconnected:)
                                                     name:GCControllerDidDisconnectNotification
                                                   object:nil];
    });
    return shared;
}

- (NSArray *)connectedGameControllers {
    return [GCController controllers];
}

#pragma mark - Private functions
- (void)gameControllerConnected:(NSNotification *)notification {
    GCController *controller = notification.object;
    if ([controller playerIndex] == -1) {
        [controller setPlayerIndex:[[self connectedGameControllers] count]-1];
    }
    
    GSGameController *gameController = [GSGameController new];
    gameController.controller = controller;
    
    NSLog(@"Controller's name：%@", controller.vendorName);
    
    if ([self.delegate respondsToSelector:@selector(manager:didConnect:)]) {
        [self.delegate manager:self didConnect:gameController];
    }
}

- (void)gameControllerDisconnected:(NSNotification *)notification {
    GCController *controller = notification.object;
    GSGameController *gameController = [GSGameController new];
    gameController.controller = controller;
    
    if ([self.delegate respondsToSelector:@selector(manager:didDisconnect:)]) {
        [self.delegate manager:self didDisconnect:gameController];
    }
}

@end
