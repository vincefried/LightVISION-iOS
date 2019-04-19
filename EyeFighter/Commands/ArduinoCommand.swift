//
//  ArduinoCommand.swift
//  MobileSystemeListe
//
//  Created by Vincent Friedrich on 16.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

enum Command: String, Codable {
    case activate = "a"
}

protocol ArduinoCommand: Codable {
    var c: Command { get }
    var jsonData: Data? { get }
}

extension ArduinoCommand {
    var jsonData: Data? {
        do {
            let data = try JSONEncoder().encode(self)
            let string = String(data: data, encoding: .utf8)
            return string?.appending("\n").data(using: .utf8)
        } catch {
            return nil
        }
    }
}
