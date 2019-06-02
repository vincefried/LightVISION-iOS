//
//  SpeechWorker.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 02.06.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Speech

class SpeechWorker {
    private let synthesizer = AVSpeechSynthesizer()
    
    private func description(for state: CalibrationState) -> String {
        switch state {
        case .initial:
            return "Um die Kalibrierung zu starten, tippe auf den Bildschirm. Schaue in den folgenden Schritten stets auf den projezierten Punkt an der Wand und halte den Blick dort während du zum Fortfahren auf den Bildschirm tippst."
        case .center:
            return "Schau in die Mitte auf den Punkt an der Wand und tippe währenddessen auf den Bildschirm. Es ist nicht schlimm wenn der Punkt vom iPhone verdeckt wird."
        case .right:
            return "Schau jetzt nach rechts auf den Punkt an der Wand und tippe währenddessen auf den Bildschirm."
        case .down:
            return "Schau jetzt nach unten auf den Punkt an der Wand und tippe währenddessen auf den Bildschirm."
        case .left:
            return "Schau jetzt nach links auf den Punkt an der Wand und tippe währenddessen auf den Bildschirm."
        case .up:
            return "Schau jetzt nach oben auf den Punkt an der Wand und tippe währenddessen auf den Bildschirm."
        case .done:
            return "Die Kalibrierung ist abgeschlossen. Zum Zurücksetzen berühre für einige Sekunden den Bildschirm. Viel Spaß!"
        }
    }
    
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
