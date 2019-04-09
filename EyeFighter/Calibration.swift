//
//  Calibration.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 09.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

protocol CalibrationDelegate {
    func calibrationStateDidChange()
}

class Calibration {
    enum CalibrationState {
        case initial, center, right, left, up, down, done
        
        var next: CalibrationState {
            switch self {
            case .initial:
                return .center
            case .center:
                return .right
            case .right:
                return .down
            case .down:
                return .left
            case .left:
                return .up
            case .up:
                return .done
            case .done:
                return .done
            }
        }
    }
    
    var state: CalibrationState = .center {
        didSet {
            delegate?.calibrationStateDidChange()
        }
    }
    
    var delegate: CalibrationDelegate?
    
    var centerX: Float?
    var centerY: Float?
    var maxX: Float?
    var minX: Float?
    var maxY: Float?
    var minY: Float?
    
    func calibrate(to x: Float, y: Float) {
        switch state {
        case .center:
            centerX = x
            centerY = y
        case .right:
            maxX = x
        case .down:
            minY = y
        case .left:
            minX = x
        case .up:
            maxY = y
        default:
            break
        }
    }
    
    func next() {
        state = state.next
    }
    
    func reset() {
        state = .initial
        
        maxX = nil
        maxY = nil
        minX = nil
        minY = nil
    }
    
    func getPosition(x: Float, y: Float) -> (x: Float, y: Float)? {
        guard let maxX = maxX,
            let minX = minX,
            let maxY = maxY,
            let minY = minY,
            let centerX = centerX,
            let centerY = centerY else { return nil }
        
        let xBorder = x < centerX ? minX : maxX
        let yBorder = y < centerY ? minY : maxY
        return (x: x / xBorder, y: y / yBorder)
    }
}
