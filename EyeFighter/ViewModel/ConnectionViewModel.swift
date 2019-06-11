//
//  ConnectionViewModel.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 31.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import UIKit

protocol ConnectionViewModelDelegate {
    /// Gets called if connection UI needs update.
    func updateConnectionUINeeded()
}

class ConnectionViewModel {
    var connectionText: String = ""
    var connectionTextColor: UIColor? = UIColor(named: "Red")
    var isAnimating: Bool = false
    var isRefreshButtonHidden: Bool = true
    
    var delegate: ConnectionViewModelDelegate?
    
    private let bluetoothWorker: BluetoothWorker
    
    init(state: ConnectionState, bluetoothWorker: BluetoothWorker) {
        self.bluetoothWorker = bluetoothWorker
    }
    
    func handleRefreshButtonPressed() {
        bluetoothWorker.connect()
    }
    
    func handleConnectionStateChange(connectionState: ConnectionState) {
        switch connectionState {
        case .connecting:
            connectionText = "Verbinden..."
        case .connected:
            connectionText = "Verbunden"
        case .disconnected:
            connectionText = "Keine Verbindung"
        case .deviceNotFound:
            connectionText = "Kein Gerät gefunden"
        }
        
        isAnimating = connectionState == .connecting || connectionState == .disconnected
        isRefreshButtonHidden = connectionState != .deviceNotFound
        
        connectionTextColor = connectionState == .connected ? UIColor(named: "Green") : UIColor(named: "Highlight")
        
        delegate?.updateConnectionUINeeded()
    }
}
