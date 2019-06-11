//
//  ArduinoCommand.swift
//  MobileSystemeListe
//
//  Created by Vincent Friedrich on 16.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A protocol that represents a bluetooth command.
/// Use it to send commands compatible with the [BluetoothWorker](x-source-tag://BluetoothWorker).
/// - Tag: BluetoothCommand
protocol BluetoothCommand {
    /// The contained data, later used for sending via bluetooth.
    var data: Data? { get }
    /// A string representation of the bluetooth command, later used for being encoded to data.
    var stringRepresentation: String { get }
}

extension BluetoothCommand {
    var data: Data? {
        // Append new line feed \n as ordinal number to data
        guard var data = stringRepresentation.data(using: .utf8),
            let char = Character("\n").asciiValue else { return nil }
        data.append(char)
        return data
    }
}
