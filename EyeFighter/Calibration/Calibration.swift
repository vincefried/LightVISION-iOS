//
//  Calibration.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 09.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An enum that respresents a calibration state.
///
/// - initial: The calibration has not yet started but is in resetted state.
/// - center: The calibration is in centered state.
/// - right: The calibration is in right state.
/// - left: The calibration is in left state.
/// - up: The calibration is in up state.
/// - down: The calibration is in down state.
/// - done: The calibration is done and ready for calling `getPosition(x:_, y:_)`.
enum CalibrationState: String {
    case initial, center, right, left, up, down, done
    
    /// The next possible calibration state after the current.
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
    /// Gets called when calibration state did change.
    ///
    /// - Parameter state: The new calinrationstate.
    /// - Tag: calibrationStateDidChange
    func calibrationStateDidChange(to state: CalibrationState)
    /// Gets called when any of the calibration values have been set.
    ///
    /// - Parameters:
    ///   - state: The state for which the values have been set.
    ///   - value: The new value.
    /// - Tag: calibrationDidChange
    func calibrationDidChange(for state: CalibrationState, value: Float)
    /// Gets called when the face detection state changed.
    ///
    /// - Parameter isFaceDetected: If the face has been detected.
    /// - Tag: changedFaceDetectedState
    func changedFaceDetectedState(isFaceDetected: Bool)
}

/// A class that helps calibrating the eye position of the user to the external device in between given borders.
/// All values to be converted to etc. are created in the standard DMX range of 0-255.
class Calibration {
    
    /// The current offset to stretch or compress the calculation by.
    private let factorOffset: (x: Float, y: Float) = (x: 0.8, y: 0.8)
    
    // MARK: - Variables
    var delegate: CalibrationDelegate?
    
    /// Indicates if a face has been detected.
    /// Calls [changedFaceDetectedState](x-source-tag://changedFaceDetectedState) if changed.
    var isFaceDetected: Bool = false {
        didSet {
            delegate?.changedFaceDetectedState(isFaceDetected: isFaceDetected)
        }
    }
    
    /// The current calibration state.
    /// Calls [calibrationStateDidChange](x-source-tag://calibrationStateDidChange) if changed.
    var state: CalibrationState = .initial {
        didSet {
            delegate?.calibrationStateDidChange(to: state)
        }
    }
    
    /// Holds the current x value in the center of the calibration.
    /// Calls [calibrationDidChange](x-source-tag://calibrationDidChange) if changed.
    var centerX: Float? {
        didSet {
            guard let value = centerX else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    /// Holds the current y value in the center of the calibration.
    /// Calls [calibrationDidChange](x-source-tag://calibrationDidChange) if changed.
    var centerY: Float? {
        didSet {
            guard let value = centerY else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    /// Holds the current maximum x value in the center of the calibration.
    /// Calls [calibrationDidChange](x-source-tag://calibrationDidChange) if changed.
    var maxX: Float? {
        didSet {
            guard let value = maxX else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    /// Holds the current minimum x value in the center of the calibration.
    /// Calls [calibrationDidChange](x-source-tag://calibrationDidChange) if changed.
    var minX: Float? {
        didSet {
            guard let value = minX else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    /// Holds the current maximum y value in the center of the calibration.
    /// Calls [calibrationDidChange](x-source-tag://calibrationDidChange) if changed.
    var maxY: Float? {
        didSet {
            guard let value = maxY else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    /// Holds the current minimum y value in the center of the calibration.
    /// Calls [calibrationDidChange](x-source-tag://calibrationDidChange) if changed.
    var minY: Float? {
        didSet {
            guard let value = minY else { return }
            delegate?.calibrationDidChange(for: state, value: value)
        }
    }
    
    /// Calibrates to given values on the x- and y-axis of a linear coordinate system.
    ///
    /// - Parameters:
    ///   - x: The value on the x-axis.
    ///   - y: The value on the y-axis.
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
    
    /// Continues calibration to the next state.
    func next() {
        state = state.next
    }
    
    /// Resets calibration the the initial state.
    /// Resets all calibrated values to `nil`.
    func reset() {
        state = .initial
        
        maxX = nil
        maxY = nil
        minX = nil
        minY = nil
        centerX = nil
        centerY = nil
    }
    
    /// Gets the calibration border for a given calibration state.
    /// Represents the maximum or minimum values on the x or y axis in a linear coordinate system.
    ///
    /// - Parameter state: The given state to return the border for.
    /// - Returns: The border for the given tate as tuple with values `x` and `y`.
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
    
    /// Converts given x and y values in the coordinate system of an `ARFaceAnchor` to an `EyePosition`,
    /// respecting the calibrated borders.
    ///
    /// - Parameters:
    ///   - x: The given x value as part of `leftEyeTransform` or `lookAtPoint.x` of `ARFaceAnchor`.
    ///   - y: The given y value as part of `rightEyeTransform` or `lookAtPoint.y` of `ARFaceAnchor`.
    /// - Returns: The resulting `EyePosition`.
    /// - PreCondition: All values have to be initialized and calibrated.
    func getPosition(x: Float, y: Float) -> EyePosition? {
        // All values have to be calibrated.
        guard let maxX = maxX,
            let minX = minX,
            let maxY = maxY,
            let minY = minY,
            let centerX = centerX,
            let centerY = centerY else { return nil }
        
        // The maximum value in each direction on the x-axis and y-axis.
        let xBorder: Float = x < centerX ? minX : maxX
        let yBorder: Float = y < centerY ? minY : maxY
        
        // Calculate the factor for the borders in the x-axis and y-axis.
        let xFactor: Float = ((Float(Calibration.getCalibrationBorder(for: .right).x) - Float(Calibration.getCalibrationBorder(for: .center).x))
            / abs(xBorder)) * factorOffset.x
        let yFactor: Float = ((Float(Calibration.getCalibrationBorder(for: .up).y) - Float(Calibration.getCalibrationBorder(for: .center).y))
            / abs(yBorder)) * factorOffset.y
        
        // Calculate the final values by making sure it does not exceed the DMX's maximum values.
        let newX: Float = max(min(xFactor * x + Float(Calibration.getCalibrationBorder(for: .center).x), 255), 0)
        let newY: Float = max(min(yFactor * y + Float(Calibration.getCalibrationBorder(for: .center).y), 255), 0)
        
        return EyePosition(x: Int(newX), y: Int(newY))
    }
}
