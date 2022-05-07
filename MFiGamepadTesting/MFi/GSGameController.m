//
//  GSGameController.m
//  gameController
//
//  Created by César Manuel Pinto Castillo on 20/04/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "GSGameController.h"
#import "GSGameControllerManager.h"

@interface GSGameController ()
@property (nonatomic) GCExtendedGamepad *extendedGamepad;
@end

@implementation GSGameController

- (void)setController:(GCController *)controller {
    if (_controller == controller) {
        return;
    }
    
    _controller = controller;
    
    if (controller.extendedGamepad) {
        self.extendedGamepad = controller.extendedGamepad;
        [self __setupExtendedGamepad];
    }
}

static CGFloat oldDpadDefaultValue = -8.f;
static CGFloat oldDpadXValue = -8.f, oldDpadYValue = -8.f;// -8 just a mark
static float lastLX = 0, lastLY = 0, lastRX = 0, lastRY = 0;
- (void)__setupExtendedGamepad {
    
    GCControllerButtonInput *a = [self.extendedGamepad buttonA];
    GCControllerButtonInput *b = [self.extendedGamepad buttonB];
    GCControllerButtonInput *x = [self.extendedGamepad buttonX];
    GCControllerButtonInput *y = [self.extendedGamepad buttonY];
    GCControllerButtonInput *leftShoulder  = [self.extendedGamepad leftShoulder];
    GCControllerButtonInput *leftTrigger   = [self.extendedGamepad leftTrigger];
    GCControllerButtonInput *rightShoulder = [self.extendedGamepad rightShoulder];
    GCControllerButtonInput *rightTrigger  = [self.extendedGamepad rightTrigger];

    // HOME/MENU/OPTION
    if (@available(iOS 14.0, *)) {
        GCControllerButtonInput *home = [self.extendedGamepad buttonHome];
        [home setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if (GSGameControllerManager.shared.keyHomePressed) {
                GSGameControllerManager.shared.keyHomePressed(pressed, value);
            }
        }];
    }

    if (@available(iOS 13.0, *)) {
        GCControllerButtonInput *menu    = [self.extendedGamepad buttonMenu];
        GCControllerButtonInput *options = [self.extendedGamepad buttonOptions];
        [options setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if (GSGameControllerManager.shared.keyOptionsPressed) {
                GSGameControllerManager.shared.keyOptionsPressed(pressed, value);
            }
        }];
        [menu setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if (GSGameControllerManager.shared.keyMenuPressed) {
                GSGameControllerManager.shared.keyMenuPressed(pressed, value);
            }
        }];
    }
    
    // A/B/X/Y
    [a setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (GSGameControllerManager.shared.keyAPressed) {
            GSGameControllerManager.shared.keyAPressed(pressed, value);
        }
    }];
    
    [b setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (GSGameControllerManager.shared.keyBPressed) {
            GSGameControllerManager.shared.keyBPressed(pressed, value);
        }
    }];
    
    [x setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (GSGameControllerManager.shared.keyXPressed) {
            GSGameControllerManager.shared.keyXPressed(pressed, value);
        }
    }];
    
    [y setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (GSGameControllerManager.shared.keyYPressed) {
            GSGameControllerManager.shared.keyYPressed(pressed, value);
        }
    }];
    
    // L1/L2/L3/R1/R2/R3
    [leftShoulder setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (GSGameControllerManager.shared.keyL1Pressed) {
            GSGameControllerManager.shared.keyL1Pressed(pressed, value);
        }
    }];
    
    // Value not press
    [leftTrigger setValueChangedHandler:^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
        if (GSGameControllerManager.shared.keyL2Pressed) {
            GSGameControllerManager.shared.keyL2Pressed(pressed, value);
        }
    }];
    
    [rightShoulder setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (GSGameControllerManager.shared.keyR1Pressed) {
            GSGameControllerManager.shared.keyR1Pressed(pressed, value);
        }
    }];
    
    // Value not press
    [rightTrigger setValueChangedHandler:^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
        if (GSGameControllerManager.shared.keyR2Pressed) {
            GSGameControllerManager.shared.keyR2Pressed(pressed, value);
        }
    }];
    
    if (@available(iOS 12.1, *)) {
        GCControllerButtonInput *leftThumbstickButton  = [self.extendedGamepad leftThumbstickButton];
        GCControllerButtonInput *rightThumbstickButton = [self.extendedGamepad rightThumbstickButton];
        [leftThumbstickButton setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
            if (GSGameControllerManager.shared.keyL3Pressed) {
                GSGameControllerManager.shared.keyL3Pressed(pressed, value);
            }
        }];
        [rightThumbstickButton setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
            if (GSGameControllerManager.shared.keyR3Pressed) {
                GSGameControllerManager.shared.keyR3Pressed(pressed, value);
            }
        }];
    }
    
    // dpad
    GCControllerDirectionPad *dPad = [self.extendedGamepad dpad];
    [dPad setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
        if (oldDpadXValue == oldDpadDefaultValue) {
            oldDpadXValue = xValue;// 1.0
        }
        
        if (oldDpadYValue == oldDpadDefaultValue) {
            oldDpadYValue = yValue;// 0.0
        }
        
        if (xValue == 0.f &&
            yValue == 0.f) {
            if (oldDpadYValue == 1.f) {// ↑
                !GSGameControllerManager.shared.keyUpPressed ? : GSGameControllerManager.shared.keyUpPressed(NO, fabs(yValue));
            }
            else if (oldDpadYValue == -1.f) {// ↓
                !GSGameControllerManager.shared.keyDownPressed ? : GSGameControllerManager.shared.keyDownPressed(NO, fabs(yValue));
            }
            else if (oldDpadXValue == -1.f) {// ←
                !GSGameControllerManager.shared.keyLeftPressed ? : GSGameControllerManager.shared.keyLeftPressed(NO, fabs(xValue));
            }
            else if (oldDpadXValue == 1.f) {// →
                !GSGameControllerManager.shared.keyRightPressed ? : GSGameControllerManager.shared.keyRightPressed(NO, fabs(xValue));
            }
            
            oldDpadXValue = oldDpadDefaultValue;
            oldDpadYValue = oldDpadDefaultValue;
        }
        else {
            if (yValue == 1.f) {// ↑
                !GSGameControllerManager.shared.keyUpPressed ? : GSGameControllerManager.shared.keyUpPressed(YES, fabs(yValue));
            }
            else if (yValue == -1.f) {// ↓
                !GSGameControllerManager.shared.keyDownPressed ? : GSGameControllerManager.shared.keyDownPressed(YES, fabs(yValue));
            }
            else if (xValue == -1.f) {// ←
                !GSGameControllerManager.shared.keyLeftPressed ? : GSGameControllerManager.shared.keyLeftPressed(YES, fabs(xValue));
            }
            else if (xValue == 1.f) {// →
                !GSGameControllerManager.shared.keyRightPressed ? : GSGameControllerManager.shared.keyRightPressed(YES, fabs(xValue));
            }
        }
    }];
    
    // Joystick
    GCControllerDirectionPad *leftThumbstick  = [self.extendedGamepad leftThumbstick];
    GCControllerDirectionPad *rightThumbstick = [self.extendedGamepad rightThumbstick];
    [leftThumbstick setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
        !GSGameControllerManager.shared.leftJoystickChanged ? : GSGameControllerManager.shared.leftJoystickChanged(xValue - lastLX, yValue - lastLY);
        lastLX = xValue;
        lastLY = yValue;
    }];
    
    [rightThumbstick setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
        !GSGameControllerManager.shared.rightJoystickChanged ? : GSGameControllerManager.shared.rightJoystickChanged(xValue - lastRX, yValue - lastRY);
        lastRX = xValue;
        lastRY = yValue;
    }];
}

@end
