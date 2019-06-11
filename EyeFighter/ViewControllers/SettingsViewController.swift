//
//  SettingsViewController.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 28.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    /// Gets called if settings view controller will finish dismissing.
    func settingsViewControllerWillFinish(with viewModel: SettingsViewModel)
}

/// Settings ViewController with all settings, containing voice assistant, debug mode and bluetooth connection info.
/// - Tag: SettingsViewController
class SettingsViewController: UIViewController {
    
    // MARK: - Outlets
    
    /// A switch for enabling a debug view in the [ViewController](x-source-tag://ViewController).
    @IBOutlet weak var debugSwitch: UISwitch!
    /// A switch for enabling a voice assistance in the [ViewController](x-source-tag://ViewController) while calibration.
    @IBOutlet weak var voiceSwitch: UISwitch!
    /// A label for showing the currently connected state.
    @IBOutlet weak var connectedWithLabel: UILabel!
    /// A visual effect view containing the controls.
    @IBOutlet weak var visualEffectsView: UIVisualEffectView!
    
    // MARK: - Variables
    
    /// Delegate for the current ViewController.
    var delegate: SettingsViewControllerDelegate?
    
    // MARK: - ViewModels
    
    /// ViewModel for the current ViewController.
    var viewModel: SettingsViewModel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCI()
        updateUI()
    }
    
    /// Styles UI to match corporate identity.
    private func initCI() {
        visualEffectsView.layer.cornerRadius = 10.0
        visualEffectsView.layer.masksToBounds = true
    }
    
    /// Updates the UI according to the ViewModel.
    private func updateUI() {
        debugSwitch.isOn = viewModel.isDebugSwitchOn
        voiceSwitch.isOn = viewModel.isVoiceSwitchOn
        connectedWithLabel.text = viewModel.connectedLabelText
    }
    
    /// Gets called when the debug switch gets toggled.
    ///
    /// - Parameter sender: The debug switch.
    @IBAction func toggledDebugSwitch(_ sender: UISwitch) {
        viewModel.handleDebugSwitchChanged(isDebugModeEnabled: sender.isOn)
    }
    
    /// Gets called when the voice switch gets toggled.
    ///
    /// - Parameter sender: The voice switch.
    @IBAction func toggledVoiceSwitch(_ sender: UISwitch) {
        viewModel.handleVoiceSwitchChanged(isVoiceAssistantEnabled: sender.isOn)
    }
    
    /// Gets called when the done button gets tapped.
    ///
    /// - Parameter sender: The done button.
    @IBAction func tappedDoneButton(_ sender: UIBarButtonItem) {
        delegate?.settingsViewControllerWillFinish(with: viewModel)
        dismiss(animated: true)
    }
}
