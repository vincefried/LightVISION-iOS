//
//  SetupViewModel.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 29.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

protocol SetupViewModelDelegate {
    func updateUINeeded()
}

class SetupViewModel {
    var titleText: String = ""
    var descriptionText: String = ""
    var isDescriptionLabelHidden: Bool = false
    
    var delegate: SetupViewModelDelegate?
    
    var calibrationState: CalibrationState
    var isFaceDetected: Bool = false
    
    let bluetoothWorker: BluetoothWorker
    
    init(calibrationState: CalibrationState, bluetoothWorker: BluetoothWorker) {
        self.bluetoothWorker = bluetoothWorker
        self.calibrationState = calibrationState
        handleStateChange(calibrationState: calibrationState)
    }
    
    func handleIsFaceDetected(isFaceDetected: Bool) {
        guard isFaceDetected != self.isFaceDetected else { return }
        
        self.isFaceDetected = isFaceDetected
        if !isFaceDetected {
            titleText = "No face detected"
            descriptionText = ""
        } else {
            handleStateChange(calibrationState: self.calibrationState)
        }
        
        delegate?.updateUINeeded()
    }
    
    func handleStateChange(calibrationState: CalibrationState) {
        self.calibrationState = calibrationState
        
        switch calibrationState {
        case .initial:
            titleText = "Not calibrated"
            descriptionText = "Tap to start"
        case .center:
            titleText = "Look to center"
            descriptionText = "Tap to set"
        case .right:
            titleText = "Look right"
            descriptionText = "Tap to set"
        case .down:
            titleText = "Look down"
            descriptionText = "Tap to set"
        case .left:
            titleText = "Look left"
            descriptionText = "Tap to set"
        case .up:
            titleText = "Look up"
            descriptionText = "Tap to finish"
        case .done:
            titleText = "Calibrated"
            descriptionText = ""
        }
        
        isDescriptionLabelHidden = calibrationState == .done
        
        let border = Calibration.getCalibrationBorder(for: calibrationState)
        let command = ControlXYCommand(x: border.x, y: border.y)
        bluetoothWorker.send(command)
        
        delegate?.updateUINeeded()
    }
}
