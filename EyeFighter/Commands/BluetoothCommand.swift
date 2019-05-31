//
//  ArduinoCommand.swift
//  MobileSystemeListe
//
//  Created by Vincent Friedrich on 16.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

protocol BluetoothCommand {
    var data: Data? { get }
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
