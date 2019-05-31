//
//  ViewController.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 02.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit
import ARKit
import FTLinearActivityIndicator

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var setupView: UIView!
    @IBOutlet weak var faceActivityIndicator: FTLinearActivityIndicator!
    
    var faceAnchor: ARFaceAnchor?
    var leftPupil: Pupil?
    var rightPupil: Pupil?
    var arrow: Arrow?
    
    let calibration = Calibration()
    
    let bluetoothWorker = BluetoothWorker()
    let settingsWorker = SettingsWorker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))

        visualEffectView.layer.cornerRadius = 10
        visualEffectView.layer.masksToBounds = true
        
        setupARView()
        
        faceActivityIndicator.hidesWhenStopped = true
        faceActivityIndicator.tintColor = .white
        
        calibration.addObserver(self, delegate: self)
        bluetoothWorker.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.bluetoothWorker.scanAndConnect() }
    }
    
    private func setupARView() {
        guard ARFaceTrackingConfiguration.isSupported else { fatalError("Face ID is not available on this device") }
        
        arrow = Arrow()
        guard let arrow = arrow else { return }
        sceneView.scene.rootNode.addChildNode(arrow)
    }
    
    private func startARView() {
        let configuration = ARFaceTrackingConfiguration()
        
        sceneView.scene.background.contents = UIColor.black
        sceneView.session.run(configuration)
    }
    
    private func pauseARView() {
        sceneView.session.pause()
    }
    
    @objc private func didTap() {
        guard let faceAnchor = faceAnchor, (bluetoothWorker.isConnected || settingsWorker.isDebugModeEnabled) else { return }
        
        if calibration.state == .done {
            guard let position = calibration.getPosition(x: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y) else { return }
            // TODO add labels in debug mode
            print("\(position.x) \(position.y)")
        } else {
            calibration.calibrate(to: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y)
            calibration.next()
        }
    }
    
    @objc private func didLongPress() {
        calibration.reset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseARView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let settingsViewController = navigationController.viewControllers.first as? SettingsViewController {
            let settingsViewModel = SettingsViewModel(settingsWorker: settingsWorker, bluetoothWorker: bluetoothWorker)
            settingsViewController.viewModel = settingsViewModel
        }
        
        if let setupViewController = segue.destination as? SetupViewController {
            calibration.addObserver(setupViewController, delegate: setupViewController)
            setupViewController.viewModel = SetupViewModel(calibrationState: calibration.state, bluetoothWorker: bluetoothWorker)
        }
    }
    
    @IBAction func tappedRefreshButton(_ sender: UIButton) {
        bluetoothWorker.connect()
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        faceGeometry?.firstMaterial?.fillMode = .lines
        faceGeometry?.firstMaterial?.transparency = 0.05
        let node = SCNNode(geometry: faceGeometry)
        
        leftPupil = Pupil()
        rightPupil = Pupil()
        guard let leftPupil = leftPupil, let rightPupil = rightPupil else { return nil }
        node.addChildNode(leftPupil)
        node.addChildNode(rightPupil)
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView,
            let leftPupil = leftPupil,
            let rightPupil = rightPupil else { return }

        DispatchQueue.main.async {
            self.calibration.isFaceDetected = self.sceneView.isNode(leftPupil, insideFrustumOf: pointOfView) && self.sceneView.isNode(rightPupil, insideFrustumOf: pointOfView)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        faceAnchor = anchor as? ARFaceAnchor

        guard let faceAnchor = faceAnchor else { return }
        
        if let leftPupil = leftPupil, let rightPupil = rightPupil {
            leftPupil.update(transform: faceAnchor.leftEyeTransform)
            rightPupil.update(transform: faceAnchor.rightEyeTransform)
        }
        
        if let arrow = arrow, let camera = sceneView.pointOfView {
            arrow.update(position: node.position, camera: camera, calibrationState: calibration.state)
        }
        
        if let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
        }
        
        guard let position = calibration.getPosition(x: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y) else { return }
        
        print("x: \(position.x) y: \(position.y)")
        
        let command = ControlXYCommand(direction: position)
        bluetoothWorker.send(command)
    }
}

extension ViewController: CalibrationDelegate {
    func calibrationStateDidChange(to state: CalibrationState) {
        
    }
    
    func calibrationDidChange(for state: CalibrationState, value: Float) {
        print("Saved point \(value) for \(state.rawValue)")
    }
    
    func changedFaceDetectedState(isFaceDetected: Bool) {
        if isFaceDetected {
            if faceActivityIndicator.isAnimating {
                self.faceActivityIndicator.stopAnimating()
            }
        } else {
            if !faceActivityIndicator.isAnimating {
                self.faceActivityIndicator.startAnimating()
            }
        }
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
