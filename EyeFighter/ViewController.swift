//
//  ViewController.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 02.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var upView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var leftView: UIView!
    
    let calibration = Calibration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextCalibrationState)))
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(resetCalibration)))

        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
        sceneView.delegate = self
        
        calibration.delegate = self
    }
    
    @objc private func nextCalibrationState() {
        calibration.next()
    }
    
    @objc private func resetCalibration() {
        calibration.reset()
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
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        calibration.calibrate(to: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y)
    }
}

extension ViewController: CalibrationDelegate {
    func calibrationStateDidChange() {
        DispatchQueue.main.async {
            self.upView.isHidden = self.calibration.state != .up
            self.rightView.isHidden = self.calibration.state != .right
            self.downView.isHidden = self.calibration.state != .down
            self.leftView.isHidden = self.calibration.state != .left
        }
    }
}
