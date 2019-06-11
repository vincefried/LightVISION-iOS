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

/// A ViewModel class for the setup container in the [ViewController](x-source-tag://ViewController).
class SetupViewModel {
    /// The title of the setup container.
    var titleText: String = ""
    /// The description of the setup container.
    var descriptionText: String = ""
    
    /// The title's color of the setup container.
    var titleTextColor: UIColor? = UIColor(named: "Red")
    /// The description's of the setup container.
    var descriptionTextColor: UIColor? = UIColor(named: "Highlight")

    var delegate: SetupViewModelDelegate?
    
    /// The current calibration state.
    var calibrationState: CalibrationState
    /// If a face was detected.
    var isFaceDetected: Bool
    
    /// An instance of the `BluetoothWorker`.
    private let bluetoothWorker: BluetoothWorker
    
    /// Initializer with current calibration and bluetooth info.
    ///
    /// - Parameters:
    ///   - calibrationState: The current `CalibrationState`.
    ///   - isFaceDetected: If a face was detected.
    ///   - bluetoothWorker: The current `BluetoothWorker`.
    init(calibrationState: CalibrationState, isFaceDetected: Bool, bluetoothWorker: BluetoothWorker) {
        self.bluetoothWorker = bluetoothWorker
        self.calibrationState = calibrationState
        self.isFaceDetected = isFaceDetected
        handleStateChange(calibrationState: calibrationState)
        updateIsFaceDetected(isFaceDetected: isFaceDetected)
    }
    
    /// Handles the UI reaction to a detected face.
    ///
    /// - Parameter isFaceDetected: If a face was detected.
    func handleIsFaceDetected(isFaceDetected: Bool) {
        guard isFaceDetected != self.isFaceDetected else { return }
        self.isFaceDetected = isFaceDetected
        updateIsFaceDetected(isFaceDetected: isFaceDetected)
    }
    
    /// Updates the UI reaction to a detected face.
    ///
    /// - Parameter isFaceDetected: If a face was detected.
    private func updateIsFaceDetected(isFaceDetected: Bool) {
        if !isFaceDetected {
            titleText = "Kein Gesicht erkannt"
            descriptionText = "Vor Gerät positionieren"
            delegate?.updateSetupUINeeded()
        } else {
            handleStateChange(calibrationState: self.calibrationState)
        }
    }
    
    /// Handles a state change.
    ///
    /// - Parameter calibrationState: The changed `CalibrationState`.
    func handleStateChange(calibrationState: CalibrationState) {
        self.calibrationState = calibrationState
        
        // update UI values according to current calibration state.
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
        
        // Send calibration command via bluetooth to let `BluetoothDevice` match the calibration.
        let border = Calibration.getCalibrationBorder(for: calibrationState)
        let command = ControlXYCommand(x: border.x, y: border.y)
        bluetoothWorker.send(command)
        
        delegate?.updateSetupUINeeded()
    }
}
