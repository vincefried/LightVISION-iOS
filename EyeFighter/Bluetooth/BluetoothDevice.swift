//
//  BluetoothDevice.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 19.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

enum BluetoothDevice: String {
    case laservision = "Laservision"
    
    var name: String {
        return rawValue
    }
}
