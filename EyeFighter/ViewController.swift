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
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    var faceAnchor: ARFaceAnchor?
    
    var point = UIView()
        
    let calibration = Calibration()
    
    let bluetoothWorker = BluetoothWorker()
    let settingsWorker = SettingsWorker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))

        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
        
        sceneView.delegate = self
        calibration.delegate = self
        bluetoothWorker.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.bluetoothWorker.scanAndConnect() }
    }
    
    @objc private func didTap() {
        guard let faceAnchor = faceAnchor else { return }
        if calibration.state == .done {
            guard let position = calibration.getPosition(x: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y) else { return }
            print("\(position.x) \(position.y)")
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
        
        sceneView.isHidden = !settingsWorker.isDebugModeEnabled
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
            let settingsViewController = navigationController.viewControllers.first as? SettingsViewController else { return }
        let settingsViewModel = SettingsViewModel(settingsWorker: settingsWorker, bluetoothWorker: bluetoothWorker)
        settingsViewController.viewModel = settingsViewModel
    }
    
    @IBAction func tappedRefreshButton(_ sender: UIButton) {
        bluetoothWorker.connect()
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
        
        print("x: \(position.x) y: \(position.y)")
        
        let command = ControlXYCommand(direction: position)
        bluetoothWorker.send(command)
    }
}

extension ViewController: CalibrationDelegate {
    func calibrationStateDidChange(to state: CalibrationState) {
        DispatchQueue.main.async {
            self.upView.isHidden = state != .up && state != .initial
            self.rightView.isHidden = state != .right && state != .initial
            self.downView.isHidden = state != .down && state != .initial
            self.leftView.isHidden = state != .left && state != .initial
            self.centerView.isHidden = state != .center && state != .initial
        }
        
        let border = Calibration.getCalibrationBorder(for: state)
        let command = ControlXYCommand(x: border.x, y: border.y)
        bluetoothWorker.send(command)
    }
    
    func calibrationDidChange(for state: CalibrationState, value: Float) {
        print("Saved point \(value) for \(state.rawValue)")
    }
}

extension ViewController: BluetoothWorkerDelegate {
    func changedConnectionState(_ state: ConnectionState) {
        switch state {
        case .connecting:
            activityIndicator.startAnimating()
            connectingLabel.text = "Connecting..."
        case .connected:
            activityIndicator.stopAnimating()
            connectingLabel.text = "Connected"
        case .disconnected:
            activityIndicator.stopAnimating()
            connectingLabel.text = "No connection"
        case .deviceNotFound:
            activityIndicator.startAnimating()
            connectingLabel.text = "Device not found"
        }
        
        if state == .deviceNotFound {
            self.refreshButton.alpha = 0.0
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            if state == .deviceNotFound {
                self.refreshButton.isHidden = false
            }
            self.refreshButton.alpha = state == .deviceNotFound ? 1.0 : 0.0
        }) { _ in
            self.refreshButton.isHidden = state != .deviceNotFound
        }
        
        connectingLabel.textColor = state == .connected ? .green : .black
    }
    
    func connectedDevice(_ device: BluetoothDevice) {
        print("Successfully connected to \(device.name)")
    }
    
    func disconnectedDevice(_ device: BluetoothDevice) {
        print("Disconnected \(device.name)")
    }
}
