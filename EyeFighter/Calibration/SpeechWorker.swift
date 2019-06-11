//
//  SpeechWorker.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 02.06.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Speech

/// A worker class that handles speech output using Apple's `Speech` framework.
class SpeechWorker {
    /// An instance of the speech synthesizer.
    private let synthesizer = AVSpeechSynthesizer()
    
    /// Gets the descrtiption for a give calibration state.
    ///
    /// - Parameter state: The given calibration state to get the description for.
    /// - Returns: The description in german.
    private func description(for state: CalibrationState) -> String {
        switch state {
        case .initial:
            return "Um die Kalibrierung zu starten, tippe auf den Bildschirm. Schaue in den folgenden Schritten stets auf den projezierten Punkt an der Wand und halte den Blick dort während du zum Fortfahren auf den Bildschirm tippst."
        case .center:
            return "Schau in die Mitte auf den Punkt an der Wand und tippe währenddessen auf den Bildschirm. Es ist nicht schlimm wenn der Punkt vom iPhone verdeckt wird."
        case .right:
            return "Schau auf den rechten Punkt und tippe."
        case .down:
            return "Schau auf den unteren Punkt und tippe."
        case .left:
            return "Schau auf den linken Punkt und tippe."
        case .up:
            return "Schau auf den oberen Punkt und tippe."
        case .done:
            return "Die Kalibrierung ist abgeschlossen. Zum Zurücksetzen berühre für einige Sekunden den Bildschirm. Viel Spaß!"
        }
    }
    
    /// Uses the `AVSpeechSynthesizer` to read out a description for a given `CalibrationState`.
    ///
    /// - Parameter state: The given `CalibrationState`.
    func introduceCalibrationState(state: CalibrationState) {
        let text = description(for: state)
        let utterence = AVSpeechUtterance(string: text)
        utterence.voice = AVSpeechSynthesisVoice(language: "de-DE")
        utterence.rate = 0.55
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }
        synthesizer.speak(utterence)
    }
}
