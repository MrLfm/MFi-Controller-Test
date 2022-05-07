//
//  GSGameControllerManager.h
//  gameController
//
//  Created by César Manuel Pinto Castillo on 02/05/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GSGameControllerManager;
@class GSGameController;

@protocol GSGameControllerManagerDelegate <NSObject>
@optional
- (void)manager:(GSGameControllerManager *)manager didConnect:(GSGameController *)gameController;
- (void)manager:(GSGameControllerManager *)manager didDisconnect:(GSGameController *)gameController;
@end

typedef void (^GSGamepadKeyPressedBlock)(BOOL pressed, CGFloat value);
typedef void (^GSGamepadJoystickChangedBlock)(CGFloat x, CGFloat y);
@interface GSGameControllerManager : NSObject

@property (nonatomic,assign) id <GSGameControllerManagerDelegate> delegate;
@property (nonatomic, copy) GSGamepadKeyPressedBlock keyAPressed, keyBPressed, keyXPressed, keyYPressed;
@property (nonatomic, copy) GSGamepadKeyPressedBlock keyL1Pressed, keyL2Pressed, keyL3Pressed, keyR1Pressed, keyR2Pressed, keyR3Pressed;
@property (nonatomic, copy) GSGamepadKeyPressedBlock keyUpPressed, keyDownPressed, keyLeftPressed, keyRightPressed;
@property (nonatomic, copy) GSGamepadKeyPressedBlock keyHomePressed, keyMenuPressed, keyOptionsPressed;
@property (nonatomic, copy) GSGamepadJoystickChangedBlock leftJoystickChanged, rightJoystickChanged;

+ (instancetype)shared;
- (NSArray *)connectedGameControllers;

@end
