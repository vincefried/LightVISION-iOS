//
//  SetupViewModel.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 29.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import UIKit

protocol SetupViewModelDelegate {
    /// Gets called if setup UI needs update.
    func updateSetupUINeeded()
}

class SetupViewModel {
    var titleText: String = ""
    var descriptionText: String = ""
    
    var titleTextColor: UIColor? = UIColor(named: "Red")
    var descriptionTextColor: UIColor? = UIColor(named: "Highlight")

    var delegate: SetupViewModelDelegate?
    
    var calibrationState: CalibrationState
    var isFaceDetected: Bool
    
    private let bluetoothWorker: BluetoothWorker
    
    init(calibrationState: CalibrationState, isFaceDetected: Bool, bluetoothWorker: BluetoothWorker) {
        self.bluetoothWorker = bluetoothWorker
        self.calibrationState = calibrationState
        self.isFaceDetected = isFaceDetected
        handleStateChange(calibrationState: calibrationState)
        updateIsFaceDetected(isFaceDetected: isFaceDetected)
    }
    
    func handleIsFaceDetected(isFaceDetected: Bool) {
        guard isFaceDetected != self.isFaceDetected else { return }
        self.isFaceDetected = isFaceDetected
        updateIsFaceDetected(isFaceDetected: isFaceDetected)
    }
    
    private func updateIsFaceDetected(isFaceDetected: Bool) {
        if !isFaceDetected {
            titleText = "Kein Gesicht erkannt"
            descriptionText = "Vor Gerät positionieren"
            delegate?.updateSetupUINeeded()
        } else {
            handleStateChange(calibrationState: self.calibrationState)
        }
    }
    
    func handleStateChange(calibrationState: CalibrationState) {
        self.calibrationState = calibrationState
        
        switch calibrationState {
        case .initial:
            titleText = "Nicht kalibriert"
            descriptionText = "Tippe zum Starten"
            titleTextColor = UIColor(named: "Red")
        case .center, .right, .down, .left:
            titleText = "Schau auf den Punkt an der Wand"
            descriptionText = "Tippe zum Fortfahren"
            titleTextColor = UIColor(named: "Yellow")
        case .up:
            titleText = "Schau auf den Punkt an der Wand"
            descriptionText = "Tippe zum Abschließen"
            titleTextColor = UIColor(named: "Yellow")
        case .done:
            titleText = "Kalibriert"
            descriptionText = "Gedrückt halten zum Zurücksetzen"
            titleTextColor = UIColor(named: "Green")
        }
        
        let border = Calibration.getCalibrationBorder(for: calibrationState)
        let command = ControlXYCommand(x: border.x, y: border.y)
        bluetoothWorker.send(command)
        
        delegate?.updateSetupUINeeded()
    }
}
