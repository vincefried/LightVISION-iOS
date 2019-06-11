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
    
    // MARK: - Outlets
    
    // AR Scene View for face recongintion and calibration animation
    @IBOutlet weak var sceneView: ARSCNView!
    // Activity indicator for bluetooth connection
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // Label for displaying connection state
    @IBOutlet weak var connectingLabel: UILabel!
    // Refresh button for connection retry if connection failed
    @IBOutlet weak var refreshButton: UIButton!
    // Visual effect view for lower container including calibration guide
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    // Activity indicator if no face is recognized
    @IBOutlet weak var faceActivityIndicator: FTLinearActivityIndicator!
    // Visual effect view for upper container inclusing bluetooth connection info
    @IBOutlet weak var upperContainerView: UIVisualEffectView!
    // Title label of lower setup container
    @IBOutlet weak var setupTitleLabel: UILabel!
    // Description label of lower setup container
    @IBOutlet weak var setupDescriptionLabel: UILabel!
    // Debug label of debug container
    @IBOutlet weak var debugLabel: UILabel!
    // Debug label of debug calibrated values container
    @IBOutlet weak var debugCalibrationLabel: UILabel!
    // Visual effect view for debug container
    @IBOutlet weak var debugVisualEffectView: UIVisualEffectView!
    
    // MARK: - Variables

    // The face anchor, including eye transform
    var faceAnchor: ARFaceAnchor?
    // Reference to the left pupil 3D object for calibration
    var leftPupil: Pupil?
    // Reference to the right pupil 3D object for calibration
    var rightPupil: Pupil?
    // Reference to the arrow 3D object for calibration
    var arrow: Arrow?
    
    // MARK: - Workers
    
    // Calibration class, holding calibrated values
    let calibration = Calibration()
    
    // Bluetooth worker for connecting and sending values
    let bluetoothWorker = BluetoothWorker()
    // Settings worker for getting settings
    let settingsWorker = SettingsWorker()
    // Speech worker for voice guide
    lazy var speechWorker = SpeechWorker()
    
    // MARK: - ViewModels

    // ViewModel for lower calibration container
    var setupViewModel: SetupViewModel!
    // ViewModel for upper bluetooth connection container
    var connectionViewModel: ConnectionViewModel!
    // ViewModel for optional debug container
    var debugViewModel: DebugViewModel!
    
    // MARK: - iOS View lifecycle
    
    /// Part of the iOS view lifecycle.
    /// Gets called when views is done loading.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setups
        setupGestureRecognizers()
        setupUpperContainerView()
        setupDebugContainerView()
        setupLowerContainerView()
        setupActivityIndicator()
        setupARView()
        
        // Set delegates of worker classes
        calibration.delegate = self
        bluetoothWorker.delegate = self
        
        // Init setup viewmodel
        setupViewModel = SetupViewModel(calibrationState: calibration.state,
                                        isFaceDetected: calibration.isFaceDetected,
                                        bluetoothWorker: bluetoothWorker)
        setupViewModel.delegate = self
        updateSetupContainerUI()
        
        // Init connection viewmodel
        connectionViewModel = ConnectionViewModel(state: bluetoothWorker.connectionState,
                                                  bluetoothWorker: bluetoothWorker)
        connectionViewModel.delegate = self
        updateConnectionContainerUI()
        
        // Init debug viewmodel
        debugViewModel = DebugViewModel(settingsWorker: settingsWorker)
        debugViewModel.delegate = self
        updateDebugContainerUI()
        
        // Init speech if voice assistant is enabled
        if settingsWorker.isVoiceAssistantEnabled {
            speechWorker.introduceCalibrationState(state: calibration.state)
        }
        
        // Auto connect after some delay to make sure everything is done loading before connecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.bluetoothWorker.scanAndConnect() }
    }
    
    /// Part of the iOS view lifecycle.
    /// Gets called after view is done loading and about to appear.
    ///
    /// - Parameter animated: If appears animated.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARView()
    }
    
    /// Part of the iOS view lifecycle.
    /// Gets called when the view is about to disappear.
    ///
    /// - Parameter animated: If disappears animated.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseARView()
    }
    
    /// Gets called if iOS prepars for a segue - e.g. when presenting a new ViewController.
    ///
    /// - Parameters:
    ///   - segue: The presentation segue.
    ///   - sender: The sender which presents the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if sender is SettingsViewController
        if let navigationController = segue.destination as? UINavigationController,
            let settingsViewController = navigationController.viewControllers.first as? SettingsViewController {
            // Set SettingsViewModel and set its delegate to this ViewController
            let settingsViewModel = SettingsViewModel(settingsWorker: settingsWorker, bluetoothWorker: bluetoothWorker)
            settingsViewController.viewModel = settingsViewModel
            settingsViewController.delegate = self
        }
    }
    
    // MARK: - Setup helper functions
    
    /// Setup face activityindicator.
    private func setupActivityIndicator() {
        faceActivityIndicator.hidesWhenStopped = true
        faceActivityIndicator.tintColor = .white
    }
    
    /// Setup gesture recognizers.
    private func setupGestureRecognizers() {
        // Tap gesture for continueing calibration
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        // Long press gesture for resetting calibration
        let press = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        // Set minimum press duration for fixing continuos updates while pressing
        press.minimumPressDuration = 1.0
        view.addGestureRecognizer(press)
    }
    
    /// Style debug container.
    private func setupDebugContainerView() {
        debugVisualEffectView.layer.cornerRadius = 10
        debugVisualEffectView.layer.masksToBounds = true
    }
    
    /// Style connection container.
    private func setupUpperContainerView() {
        upperContainerView.layer.cornerRadius = 10
        upperContainerView.layer.masksToBounds = true
    }
    
    /// Style calibration container.
    private func setupLowerContainerView() {
        visualEffectView.layer.cornerRadius = 10
        visualEffectView.layer.masksToBounds = true
    }
    
    /// Setup AR View.
    private func setupARView() {
        // Stop if no AR face tracking is supported
        guard ARFaceTrackingConfiguration.isSupported else { fatalError("AR Face Tracking is not available on this device") }
        
        // Init Arrow and add it to scene for calibration
        arrow = Arrow()
        guard let arrow = arrow else { return }
        sceneView.scene.rootNode.addChildNode(arrow)
    }
    
    /// Starts AR view for face tracking and configure contents.
    private func startARView() {
        let configuration = ARFaceTrackingConfiguration()
        
        sceneView.scene.background.contents = UIColor.black
        sceneView.session.run(configuration)
    }
    
    /// Pauses AR view.
    private func pauseARView() {
        sceneView.session.pause()
    }
    
    // MARK: - ViewModel UI update helper functions
    
    /// Updates UI of upper connection container according to the ConnectionViewModel.
    private func updateConnectionContainerUI() {
        connectingLabel.text = connectionViewModel.connectionText
        connectingLabel.textColor = connectionViewModel.connectionTextColor
        
        refreshButton.isHidden = connectionViewModel.isRefreshButtonHidden
        
        if connectionViewModel.isAnimating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    /// Updates UI of lower calibration container according to the SetupViewModel.
    private func updateSetupContainerUI() {
        setupTitleLabel.text = setupViewModel.titleText
        setupTitleLabel.textColor = setupViewModel.titleTextColor
        setupDescriptionLabel.text = setupViewModel.descriptionText
        
        if setupViewModel.isFaceDetected {
            if faceActivityIndicator.isAnimating {
                self.faceActivityIndicator.stopAnimating()
            }
        } else {
            if !faceActivityIndicator.isAnimating {
                self.faceActivityIndicator.startAnimating()
            }
        }
    }
    
    /// Updates UI of optional debug container according to the DebugViewModel.
    private func updateDebugContainerUI() {
        debugVisualEffectView.isHidden = debugViewModel.isDebugContainerHidden
        debugLabel.text = debugViewModel.eyePositionLabelText
        debugCalibrationLabel.text = debugViewModel.calibrationLabelText
    }
    
    // MARK: - UI actions
    
    /// Gets called if tap gesture recognizer gets triggered by tapping on screen.
    /// Continues to next state of calibration.
    @objc private func didTap() {
        guard let faceAnchor = faceAnchor,
            (bluetoothWorker.isConnected || settingsWorker.isDebugModeEnabled),
            calibration.state != .done else { return }
        
        calibration.calibrate(to: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y)
        calibration.next()
    }
    
    /// Gets called if long press gesture recognizer gets triggered by long pressing on screen.
    /// Resets the calibration.
    ///
    /// - Parameter sender: The long press gesture recognizer
    @objc private func didLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        calibration.reset()
    }
    
    @IBAction func tappedRefreshButton(_ sender: UIButton) {
        connectionViewModel.handleRefreshButtonPressed()
    }
}

// MARK: - AR Scene View delegate

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else { return nil }
        // Init face geometry and setup materials for calibration visualization
        let faceGeometry = ARSCNFaceGeometry(device: device)
        faceGeometry?.firstMaterial?.fillMode = .lines
        faceGeometry?.firstMaterial?.transparency = 0.05
        let faceNode = SCNNode(geometry: faceGeometry)
        
        // Init pupils and attach to face node
        leftPupil = Pupil()
        rightPupil = Pupil()
        guard let leftPupil = leftPupil, let rightPupil = rightPupil else { return nil }
        faceNode.addChildNode(leftPupil)
        faceNode.addChildNode(rightPupil)
        
        return faceNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView,
            let leftPupil = leftPupil,
            let rightPupil = rightPupil else {
                calibration.isFaceDetected = false
                return
        }

        // Update face detected flag if face is in frustum of AR camera
        DispatchQueue.main.async {
            self.calibration.isFaceDetected = self.sceneView.isNode(leftPupil, insideFrustumOf: pointOfView)
                && self.sceneView.isNode(rightPupil, insideFrustumOf: pointOfView)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update face anchor instance
        faceAnchor = anchor as? ARFaceAnchor

        guard let faceAnchor = faceAnchor else { return }
        
        // Update pupil positions
        if let leftPupil = leftPupil, let rightPupil = rightPupil {
            leftPupil.update(transform: faceAnchor.leftEyeTransform)
            rightPupil.update(transform: faceAnchor.rightEyeTransform)
        }
        
        // Update arrow position for calibration
        if let arrow = arrow, let camera = sceneView.pointOfView {
            arrow.update(position: node.position, camera: camera, calibrationState: calibration.state)
        }
        
        // Update face geometry
        if let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
        }
        
        // Get and update eye position and debug info
        let eyePosition = calibration.getPosition(x: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y)
        
        DispatchQueue.main.async {
            self.debugViewModel.updateEyePositionInfo(eyePosition: eyePosition, rawX: faceAnchor.lookAtPoint.x, rawY: faceAnchor.lookAtPoint.y)
        }
        
        // Send command via bluetooth connection
        guard let direction = eyePosition else { return }
        let command = ControlXYCommand(direction: direction)
        bluetoothWorker.send(command)
    }
}

// MARK: - SetupViewModelDelegate
extension ViewController: SetupViewModelDelegate {
    func updateSetupUINeeded() {
        updateSetupContainerUI()
    }
}

// MARK: - ConnectionViewModelDelegate
extension ViewController: ConnectionViewModelDelegate {
    func updateConnectionUINeeded() {
        updateConnectionContainerUI()
    }
}

// MARK: - DebugViewModelDelegate
extension ViewController: DebugViewModelDelegate {
    func updateDebugUINeeded() {
        updateDebugContainerUI()
    }
}

// MARK: - SettingsViewControllerDelegate
extension ViewController: SettingsViewControllerDelegate {
    func settingsViewControllerWillFinish(with viewModel: SettingsViewModel) {
        updateDebugContainerUI()
    }
}

// MARK: - CalibrationDelegate
extension ViewController: CalibrationDelegate {
    func calibrationStateDidChange(to state: CalibrationState) {
        if settingsWorker.isVoiceAssistantEnabled {
            speechWorker.introduceCalibrationState(state: state)
        }
        setupViewModel.handleStateChange(calibrationState: state)
    }
    
    func calibrationDidChange(for state: CalibrationState, value: Float) {
        debugViewModel.updateCalibrationInfo(value: value, state: state)
    }
    
    func changedFaceDetectedState(isFaceDetected: Bool) {
        setupViewModel.handleIsFaceDetected(isFaceDetected: isFaceDetected)
    }
}

// MARK: - BluetoothWorkerDelegate
extension ViewController: BluetoothWorkerDelegate {
    func changedConnectionState(_ state: ConnectionState) {
        connectionViewModel.handleConnectionStateChange(connectionState: state)
    }
    
    func connectedDevice(_ device: BluetoothDevice) {
        print("Successfully connected to \(device.name)")
    }
    
    func disconnectedDevice(_ device: BluetoothDevice) {
        print("Disconnected \(device.name)")
    }
}
