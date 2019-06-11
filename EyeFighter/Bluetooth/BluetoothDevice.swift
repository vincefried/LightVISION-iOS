//
//  BluetoothDevice.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 19.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An enum that represents a bluetooth device.
/// Use it to connect with a device, compatible with the [BluetoothWorker](x-source-tag://BluetoothWorker).
/// Typically represents an arduino, connected to a DMX-Lightscanner in this case.
/// - Tag: BluetoothDevice
enum BluetoothDevice: String {
    case lightvision = "LightVISION"
    
    /// The name of the bluetooth device, represented by the enum's raw value.
    var name: String {
        return rawValue
    }
}
