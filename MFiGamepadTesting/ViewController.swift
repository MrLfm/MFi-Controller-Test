//
//  ViewController.swift
//  VastWorldTest
//
//  Created by Leo on 2022/3/21.
//

import UIKit
import GameController

class ViewController: UIViewController, GSGameControllerManagerDelegate {
    
    @IBOutlet weak var leftThumberPointLabel: UILabel!
    @IBOutlet weak var rightThumberPointLabel: UILabel!
    @IBOutlet weak var leftRedPoint: UILabel!
    @IBOutlet weak var rightRedPoint: UILabel!
    @IBOutlet weak var buttonL1: UIButton!
    @IBOutlet weak var buttonL2: UIButton!
    @IBOutlet weak var buttonL3: UIButton!
    @IBOutlet weak var buttonR1: UIButton!
    @IBOutlet weak var buttonR2: UIButton!
    @IBOutlet weak var buttonR3: UIButton!
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonX: UIButton!
    @IBOutlet weak var buttonY: UIButton!
    @IBOutlet weak var buttonUp: UIButton!
    @IBOutlet weak var buttonDown: UIButton!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var buttonRight: UIButton!
    @IBOutlet weak var buttonOptions: UIButton!
    @IBOutlet weak var buttonHome: UIButton!
    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var labelL1: UILabel!
    @IBOutlet weak var labelL2: UILabel!
    @IBOutlet weak var labelL3: UILabel!
    @IBOutlet weak var labelR1: UILabel!
    @IBOutlet weak var labelR2: UILabel!
    @IBOutlet weak var labelR3: UILabel!
    @IBOutlet weak var labelA: UILabel!
    @IBOutlet weak var labelB: UILabel!
    @IBOutlet weak var labelX: UILabel!
    @IBOutlet weak var labelY: UILabel!
    @IBOutlet weak var labelUp: UILabel!
    @IBOutlet weak var labelDown: UILabel!
    @IBOutlet weak var labelLeft: UILabel!
    @IBOutlet weak var labelRight: UILabel!
    @IBOutlet weak var labelOptions: UILabel!
    @IBOutlet weak var labelHome: UILabel!
    @IBOutlet weak var labelMenu: UILabel!
    @IBOutlet weak var labelLeftJoystickX: UILabel!
    @IBOutlet weak var labelLeftJoystickY: UILabel!
    @IBOutlet weak var labelRightJoystickX: UILabel!
    @IBOutlet weak var labelRightJoystickY: UILabel!
    
    var accessory: EAAccessory? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidConnect(notification:)), name:NSNotification.Name.EAAccessoryDidConnect , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidDisconnect(notification:)), name:NSNotification.Name.EAAccessoryDidDisconnect , object: nil)
        
        GSGameControllerManager.shared().delegate = self
    }
    
    
    // MARK: Controller Connecting
    // Will be called after when the controller is connected via bluetooth or lightning
    @objc func accessoryDidConnect(notification: Notification) {
        didConnectGamepad()
    }
    
    @objc func accessoryDidDisconnect(notification: Notification) {
        let disconnectedAccessory = notification.userInfo?[EAAccessoryKey] as! EAAccessory
        if self.accessory != nil &&
            disconnectedAccessory.connectionID == self.accessory!.connectionID {
            self.accessory = nil
            EADSessionController.shared().closeSession()
        }
    }
    
    func manager(_ manager: GSGameControllerManager!, didConnect gameController: GSGameController!) {
        didConnectGamepad()
    }
    
    func manager(_ manager: GSGameControllerManager!, didDisconnect gameController: GSGameController!) {
    }
    
    func didConnectGamepad() {
        setupLightningController()
    }
    
    func setupLightningController() {
        if self.accessory != nil {
            return
        }
        
        let connectedAccessoriesCount = EAAccessoryManager.shared().connectedAccessories.count
        if connectedAccessoriesCount == 0 {
            return
        }
        
        let accessorys = EAAccessoryManager.shared().connectedAccessories
        for accessory in accessorys {
            if accessory.isKind(of: EAAccessory.self) {
                let accessoryStrings = accessory.protocolStrings
                for accessoryString in accessoryStrings {
                    self.accessory = accessory
                    
                    print("Connected Controller：\n", accessory)
                    
                    EADSessionController.shared().setupController(for: accessory, withProtocolString: accessoryString)
                    
                    return
                }
            }
        }
    }
    
    var lastLX: CGFloat = 0
    var lastLY: CGFloat = 0
    var lastRX: CGFloat = 0
    var lastRY: CGFloat = 0
    var joystickRadius: CGFloat = 60
    
    // MARK: Observe controller's key action
    func observeController() {
        
        // A、B、X、Y
        GSGameControllerManager.shared().keyAPressed = { pressed, value in
            self.setPressedKeyWith(index: 0, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyBPressed = { pressed, value in
            self.setPressedKeyWith(index: 1, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyXPressed = { pressed, value in
            self.setPressedKeyWith(index: 2, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyYPressed = { pressed, value in
            self.setPressedKeyWith(index: 3, pressed: pressed, value: value)
        }
        
        // L1、L2、L3、R1、R2、R3
        GSGameControllerManager.shared().keyL1Pressed = { pressed, value in
            self.setPressedKeyWith(index: 4, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyL2Pressed = { pressed, value in
            self.setPressedKeyWith(index: 5, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyL3Pressed = { pressed, value in
            self.setPressedKeyWith(index: 6, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyR1Pressed = { pressed, value in
            self.setPressedKeyWith(index: 7, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyR2Pressed = { pressed, value in
            self.setPressedKeyWith(index: 8, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyR3Pressed = { pressed, value in
            self.setPressedKeyWith(index: 9, pressed: pressed, value: value)
        }
        
        // Direction
        GSGameControllerManager.shared().keyUpPressed = { pressed, value in
            self.setPressedKeyWith(index: 10, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyLeftPressed = { pressed, value in
            self.setPressedKeyWith(index: 11, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyDownPressed = { pressed, value in
            self.setPressedKeyWith(index: 12, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyRightPressed = { pressed, value in
            self.setPressedKeyWith(index: 13, pressed: pressed, value: value)
        }
        
        // Options、Home、Menu
        GSGameControllerManager.shared().keyOptionsPressed = { pressed, value in
            self.setPressedKeyWith(index: 14, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyHomePressed = { pressed, value in
            self.setPressedKeyWith(index: 15, pressed: pressed, value: value)
        }
        
        GSGameControllerManager.shared().keyMenuPressed = { pressed, value in
            self.setPressedKeyWith(index: 16, pressed: pressed, value: value)
        }
        
        // Joystick
        GSGameControllerManager.shared().leftJoystickChanged = { x, y in
            
            var center = self.leftThumberPointLabel.center
            center.x += self.joystickRadius * x
            center.y -= self.joystickRadius * y
            self.leftThumberPointLabel.center = center
            
            self.lastLX = x
            self.lastLY = y
            
            let realX = (center.x - self.leftRedPoint.center.x) / self.joystickRadius
            let realY = (center.y - self.leftRedPoint.center.y) / self.joystickRadius
            let xString = String.init(format: "%.2f", realX)// avoid max value of 256 or 254
            let yString = String.init(format: "%.2f", realY)
            self.labelLeftJoystickX.text = String.init(format: "X: %.0f", Float(xString)!*255)
            self.labelLeftJoystickY.text = String.init(format: "Y: %.0f", Float(yString)!*255)
        }
        
        GSGameControllerManager.shared().rightJoystickChanged = { x, y in
            
            var center = self.rightThumberPointLabel.center
            center.x += self.joystickRadius * x
            center.y -= self.joystickRadius * y
            self.rightThumberPointLabel.center = center
            
            self.lastRX = x
            self.lastRY = y
            
            let realX = (center.x - self.rightRedPoint.center.x) / self.joystickRadius
            let realY = (center.y - self.rightRedPoint.center.y) / self.joystickRadius
            let xString = String.init(format: "%.2f", realX)
            let yString = String.init(format: "%.2f", realY)
            self.labelRightJoystickX.text = String.init(format: "X: %.0f", Float(xString)!*255)
            self.labelRightJoystickY.text = String.init(format: "Y: %.0f", Float(yString)!*255)
        }
    }
    
    func setPressedKeyWith(index: Int, pressed: Bool, value: CGFloat) {
        
        var button = UIButton.init()
        var label = UILabel.init()
        
        switch index {
        case 0:
            button = buttonA!
            label = labelA!
        case 1:
            button = buttonB!
            label = labelB!
        case 2:
            button = buttonX!
            label = labelX!
        case 3:
            button = buttonY!
            label = labelY!
        case 4:
            button = buttonL1!
            label = labelL1!
        case 5:
            button = buttonL2!
            label = labelL2!
        case 6:
            button = buttonL3!
            label = labelL3!
        case 7:
            button = buttonR1!
            label = labelR1!
        case 8:
            button = buttonR2!
            label = labelR2!
        case 9:
            button = buttonR3!
            label = labelR3!
        case 10:
            button = buttonUp!
            label = labelUp!
        case 11:
            button = buttonLeft!
            label = labelLeft!
        case 12:
            button = buttonDown!
            label = labelDown!
        case 13:
            button = buttonRight!
            label = labelRight!
        case 14:
            button = buttonOptions!
            label = labelOptions!
        case 15:
            button = buttonHome!
            label = labelHome!
        case 16:
            button = buttonMenu!
            label = labelMenu!
        default: break
        }
        
        button.isSelected = pressed
        
        label.text = String.init(format: "%.0f", value*255)
    }
    
    
}
