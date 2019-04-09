//
//  ViewController.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 02.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit
import ARKit
import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var upView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var centerView: UIView!
    
    var faceAnchor: ARFaceAnchor?
    
    var point = UIView()
    
    let calibration = Calibration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))

        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
        sceneView.delegate = self
        
        calibration.delegate = self
    }
    
    @objc private func didTap() {
        guard let faceAnchor = faceAnchor else { return }
        if calibration.state == .done {
            guard let position = calibration.getPosition(x: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y) else { return }
            let synthesizer = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: position.humanReadablePosition)
            utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
            utterance.rate = 0.65
            synthesizer.speak(utterance)
            
            print(position.humanReadablePosition)
        } else {
            calibration.calibrate(to: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y)
            calibration.next()
        }
    }
    
    @objc private func didLongPress() {
        calibration.reset()
        point.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.transparency = 0.0
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        faceAnchor = anchor as? ARFaceAnchor
        
        guard let faceAnchor = faceAnchor,
            let position = calibration.getPosition(x: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y) else { return }
        
        DispatchQueue.main.async {
            if !self.view.subviews.contains(self.point) {
                self.view.addSubview(self.point)
                self.point.backgroundColor = .red
            }
        }
        
        let midX = Double(UIScreen.main.bounds.midX)
        let midY = Double(UIScreen.main.bounds.midY)
        var x = 0.0
        var y = 0.0

        if position.trend.x == .right {
            x = midX + Double(200.0 * position.x)
        } else {
            x = midX - Double(200.0 * (position.x * -1))
        }
        
        if position.trend.y == .up {
            y = midY - Double(200.0 * position.y)
        } else {
            y = midY + Double(200.0 * (position.y * -1))
        }

        DispatchQueue.main.async {
            self.point.frame = CGRect(x: x, y: y, width: 50.0, height: 50.0)
        }
        print("x: \(position.x) y: \(position.y)")
    }
}

extension ViewController: CalibrationDelegate {
    func calibrationStateDidChange() {
        DispatchQueue.main.async {
            self.upView.isHidden = self.calibration.state != .up && self.calibration.state != .initial
            self.rightView.isHidden = self.calibration.state != .right && self.calibration.state != .initial
            self.downView.isHidden = self.calibration.state != .down && self.calibration.state != .initial
            self.leftView.isHidden = self.calibration.state != .left && self.calibration.state != .initial
            self.centerView.isHidden = self.calibration.state != .center && self.calibration.state != .initial
        }
    }
    
    func calibrationDidChange(for state: CalibrationState, value: Float) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "\(String(format: "%.2f", value)) gespeichert für \(state.rawValue)")
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        utterance.rate = 0.65
        synthesizer.speak(utterance)
        
        print("Saved point \(value) for \(state.rawValue)")
    }
}
