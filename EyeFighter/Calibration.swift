//
//  Calibration.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 09.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

struct Calibration {
    enum CalibrationState {
        case center, right, left, up, down
    }
    
    var maxX: Double
    var minX: Double
    var maxY: Double
    var minY: Double
    
    func getPosition(x: Double, y: Double) -> (x: Double, y: Double) {
        let xBorder = x < 0 ? minX : maxX
        let yBorder = y < 0 ? minY : maxY
        return (x: x / xBorder, y: y / yBorder)
    }
}
