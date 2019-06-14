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

/// A ViewModel class for the connection container in the [ViewController](x-source-tag://ViewController).
class ConnectionViewModel {
    /// The text of the current connection status.
    var connectionText: String = ""
    /// The color of the current connection status text.
    var connectionTextColor: UIColor? = UIColor(named: "Red")
    /// If the activity indicator should be spinning.
    var isAnimating: Bool = false
    /// If the refresh button should be hidden.
    var isRefreshButtonHidden: Bool = true
    
    var delegate: ConnectionViewModelDelegate?
    
    /// An instance of the `BluetoothWorker`.
    private let bluetoothWorker: BluetoothWorker
    
    /// Initializer, called with a `ConnectionState` and an instance of the `BluetoothWorker`.
    ///
    /// - Parameters:
    ///   - bluetoothWorker: The current `BluetoothWorker`.
    init(bluetoothWorker: BluetoothWorker) {
        self.bluetoothWorker = bluetoothWorker
    }
    
    /// Handles a refresh button press and tries a reconnect.
    func handleRefreshButtonPressed() {
        bluetoothWorker.connect()
    }
    
    /// Handles a connection state change and updates the UI values accordingly.
    ///
    /// - Parameter connectionState: The given connection state.
    func handleConnectionStateChange(connectionState: ConnectionState) {
        // Set connection text accordingly.
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
        
        // Update spinner and button
        isAnimating = connectionState == .connecting || connectionState == .disconnected
        isRefreshButtonHidden = connectionState != .deviceNotFound
        
        connectionTextColor = connectionState == .connected ? UIColor(named: "Green") : UIColor(named: "Highlight")
        
        delegate?.updateConnectionUINeeded()
    }
}
