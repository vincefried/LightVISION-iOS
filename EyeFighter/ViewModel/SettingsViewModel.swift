//
//  SettingsViewModel.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 28.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

struct SettingsViewModel {
    let connectedLabelText: String
    let isDebugSwitchOn: Bool
    let isVoiceSwitchOn: Bool
        
    private let settingsWorker: SettingsWorker
    
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
    
    func handleDebugSwitchChanged(isDebugModeEnabled: Bool) {
        settingsWorker.isDebugModeEnabled = isDebugModeEnabled
    }
    
    func handleVoiceSwitchChanged(isVoiceAssistantEnabled: Bool) {
        settingsWorker.isVoiceAssistantEnabled = isVoiceAssistantEnabled
    }
}
