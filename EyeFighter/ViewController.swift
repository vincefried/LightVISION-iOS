//
//  ViewController.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 02.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit
#if !targetEnvironment(simulator)
import ARKit
#endif

class ViewController: UIViewController {
    
    // We use UIView instead of ARSCNView because ARSCNView doesn't exist on iOS Simulator
    @IBOutlet weak var sceneView: UIView!
    @IBOutlet weak var upView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var setupView: UIView!
    
    #if !targetEnvironment(simulator)
    var faceAnchor: ARFaceAnchor?
    #endif
    
    var point = UIView()
        
    let calibration = Calibration()
    
    let bluetoothWorker = BluetoothWorker()
    let settingsWorker = SettingsWorker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))

        visualEffectView.layer.cornerRadius = 10
        visualEffectView.layer.masksToBounds = true
        
        #if !targetEnvironment(simulator)
        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
        guard let sceneView = sceneView as? ARSCNView else { return }
        sceneView.delegate = self
        #endif
        
        bluetoothWorker.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.bluetoothWorker.scanAndConnect() }
    }
    
    @objc private func didTap() {
        #if targetEnvironment(simulator)
        if calibration.state != .done {
            calibration.calibrate(to: 0, y: 0)
            calibration.next()
        }
        #else
        guard let faceAnchor = faceAnchor, bluetoothWorker.isConnected else { return }
        if calibration.state == .done {
            guard let position = calibration.getPosition(x: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y) else { return }
            print("\(position.x) \(position.y)")
        } else {
            calibration.calibrate(to: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y)
            calibration.next()
        }
        #endif
    }
    
    @objc private func didLongPress() {
        calibration.reset()
        point.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        #if !targetEnvironment(simulator)
        let configuration = ARFaceTrackingConfiguration()
        
        guard let sceneView = sceneView as? ARSCNView else { return }
        sceneView.session.run(configuration)
        #endif
        
        sceneView.isHidden = !settingsWorker.isDebugModeEnabled
        
        if settingsWorker.isDebugModeEnabled {
            calibration.delegate = self
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let settingsViewController = navigationController.viewControllers.first as? SettingsViewController {
            let settingsViewModel = SettingsViewModel(settingsWorker: settingsWorker, bluetoothWorker: bluetoothWorker)
            settingsViewController.viewModel = settingsViewModel
        }
        
        if let setupViewController = segue.destination as? SetupViewController {
            calibration.delegate = setupViewController
            setupViewController.viewModel = SetupViewModel(calibrationState: calibration.state)
        }
    }
    
    @IBAction func tappedRefreshButton(_ sender: UIButton) {
        bluetoothWorker.connect()
    }
}

#if !targetEnvironment(simulator)
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = sceneView as? ARSCNView,
            let device = sceneView.device else { return nil }
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
#endif

extension ViewController: CalibrationDelegate {
    func calibrationStateDidChange(to state: CalibrationState) {
        if settingsWorker.isDebugModeEnabled {
            DispatchQueue.main.async {
                self.upView.isHidden = state != .up && state != .initial
                self.rightView.isHidden = state != .right && state != .initial
                self.downView.isHidden = state != .down && state != .initial
                self.leftView.isHidden = state != .left && state != .initial
                self.centerView.isHidden = state != .center && state != .initial
            }
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
        
        connectingLabel.textColor = state == .connected ? .green : .white
    }
    
    func connectedDevice(_ device: BluetoothDevice) {
        print("Successfully connected to \(device.name)")
    }
    
    func disconnectedDevice(_ device: BluetoothDevice) {
        print("Disconnected \(device.name)")
    }
}
