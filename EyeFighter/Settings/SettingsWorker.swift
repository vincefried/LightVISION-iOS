//
//  SettingsWorker.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 28.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A worker class that saves and loads its properties using `UserDefaults`.
/// Used for saving and loading settings.
class SettingsWorker {
    /// A list of keys for each property to save and load by `UserDefaults`.
    ///
    /// - debugMode: Is the debug mode enabled.
    /// - voiceAssistant: Is the voice assistant enabled.
    private enum SettingsKey: String {
        case debugMode = "debug_mode"
        case voiceAssistant = "voice_assistant"
    }
    
    /// Is the debug mode enabled.
    var isDebugModeEnabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SettingsKey.debugMode.rawValue)
        }
        
        get {
            return UserDefaults.standard.bool(forKey: SettingsKey.debugMode.rawValue)
        }
    }
    
    /// Is the voice assistant enabled.
    var isVoiceAssistantEnabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SettingsKey.voiceAssistant.rawValue)
        }
        
        get {
            return UserDefaults.standard.bool(forKey: SettingsKey.voiceAssistant.rawValue)
        }
    }
}
