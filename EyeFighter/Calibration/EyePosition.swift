//
//  EyePosition.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 09.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A struct that represents the user's eye position on a linear coordinate system.
struct EyePosition {
    /// A point on the x-axis of the linear coordinate system.
    var x: Int
    /// A point on the y-axis of the linear coordinate system.
    var y: Int
    
    /// Initializer of EyePosition.
    ///
    /// - Parameters:
    ///   - x: A point on the x-axis of the linear coordinate system.
    ///   - y: A point on the y-axis of the linear coordinate system.
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
