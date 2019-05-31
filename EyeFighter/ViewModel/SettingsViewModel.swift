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
        
    private let settingsWorker: SettingsWorker
    
    init(settingsWorker: SettingsWorker, bluetoothWorker: BluetoothWorker) {
        self.settingsWorker = settingsWorker
        
        self.connectedLabelText = "Verbunden mit: " + (bluetoothWorker.connectedPeripheral?.name ?? "Keinem Gerät")
        self.isDebugSwitchOn = settingsWorker.isDebugModeEnabled
    }
    
    func handleDebugSwitchChanged(isDebugModeEnabled: Bool) {
        settingsWorker.isDebugModeEnabled = isDebugModeEnabled
    }
}
