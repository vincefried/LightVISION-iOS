//
//  LedCommand.swift
//  MobileSystemeListe
//
//  Created by Vincent Friedrich on 16.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

struct ControlXYCommand: BluetoothCommand {
    var c: Command = .xyDirection
    
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init(direction: EyePosition) {
        self.init(x: direction.x, y: direction.y)
    }
}
