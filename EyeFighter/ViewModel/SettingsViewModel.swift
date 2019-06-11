//
//  SettingsViewModel.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 28.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A ViewModel struct that holds UI values for the [SettingsViewController](x-source-tag://SettingsViewController).
struct SettingsViewModel {
    /// A text for a label that shows the name and UUID of the currently connected bluetooth device.
    let connectedLabelText: String
    /// Indicates if the debug switch should be on.
    let isDebugSwitchOn: Bool
    /// Indicates if the voice switch should be on.
    let isVoiceSwitchOn: Bool
    
    /// An instance to the `SettingsWorker`.
    private let settingsWorker: SettingsWorker
    
    /// Initializer with given workers, loading each values into the ViewModel.
    ///
    /// - Parameters:
    ///   - settingsWorker: An instance of a `SettingsWorker` for the debug and voice switches.
    ///   - bluetoothWorker: An instance of a `BluetoothWorker` for the currently connected bluetooth info.
    init(settingsWorker: SettingsWorker, bluetoothWorker: BluetoothWorker) {
        self.settingsWorker = settingsWorker
        
        if let peripheral = bluetoothWorker.connectedPeripheral {
            self.connectedLabelText = "Name: \(peripheral.name ?? "Unbekannt")\nUUID: \(peripheral.identifier.uuidString)"
        } else {
            self.connectedLabelText = "Keine Verbindung"
        }
        self.isDebugSwitchOn = settingsWorker.isDebugModeEnabled
        self.isVoiceSwitchOn = settingsWorker.isVoiceAssistantEnabled
    }
    
    /// Handles a debug switch change.
    ///
    /// - Parameter isDebugModeEnabled: If the debug switch is enabled.
    func handleDebugSwitchChanged(isDebugModeEnabled: Bool) {
        settingsWorker.isDebugModeEnabled = isDebugModeEnabled
    }
    /// Handles a voice assistant switch change.
    ///
    /// - Parameter isDebugModeEnabled: If the voice assistant switch is enabled.
    func handleVoiceSwitchChanged(isVoiceAssistantEnabled: Bool) {
        settingsWorker.isVoiceAssistantEnabled = isVoiceAssistantEnabled
    }
}
