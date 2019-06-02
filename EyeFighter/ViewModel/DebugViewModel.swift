//
//  DebugViewModel.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 02.06.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

protocol DebugViewModelDelegate {
    func updateDebugUINeeded()
}

class DebugViewModel {
    var eyePositionLabelText: String = "Keine Informationen"
    var calibrationLabelText: String = "Keine Informationen"
    var isDebugContainerHidden: Bool {
        return !settingsWorker.isDebugModeEnabled
    }
    var isCalibrationLabelHidden: Bool {
        return calibrationLabelText.isEmpty
    }
    
    var delegate: DebugViewModelDelegate?
    
    private var calibrationValues = [CalibrationState : Float]()
    
    private let settingsWorker: SettingsWorker
    
    init(settingsWorker: SettingsWorker) {
        self.settingsWorker = settingsWorker
    }
    
    func updateEyePositionInfo(eyePosition: EyePosition?, rawX: Float, rawY: Float) {
        if let eyePosition = eyePosition {
            self.eyePositionLabelText = String(format: "Raw -> x: %.2f y: %.2f\nConverted -> x: %d y: %d", rawX, rawY, eyePosition.x, eyePosition.y)
        } else {
            self.eyePositionLabelText = String(format: "Raw -> x: %.2f y: %.2f", rawX, rawY)
        }
        delegate?.updateDebugUINeeded()
    }
    
    func updateCalibrationInfo(value: Float, state: CalibrationState) {
        calibrationValues[state] = value
        self.calibrationLabelText = String(calibrationValues.sorted { $0.key.rawValue < $1.key.rawValue }
                                                            .flatMap { "\($0.rawValue) -> \($1)\n" })
                                                            .trimmingCharacters(in: .newlines)
        delegate?.updateDebugUINeeded()
    }
}
