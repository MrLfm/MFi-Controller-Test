//
//  GSGameController.h
//  gameController
//
//  Created by César Manuel Pinto Castillo on 20/04/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameController/GameController.h>

typedef NS_ENUM(NSInteger, GSGamepadType) {
    GSGamepadTypeExtended,
    GSGamepadTypeNA
};

@interface GSGameController : NSObject

@property (nonatomic, strong) GCController *controller;

@end
