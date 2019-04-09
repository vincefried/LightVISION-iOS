//
//  EyePosition.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 09.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

struct EyePosition {
    enum HumanReadableXPosition {
        case left, right, unknown
    }
    
    enum HumanReadableYPosition {
        case up, down, unknown
    }
    
    var x: Float
    var y: Float
    
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    var trend: (x: HumanReadableXPosition, y: HumanReadableYPosition) {
        return (x: x < 0 ? .left : .right, y: y < 0 ? .down : .up)
    }
    
    var humanReadablePosition: String {
        switch trend {
        case (.left, .up):
            return "Oben links"
        case (.right, .up):
            return "Oben rechts"
        case (.left, .down):
            return "Unten links"
        case (.right, .down):
            return "Unten rechts"
        default:
            return "Unbekannt"
        }
    }
}
