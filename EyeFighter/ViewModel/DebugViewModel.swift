//
//  DebugViewModel.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 02.06.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

protocol DebugViewModelDelegate {
    /// Gets called if debug UI needs update.
    func updateDebugUINeeded()
}

/// A ViewModel class for the debug view in the [ViewController](x-source-tag://ViewController).
class DebugViewModel {
    /// The text for the eye position info label.
    var eyePositionLabelText: String = "Keine Informationen"
    /// The text for the calibration info label.
    var calibrationLabelText: String = "Keine Informationen"
    /// If the debug container is hidden.
    var isDebugContainerHidden: Bool {
        return !settingsWorker.isDebugModeEnabled
    }
    // If the calibration label is hidden.
    var isCalibrationLabelHidden: Bool {
        return calibrationLabelText.isEmpty
    }
    
    var delegate: DebugViewModelDelegate?
    
    /// A list of calibration values.
    private var calibrationValues = [CalibrationState : Float]()
    
    /// An instance of the `SettingsWorker`.
    private let settingsWorker: SettingsWorker
    
    /// Initializer with an instance of `SettingsWorker` to let debug container be hidden or not according to settings.
    ///
    /// - Parameter settingsWorker: An instance of `SettingsWorker`.
    init(settingsWorker: SettingsWorker) {
        self.settingsWorker = settingsWorker
    }
    
    /// Formats the values of `EyePosition` to readable debug info.
    ///
    /// - Parameters:
    ///   - eyePosition: An instance of `EyePosition`.
    ///   - rawX: Raw, uncalibrated value for x-axis.
    ///   - rawY: Raw, uncalibrated value for y-axis.
    func updateEyePositionInfo(eyePosition: EyePosition?, rawX: Float, rawY: Float) {
        if let eyePosition = eyePosition {
            self.eyePositionLabelText = String(format: "Raw -> x: %.2f y: %.2f\nConverted -> x: %d y: %d", rawX, rawY, eyePosition.x, eyePosition.y)
        } else {
            self.eyePositionLabelText = String(format: "Raw -> x: %.2f y: %.2f", rawX, rawY)
        }
        delegate?.updateDebugUINeeded()
    }
    
    /// Formats the values of the current `CalibrationState` to readable debug info.
    ///
    /// - Parameters:
    ///   - value: The value that has been calibrated.
    ///   - state: The state for which the value has been calibrated.
    func updateCalibrationInfo(value: Float, state: CalibrationState) {
        calibrationValues[state] = value
        self.calibrationLabelText = String(calibrationValues.sorted { $0.key.rawValue < $1.key.rawValue }
                                                            .flatMap { "\($0.rawValue) -> \($1)\n" })
                                                            .trimmingCharacters(in: .newlines)
        delegate?.updateDebugUINeeded()
    }
}
