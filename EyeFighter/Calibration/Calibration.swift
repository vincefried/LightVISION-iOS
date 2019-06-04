//
//  Calibration.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 09.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

enum CalibrationState: String {
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

protocol CalibrationDelegate {
    func calibrationStateDidChange(to state: CalibrationState)
    func calibrationDidChange(for state: CalibrationState, value: Float)
    func changedFaceDetectedState(isFaceDetected: Bool)
}

class Calibration {
    var delegate: CalibrationDelegate?
    
    var isFaceDetected: Bool = false {
        didSet {
            delegate?.changedFaceDetectedState(isFaceDetected: isFaceDetected)
        }
    }
    
    var state: CalibrationState = .initial {
        didSet {
            delegate?.calibrationStateDidChange(to: state)
        }
    }
    
    var centerX: Float? {
        didSet {
            guard let value = centerX else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    var centerY: Float? {
        didSet {
            guard let value = centerY else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    var maxX: Float? {
        didSet {
            guard let value = maxX else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    var minX: Float? {
        didSet {
            guard let value = minX else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    var maxY: Float? {
        didSet {
            guard let value = maxY else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    var minY: Float? {
        didSet {
            guard let value = minY else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    
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
        centerX = nil
        centerY = nil
    }
    
    static func getCalibrationBorder(for state: CalibrationState) -> (x: Int, y: Int) {
        var border = (x: 0, y: 0)
        switch state {
        case .center:
            border = (x: 128, y: 150)
        case .right:
            border = (x: 76, y: 150)
        case .down:
            border = (x: 128, y: 220)
        case .left:
            border = (x: 180, y: 150)
        case .up:
            border = (x: 128, y: 50)
        case .initial:
            border = (x: 128, y: 150)
        case .done:
            border = (x: 128, y: 150)
        }
        return (x: 255 - border.x, y: 255 - border.y)
    }
    
    func getPosition(x: Float, y: Float) -> EyePosition? {
        guard let maxX = maxX,
            let minX = minX,
            let maxY = maxY,
            let minY = minY,
            let centerX = centerX,
            let centerY = centerY else { return nil }
        
        let xBorder: Float = x < centerX ? minX : maxX
        let yBorder: Float = y < centerY ? minY : maxY
        
        let xFactor: Float = ((Float(Calibration.getCalibrationBorder(for: .right).x) - Float(Calibration.getCalibrationBorder(for: .center).x))
            / abs(xBorder)) * 0.8
        let yFactor: Float = ((Float(Calibration.getCalibrationBorder(for: .up).y) - Float(Calibration.getCalibrationBorder(for: .center).y))
            / abs(yBorder)) * 0.8
        
        let newX: Float = max(min(xFactor * x + Float(Calibration.getCalibrationBorder(for: .center).x), 255), 0)
        let newY: Float = max(min(yFactor * y + Float(Calibration.getCalibrationBorder(for: .center).y), 255), 0)
        
        return EyePosition(x: Int(newX), y: Int(newY))
    }
}
