//
//  LedCommand.swift
//  MobileSystemeListe
//
//  Created by Vincent Friedrich on 16.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A bluetooth command that represents a XY-Position of a point in a linear coordinate system.
struct ControlXYCommand: BluetoothCommand {
    var stringRepresentation: String {
        return "x\(x)y\(y)"
    }
    
    /// The value on the x-axis.
    let x: Int
    /// The value on the y-axis.
    let y: Int
    
    /// Initializer of a control xy command.
    ///
    /// - Parameters:
    ///   - x: The value on the x-axis.
    ///   - y: The value on the y-axis.
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    /// Initializer of a control xy command.
    ///
    /// - Parameter direction: The eye position that the user points to.
    init(direction: EyePosition) {
        self.init(x: direction.x, y: direction.y)
    }
}
